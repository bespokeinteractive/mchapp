package org.openmrs.module.mchapp.fragment.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.SendForExaminationParser;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

/**
 * Created by USER on 5/4/2016.
 */
public class CwcTriageFragmentController {
    private static final String PATIENT_SPECIAL_CLINIC = "MCH CLINIC";

    public void controller(FragmentModel model, UiUtils ui) {
        model.addAttribute("internalReferralSources", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));
    }

    @SuppressWarnings("unchecked")

    public SimpleObject saveCwcTriageInfo(@RequestParam("patientId") Patient patient, HttpServletRequest request) {
        List<Obs> observations = new ArrayList<Obs>();
        for (Map.Entry<String, String[]> postedParams :
                ((Map<String, String[]>) request.getParameterMap()).entrySet()) {
            try {
                observations = ObsParser.parse(
                        observations, patient, postedParams.getKey(),
                        postedParams.getValue());
                SendForExaminationParser.parse(postedParams.getKey(), postedParams.getValue(), patient);
            } catch (Exception e) {
                return SimpleObject.create("status", "error", "message", e.getMessage());
            }
        }

        String examination = request.getParameter("send_for_examination");
        if (StringUtils.isNotEmpty(examination) && examination.equals("yes")) {
            //TODO refer to MCH Clinic
            Concept referralSpecialClinicConcept = Context.getConceptService().getConcept(PATIENT_SPECIAL_CLINIC);
            String paymentCategory = patient.getAttribute(14).getValue();
            sendPatientToOPDQueue(patient, referralSpecialClinicConcept, true, paymentCategory);
        }


        Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST, MchMetadata._MchProgram.PNC_PROGRAM);

        return SimpleObject.create("status", "success", "message", "Triage information has been saved.");


    }

    /**
     * Send patient for OPD Queue
     *
     * @param patient
     * @param selectedOPDConcept
     * @param revisit
     */
    public void sendPatientToOPDQueue(Patient patient, Concept selectedOPDConcept, boolean revisit, String selectedCategory) {
        Concept visitStatus = null;
        if (!revisit) {
            visitStatus = Context.getConceptService().getConcept("NEW PATIENT");
        } else {
            visitStatus = Context.getConceptService().getConcept("REVISIT");
        }

        OpdPatientQueue queue = Context.getService(PatientQueueService.class).getOpdPatientQueue(
                patient.getPatientIdentifier().getIdentifier(), selectedOPDConcept.getConceptId());
        if (queue == null) {
            queue = new OpdPatientQueue();
            queue.setUser(Context.getAuthenticatedUser());
            queue.setPatient(patient);
            queue.setCreatedOn(new Date());
            queue.setBirthDate(patient.getBirthdate());
            queue.setPatientIdentifier(patient.getPatientIdentifier().getIdentifier());
            queue.setOpdConcept(selectedOPDConcept);
            queue.setOpdConceptName(selectedOPDConcept.getName().getName());
            if (null != patient.getMiddleName()) {
                queue.setPatientName(patient.getGivenName() + " " + patient.getFamilyName() + " " + patient.getMiddleName());
            } else {
                queue.setPatientName(patient.getGivenName() + " " + patient.getFamilyName());
            }
            //queue.setReferralConcept(referralConcept);
            //queue.setReferralConceptName(referralConcept.getName().getName());
            queue.setSex(patient.getGender());
            queue.setCategory(selectedCategory);
            queue.setVisitStatus(visitStatus.getName().getName());
            PatientQueueService queueService = Context.getService(PatientQueueService.class);
            queueService.saveOpdPatientQueue(queue);
        }
    }
}
