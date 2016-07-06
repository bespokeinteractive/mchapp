package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Location;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.AdministrationService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientDashboardService;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.model.VisitDetail;
import org.openmrs.module.mchapp.model.VisitSummary;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

public class VisitSummaryFragmentController {
	public void controller(FragmentConfiguration config,
			FragmentModel model) {
		config.require("patientId");
		Integer patientId = Integer.parseInt(config.get("patientId").toString());
        PatientDashboardService dashboardService = Context.getService(PatientDashboardService.class);

        Patient patient = Context.getPatientService().getPatient(patientId);

        MchService mchService = Context.getService(MchService.class);
        EncounterType mchEncType = null;

        if (mchService.enrolledInANC(patient)) {
            mchEncType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE);
        }
        else if (mchService.enrolledInPNC(patient)){
            mchEncType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.PNC_ENCOUNTER_TYPE);
        }
        else{
            mchEncType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.CWC_ENCOUNTER_TYPE);
        }

        List<Encounter> encounters = dashboardService.getEncounter(patient, null, mchEncType, null);
        
        List<VisitSummary> visitSummaries = new ArrayList<VisitSummary>();

        int i=0;
        
        for (Encounter enc : encounters) {
            VisitSummary visitSummary = new VisitSummary();
            visitSummary.setVisitDate(enc.getDateCreated());
            visitSummary.setEncounterId(enc.getEncounterId());
            Concept outcomeConcept = Context.getConceptService().getConcept("Visit outcome");
            for (Obs obs : enc.getAllObs()) {
                if (obs.getConcept().equals(outcomeConcept)) {
                    visitSummary.setOutcome(obs.getValueText());
                }
            }
            visitSummaries.add(visitSummary);

            i++;

            if (i >=20){
                break;
            }
        }
        model.addAttribute("patient", patient);
        model.addAttribute("visitSummaries", visitSummaries);
	}

	public SimpleObject getVisitSummaryDetails(
			@RequestParam("encounterId") Integer encounterId,
			UiUtils ui
			) {
		Encounter encounter = Context.getEncounterService().getEncounter(encounterId);
		VisitDetail visitDetail = VisitDetail.create(encounter);
		
		SimpleObject detail = SimpleObject.fromObject(visitDetail, ui, "diagnosis", "symptoms", "cwcFollowUp", "cwcBreastFeedingExclussive","cwcBreastFeedingInfected", "procedures", "investigations", "examinations", "hivPriorStatus", "hivPartnerStatus", "hivPartnerTested", "hivCoupleCouncelled", "pncExcercise","pncMultivitamin","pncVitaminA","pncHaematinics", "pncFamilyPlanning", "ancCouncelling", "ancExlussiveBF", "ancForInfected", "ancDecisionOnBF", "ancDeworming", "ancExcercise", "ancLLITN","visitOutcome", "internalReferral", "externalReferral");
		List<OpdDrugOrder> opdDrugs = Context.getService(PatientDashboardService.class).getOpdDrugOrder(encounter);
		List<SimpleObject> drugs = SimpleObject.fromCollection(opdDrugs, ui, "inventoryDrug.name",
				"inventoryDrug.unit.name", "inventoryDrugFormulation.name", "inventoryDrugFormulation.dozage","dosage", "dosageUnit.name");
		return SimpleObject.create("notes", detail, "drugs", drugs);
	}
}