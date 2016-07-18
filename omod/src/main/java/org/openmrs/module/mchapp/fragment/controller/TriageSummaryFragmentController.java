package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.List;

import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientDashboardService;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.model.TriageDetail;
import org.openmrs.module.mchapp.model.TriageSummary;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

public class TriageSummaryFragmentController {
	
	public void controller(FragmentConfiguration config,
			FragmentModel model) {
		config.require("patientId");
		Integer patientId = Integer.parseInt(config.get("patientId").toString());
        PatientDashboardService dashboardService = Context.getService(PatientDashboardService.class);

        Patient patient = Context.getPatientService().getPatient(patientId);

        MchService mchService = Context.getService(MchService.class);
        EncounterType mchEncType = null;

        if (mchService.enrolledInANC(patient)) {
            mchEncType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.ANC_TRIAGE_ENCOUNTER_TYPE);
        }
        else if (mchService.enrolledInPNC(patient)){
            mchEncType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.PNC_TRIAGE_ENCOUNTER_TYPE);
        }
        else{
            mchEncType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.CWC_TRIAGE_ENCOUNTER_TYPE);
        }

        List<Encounter> encounters = dashboardService.getEncounter(patient, null, mchEncType, null);
        
        List<TriageSummary> triageSummaries = new ArrayList<TriageSummary>();
        
        int i=0;
        
        for(Encounter enc : encounters){
        	TriageSummary triageSummary = new TriageSummary();
        	triageSummary.setVisitDate(enc.getDateCreated());
        	triageSummary.setEncounterId(enc.getEncounterId());
        	triageSummaries.add(triageSummary);
        	i++;
        	if(i >=20){
        		break;
        	}
         }
        model.addAttribute("patient", patient);
        model.addAttribute("triageSummaries", triageSummaries);
      }
	
	
	public SimpleObject getTriageSummaryDetails(
			@RequestParam("encounterId") Integer encounterId,
			UiUtils ui
			){
		Encounter encounter = Context.getEncounterService().getEncounter(encounterId);
		TriageDetail triageDetail = TriageDetail.create(encounter);
		
		SimpleObject triage = SimpleObject.fromObject(triageDetail, ui, "weight", "height", "temperature", "pulseRate", "systolic", "daistolic", "muac" ,"growthStatus","weightcategory");
		return SimpleObject.create("notes", triage);
	}
}
        