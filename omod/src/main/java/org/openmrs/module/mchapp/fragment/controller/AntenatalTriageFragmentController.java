package org.openmrs.module.mchapp.fragment.controller;

import java.text.ParseException;
import java.util.*;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.module.mchapp.api.parsers.QueueLogs;
import org.openmrs.module.mchapp.api.parsers.SendForExaminationParser;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by qqnarf on 4/27/16.
 */
public class AntenatalTriageFragmentController {
    protected Logger log = LoggerFactory.getLogger(AntenatalTriageFragmentController.class);
    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui,
            @RequestParam(value = "encounterId", required = false) String encounterId) {
        config.require("patientId");
        config.require("queueId");

        MchService service = Context.getService(MchService.class);


        if (StringUtils.isNotEmpty(encounterId)) {
            Encounter current = Context.getEncounterService().getEncounter(Integer.parseInt(encounterId));
            Set<Obs> obs = Context.getEncounterService().getEncounterByUuid(current.getUuid()).getAllObs();
            for (Obs s : obs) {
                switch (s.getConcept().getId()) {
                case 5089: {
                    model.addAttribute("weight", s.getValueNumeric());
                    break;
                }
                case 5090: {
                    model.addAttribute("height", s.getValueNumeric());
                    break;
                }
                case 5086: {
                    model.addAttribute("daistolic", s.getValueNumeric());
                    break;
                }
                case 5085: {
                    model.addAttribute("systolic", s.getValueText());
                    break;
                }
                }
            }
        } else {
            model.addAttribute("weight", "");
            model.addAttribute("height", "");
            model.addAttribute("systolic", "");
            model.addAttribute("daistolic", "");
        }

        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));
        model.addAttribute("patientProfile",
                PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM));
        model.addAttribute("patientHistoricalProfile",
                PatientProfileGenerator.generateHistoricalPatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM));
        model.addAttribute("internalReferrals",
                SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));
        model.addAttribute("queueId", config.get("queueId"));
        model.addAttribute("visitCount", getLastANCVisitNumber(patient)+1);
    }

    public int getLastANCVisitNumber(Patient patient){
        List<Obs> ancVisitObs = new ArrayList<Obs>();
        List<PatientProgram> patientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM), null, null, null, null, false);
        PatientProgram currentProgram = null;
        for (PatientProgram patientProgram : patientPrograms) {
            if (patientProgram.getActive()) {
                currentProgram = patientProgram;
                break;
            }
        }
        if (currentProgram != null) {
            Date dateEnrolled = currentProgram.getDateEnrolled();
            List<Concept> questions = new ArrayList<Concept>() ;
            questions.add(Context.getConceptService().getConceptByUuid(MchMetadata._MchProgram.ANTENATAL_VISIT_NUMBER));
            ancVisitObs = Context.getObsService().getObservations(Arrays.asList((Person) patient), null, questions, null, null, null, Arrays.asList("obsDatetime"), 1, null, dateEnrolled, null, false);
        }

        if (ancVisitObs.size() == 0){
            return 0;
        }
        else{
            return ancVisitObs.get(0).getValueNumeric().intValue();
        }
    }

    public SimpleObject saveAntenatalTriageInformation(@RequestParam("patientId") Patient patient,
            @RequestParam("queueId") Integer queueId, @RequestParam("patientEnrollmentDate") Date patientEnrollmentDate,
            @RequestParam(value = "isEdit", required = false) Boolean isEdit, UiSessionContext session,
            HttpServletRequest request) {
        SimpleObject saveStatus = null;
        PatientQueueService queueService = Context.getService(PatientQueueService.class);
        TriagePatientQueue queue = queueService.getTriagePatientQueueById(queueId);
        try {
            ClinicalForm form = ClinicalForm.generateForm(request, patient, null);
            List<Object> previousVisitsByPatient = Context.getService(MchService.class).findVisitsByPatient(patient, true,
                    true, patientEnrollmentDate);
            int visitTypeId;
            if (previousVisitsByPatient.size() == 0) {
                visitTypeId = MchMetadata._MchProgram.INITIAL_MCH_CLINIC_VISIT;
            } else {
                visitTypeId = MchMetadata._MchProgram.RETURN_ANC_CLINIC_VISIT;
            }
            Encounter encounter = Context.getService(MchService.class).saveMchEncounter(form,
                MchMetadata._MchEncounterType.ANC_TRIAGE_ENCOUNTER_TYPE, session.getSessionLocation(), visitTypeId);

            if (request.getParameter("send_for_examination") != null) {
                String visitStatus = queue.getVisitStatus();
                SendForExaminationParser.parse("send_for_examination", request.getParameterValues("send_for_examination"),
                    patient, visitStatus);
            }
            if (!isEdit) {
                QueueLogs.logTriagePatient(queue, encounter);
            }
            saveStatus = SimpleObject.create("status", "success", "message", "Triage information has been saved.", "isEdit",
                isEdit);
            return saveStatus;
        } catch (NullPointerException e) {
            log.error(e.getMessage());
            return SimpleObject.create("status", "error", "message",
                e.getMessage());
        } catch (ParseException e) {
            log.error(e.getMessage());
            return SimpleObject.create("status", "error", "message",
                e.getMessage());
        }
    }

}
