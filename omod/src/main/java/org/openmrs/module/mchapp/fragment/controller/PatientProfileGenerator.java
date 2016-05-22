package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.List;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;

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
}
