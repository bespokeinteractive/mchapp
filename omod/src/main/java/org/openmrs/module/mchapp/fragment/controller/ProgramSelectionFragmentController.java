package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.Encounter;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

public class ProgramSelectionFragmentController {
    protected Logger logger = LoggerFactory.getLogger(ProgramSelectionFragmentController.class);

    public void controller(FragmentConfiguration config, FragmentModel model) {
        config.require("queueId");

        Concept modeOfDelivery = Context.getConceptService().getConceptByUuid(MchMetadata._MchProgram.PNC_DELIVERY_MODES);
        List<SimpleObject> modesOfDelivery = new ArrayList<SimpleObject>();
        for (ConceptAnswer answer : modeOfDelivery.getAnswers()) {
            modesOfDelivery.add(SimpleObject.create("uuid", answer.getAnswerConcept().getUuid(), "label",
                    answer.getAnswerConcept().getDisplayString()));
        }

        model.addAttribute("queueId", config.get("queueId"));
        model.addAttribute("source", config.get("source"));
        model.addAttribute("deliveryMode", modesOfDelivery);
    }

    public SimpleObject enrollInAnc(
            @RequestParam("patientId") Patient patient,
            @RequestParam("dateEnrolled") String dateEnrolledAsString,
            UiSessionContext session,
            HttpServletRequest request
    ) {
        MchService mchService = Context.getService(MchService.class);
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        Date dateEnrolled;
        try {
            ClinicalForm form = ClinicalForm.generateForm(request, patient, null);
            dateEnrolled = dateFormatter.parse(dateEnrolledAsString);
            mchService.enrollInANC(patient, dateEnrolled);
            Encounter encounter = Context.getService(MchService.class).saveMchEncounter(form, MchMetadata._MchEncounterType.ANC_TRIAGE_ENCOUNTER_TYPE, session.getSessionLocation(), MchMetadata._MchProgram.INITIAL_MCH_CLINIC_VISIT);

            return SimpleObject.create("status", "success", "message", patient + " has been enrolled into ANC");
        } catch (ParseException e) {
            logger.error(e.getMessage());
            return SimpleObject.create("status", "error", "message", dateEnrolledAsString + " is not in the correct format.");
        }
    }

    public SimpleObject enrollInPnc(
            @RequestParam("patientId") Patient patient,
            @RequestParam("dateEnrolled") String dateEnrolledAsString,
            UiSessionContext session,
            HttpServletRequest request
    ) {
        MchService mchService = Context.getService(MchService.class);
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        Date dateEnrolled;
        try {
            ClinicalForm form = ClinicalForm.generateForm(request, patient, null);
            dateEnrolled = dateFormatter.parse(dateEnrolledAsString);
            mchService.enrollInPNC(patient, dateEnrolled);
            Encounter encounter = Context.getService(MchService.class).saveMchEncounter(form, MchMetadata._MchEncounterType.PNC_TRIAGE_ENCOUNTER_TYPE, session.getSessionLocation(), MchMetadata._MchProgram.INITIAL_MCH_CLINIC_VISIT);

            return SimpleObject.create("status", "success", "message", patient + " has been enrolled into PNC");
        } catch (ParseException e) {
            logger.error(e.getMessage());
            return SimpleObject.create("status", "error", "message", dateEnrolledAsString + " is not in the correct format.");
        }
    }

    public SimpleObject enrollInCwc(@RequestParam("patientId") Patient patient,
                                    @RequestParam("dateEnrolled") String dateEnrolledAsString) {
        MchService mchService = Context.getService(MchService.class);
        SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
        Date dateEnrolled;
        try {
            dateEnrolled = dateFormatter.parse(dateEnrolledAsString);
            //TODO add method to enroll in CWC and call from here
            return mchService.enrollInCWC(patient, dateEnrolled, new HashMap<String, String>());
        } catch (ParseException e) {
            logger.error(e.getMessage());
            return SimpleObject.create("status", "error", "message", dateEnrolledAsString + " is not in the correct format.");
        }
    }

}
