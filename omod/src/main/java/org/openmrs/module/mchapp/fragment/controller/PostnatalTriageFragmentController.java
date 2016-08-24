package org.openmrs.module.mchapp.fragment.controller;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.QueueLogs;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.module.mchapp.api.parsers.SendForExaminationParser;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

public class PostnatalTriageFragmentController {
    protected Logger log = LoggerFactory.getLogger(PostnatalTriageFragmentController.class);
    public void controller(FragmentModel model, FragmentConfiguration config,
            @RequestParam(value = "encounterId", required = false) String encounterId, UiUtils ui) {
        config.require("patientId");
        config.require("queueId");

        if (StringUtils.isNotEmpty(encounterId)) {
            Encounter current = Context.getEncounterService().getEncounter(Integer.parseInt(encounterId));
            Set<Obs> obs = Context.getEncounterService().getEncounterByUuid(current.getUuid()).getAllObs();
            for (Obs s : obs) {
                switch (s.getConcept().getId()) {
                case 5088: {
                    model.addAttribute("temperature", s.getValueNumeric());
                    break;
                }
                case 5087: {
                    model.addAttribute("pulseRate", s.getValueNumeric());
                    break;
                }
                case 5085: {
                    model.addAttribute("systolic", s.getValueText());
                    break;
                }
                case 5086: {
                    model.addAttribute("daistolic", s.getValueNumeric());
                    break;
                }
                }
            }
        } else {
            model.addAttribute("temperature", "");
            model.addAttribute("pulseRate", "");
            model.addAttribute("systolic", "");
            model.addAttribute("daistolic", "");
        }

        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));

        Concept modeOfDelivery = Context.getConceptService()
                .getConceptByUuid(MchMetadata._MchProgram.PNC_DELIVERY_MODES);
        List<SimpleObject> modesOfDelivery = new ArrayList<SimpleObject>();
        for (ConceptAnswer answer : modeOfDelivery.getAnswers()) {
            modesOfDelivery.add(SimpleObject.create("uuid", answer.getAnswerConcept().getUuid(), "label",
                    answer.getAnswerConcept().getDisplayString()));
        }

        model.addAttribute("patient", patient);
        model.addAttribute("patientProfile",
                PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.PNC_PROGRAM));
        model.addAttribute("queueId", config.get("queueId"));
        model.addAttribute("deliveryMode", modesOfDelivery);

    }

    public SimpleObject savePostnatalTriageInformation(@RequestParam("patientId") Patient patient,
            @RequestParam("patientEnrollmentDate") Date patientEnrollmentDate, @RequestParam("queueId") Integer queueId,
            @RequestParam(value = "isEdit", required = false) Boolean isEdit, UiSessionContext session,
            HttpServletRequest request) {
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
                visitTypeId = MchMetadata._MchProgram.RETURN_PNC_CLINIC_VISIT;
            }
            Encounter encounter = Context.getService(MchService.class).saveMchEncounter(form,
                MchMetadata._MchEncounterType.PNC_TRIAGE_ENCOUNTER_TYPE, session.getSessionLocation(), visitTypeId);
            if (request.getParameter("send_for_examination") != null) {
                String visitStatus = queue.getVisitStatus();
                SendForExaminationParser.parse("send_for_examination", request.getParameterValues("send_for_examination"),
                    patient, visitStatus);
            }
            if (!isEdit) {
                QueueLogs.logTriagePatient(queue, encounter);
            }

            return SimpleObject.create("status", "success", "message", "Triage information has been saved.", "isEdit",
                isEdit);
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
