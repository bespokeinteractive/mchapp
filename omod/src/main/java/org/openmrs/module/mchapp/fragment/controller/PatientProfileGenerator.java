package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;

import java.util.ArrayList;
import java.util.List;

public class PatientProfileGenerator {
	public static String generatePatientProfile(Patient patient, String program) {
		List<SimpleObject> patientProfile = new ArrayList<SimpleObject>();
		List<Obs> profileObs = Context.getService(MchService.class).getPatientProfile(patient, program);
		for (Obs singleProfileObs : profileObs) {
			SimpleObject profileInfo = new SimpleObject();
			profileInfo.put("name", singleProfileObs.getConcept().getDisplayString());
			profileInfo.put("uuid", singleProfileObs.getConcept().getUuid());
			profileInfo.put("value", singleProfileObs.getValueAsString(Context.getLocale()));
			patientProfile.add(profileInfo);
		}
		return SimpleObject.create("details", patientProfile).toJson();
	}

	public static String generateHistoricalPatientProfile(Patient patient, String program) {
		List<SimpleObject> patientProfile = new ArrayList<SimpleObject>();
		List<Obs> profileObs = Context.getService(MchService.class).getHistoricalPatientProfile(patient, program);
		for (Obs singleProfileObs : profileObs) {
			SimpleObject profileInfo = new SimpleObject();
			profileInfo.put("name", singleProfileObs.getConcept().getDisplayString());
			profileInfo.put("uuid", singleProfileObs.getConcept().getUuid());
			profileInfo.put("value", singleProfileObs.getValueAsString(Context.getLocale()));
			profileInfo.put("date", singleProfileObs.getObsDatetime());
			profileInfo.put("encounter", singleProfileObs.getEncounter().getEncounterId());
			patientProfile.add(profileInfo);
		}
		return SimpleObject.create("historicalDetails", patientProfile).toJson();
	}
}
