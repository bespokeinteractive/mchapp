package org.openmrs.module.mchapp.api.impl;

import static java.lang.Math.max;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchEncounterService;

public class MchEncounterServiceImpl implements MchEncounterService {

	private static final String FINAL_DIAGNOSIS_UUID = "7033ef37-461c-4953-a757-34722b6d9e38";
	private static final int MAX_ANC_DURATION = 9;
	private static final int MAX_PNC_DURATION = 9;
	private static final int MAX_CWC_DURATION = 5;
	@Override
	public List<String> getConditions(Patient patient) {
		Calendar minEnrollmentDate = Calendar.getInstance();
		minEnrollmentDate
				.add(Calendar.MONTH,
						-max(max(MAX_CWC_DURATION, MAX_ANC_DURATION),
								MAX_PNC_DURATION));
		List<PatientProgram> patientPrograms = Context
				.getProgramWorkflowService().getPatientPrograms(patient,
						null, minEnrollmentDate.getTime(), null, null, null,
						false);
		PatientProgram currentProgram = null;
		for (PatientProgram patientProgram : patientPrograms) {
			if (patientProgram.getActive()) {
				currentProgram = patientProgram;
				break;
			}
		}
		
		if (currentProgram != null) {
			Concept diagnosis = Context.getConceptService().getConceptByUuid(FINAL_DIAGNOSIS_UUID);
			List<Concept> questions = new ArrayList<Concept>();
			questions.add(diagnosis);
			List<Obs> allDiagnosisObs = Context.getObsService().getObservations(Arrays.asList((Person) patient), null, questions, null, null, null, Arrays.asList("obsDatetime"), null, null, currentProgram.getDateEnrolled(), null, false);
			List<String> currentDiagnosisObs = new ArrayList<String>();
			Calendar mostCurrentObsDate = null;
			for (Obs obs : allDiagnosisObs) {
				Calendar obsDate = Calendar.getInstance();
				obsDate.setTime(obs.getObsDatetime());
				if (mostCurrentObsDate == null) {
					mostCurrentObsDate = Calendar.getInstance();
					mostCurrentObsDate.setTime(obs.getObsDatetime());
					currentDiagnosisObs.add(obs.getValueCoded().getUuid());
				} else if (mostCurrentObsDate.get(Calendar.YEAR) == obsDate.get(Calendar.YEAR) 
					&& mostCurrentObsDate.get(Calendar.DAY_OF_YEAR) == obsDate.get(Calendar.DAY_OF_YEAR)) {
					currentDiagnosisObs.add(obs.getValueCoded().getUuid());
				}
			}
			return currentDiagnosisObs;
		}
		return new ArrayList<String>();
	}

}
