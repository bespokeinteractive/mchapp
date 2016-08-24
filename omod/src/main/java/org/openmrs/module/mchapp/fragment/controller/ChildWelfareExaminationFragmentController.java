package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Encounter;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.openmrs.module.mchapp.*;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.module.mchapp.api.parsers.QueueLogs;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.module.patientdashboardapp.model.ReferralReasons;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;

import java.text.ParseException;

/**
 * @author Stanslaus Odhiambo
 * Created on 5/30/2016.
 */
public class ChildWelfareExaminationFragmentController {
    protected Logger log = LoggerFactory.getLogger(ChildWelfareExaminationFragmentController.class);
    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui) {
        config.require("patientId");
        config.require("queueId");
        String queueId = config.get("queueId").toString();
        String patientID = config.get("patientId").toString();
        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(patientID));
        model.addAttribute("patient", patient);
        model.addAttribute("patientProfile", PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.CWC_PROGRAM));
        model.addAttribute("patientHistoricalProfile", PatientProfileGenerator.generateHistoricalPatientProfile(patient, MchMetadata._MchProgram.CWC_PROGRAM));
        model.addAttribute("internalReferrals", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("externalReferrals", SimpleObject.fromCollection(Referral.getExternalReferralOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("referralReasons", SimpleObject.fromCollection(ReferralReasons.getReferralReasonsOptions(), ui, "label", "id", "uuid"));


        model.addAttribute("queueId", queueId);
    }

    public SimpleObject saveCwcExaminationInformation(
            @RequestParam("patientId") Patient patient,
            @RequestParam("queueId") Integer queueId,
            UiSessionContext session,
            HttpServletRequest request) {


        OpdPatientQueue patientQueue = Context.getService(
                PatientQueueService.class).getOpdPatientQueueById(queueId);
        String location = "CWC Exam Room";
        if (patientQueue != null) {
            location = patientQueue.getOpdConceptName();
        }
        try {
            ClinicalForm form = ClinicalForm.generateForm(request, patient, location);
            InternalReferral internalReferral = new InternalReferral();
            Encounter encounter = Context.getService(MchService.class).saveMchEncounter(form,
                 MchMetadata._MchEncounterType.CWC_ENCOUNTER_TYPE, session.getSessionLocation());
            String refferedRoomUuid = request.getParameter("internalRefferal");
            if(refferedRoomUuid != "" && refferedRoomUuid != null && !refferedRoomUuid.equals(0) && !refferedRoomUuid.equals("0")) {
                internalReferral.sendToRefferedRoom(patient, refferedRoomUuid);
            }
            QueueLogs.logOpdPatient(patientQueue, encounter);
            return SimpleObject.create("status", "success", "message",
                "Examination information has been saved.");
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
