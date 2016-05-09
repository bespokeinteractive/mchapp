package org.openmrs.module.mchapp.api.impl;

import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.MchService;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class MchServiceImpl implements MchService {

	private static final int MAX_ANC_DURATION = 9;
	private static final int MAX_PNC_DURATION = 9;

	@Override
	public boolean enrolledInANC(Patient patient) {
		Program ancProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM);
		Calendar minEnrollmentDate = Calendar.getInstance();
		minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_DURATION);
		List<PatientProgram> ancPatientPrograms =  Context.getProgramWorkflowService().getPatientPrograms(patient, ancProgram, minEnrollmentDate.getTime(), null, null, null, false);
		if (ancPatientPrograms.size() > 0) {
			return true;
		}
		return false;
	}

	@Override
	public void enrollInANC(Patient patient, Date dateEnrolled) {
		PatientProgram patientProgram = new PatientProgram();
		patientProgram.setPatient(patient);
		Program ancProgram =  Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM);
		patientProgram.setProgram(ancProgram);
		patientProgram.setDateEnrolled(dateEnrolled);
		//TODO Add creator 
		Context.getProgramWorkflowService().savePatientProgram(patientProgram);
	}

	@Override
	public boolean enrolledInPNC(Patient patient) {
		Program pncProgram =  Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM);
		Calendar minEnrollmentDate = Calendar.getInstance();
		minEnrollmentDate.add(Calendar.MONTH, -MAX_PNC_DURATION);
		List<PatientProgram> pncPatientPrograms =  Context.getProgramWorkflowService().getPatientPrograms(patient, pncProgram, minEnrollmentDate.getTime(), null, null, null, false);
		if (pncPatientPrograms.size() > 0) {
			return true;
		}
		return false;
	}

	@Override
	public void enrollInPNC(Patient patient, Date dateEnrolled) {
		PatientProgram patientProgram = new PatientProgram();
		patientProgram.setPatient(patient);
		Program pncProgram =  Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM);
		patientProgram.setProgram(pncProgram);
		patientProgram.setDateEnrolled(dateEnrolled);
		//TODO Add creator 
		Context.getProgramWorkflowService().savePatientProgram(patientProgram);
	}

	@Override
	public Encounter saveMchEncounter(Patient patient, List<Obs> encounterObservations, String program) {
		Encounter mchEncounter = new Encounter();
		mchEncounter.setPatient(patient);
		Date encounterDateTime = new Date();
		if (encounterObservations.size() > 0) {
			encounterDateTime = encounterObservations.get(0).getObsDatetime();
		}
		mchEncounter.setEncounterDatetime(encounterDateTime);
		EncounterType mchEncounterType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE);
		mchEncounter.setEncounterType(mchEncounterType);
		for (Obs obs : encounterObservations) {
			mchEncounter.addObs(obs);
		}
		return Context.getEncounterService().saveEncounter(mchEncounter);
	}
}
