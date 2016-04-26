package org.openmrs.module.mchapp.api.impl;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Program;
import org.openmrs.api.ProgramWorkflowService;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchService;

public class MchServiceImpl implements MchService {

	private static final int MAX_ANC_DURATION = 9;
	private static final int MAX_PNC_DURATION = 9;
	private static final String ANC_PROGRAM_UUID = "mchapp.ancuuid";
	private static final String PNC_PROGRAM_UUID = "mchapp.pncuuid";
	private ProgramWorkflowService programWorkflowService;

	public ProgramWorkflowService getProgramWorkflowService() {
		return programWorkflowService;
	}

	public void setProgramWorkflowService(ProgramWorkflowService programWorkflowService) {
		this.programWorkflowService = programWorkflowService;
	}

	@Override
	public boolean enrolledInANC(Patient patient) {
		Program ancProgram = programWorkflowService.getProgramByUuid(Context.getAdministrationService().getGlobalProperty(ANC_PROGRAM_UUID));
		Calendar minEnrollmentDate = Calendar.getInstance();
		minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_DURATION);
		List<PatientProgram> ancPatientPrograms = programWorkflowService.getPatientPrograms(patient, ancProgram, minEnrollmentDate.getTime(), null, null, null, false);
		if (ancPatientPrograms.size() > 0) {
			return true;
		}
		return false;
	}

	@Override
	public void enrollInANC(Patient patient, Date dateEnrolled) {
		PatientProgram patientProgram = new PatientProgram();
		patientProgram.setPatient(patient);
		Program ancProgram = programWorkflowService.getProgramByUuid(Context.getAdministrationService().getGlobalProperty(ANC_PROGRAM_UUID));
		patientProgram.setProgram(ancProgram);
		patientProgram.setDateEnrolled(dateEnrolled);
		//TODO Add creator 
		programWorkflowService.savePatientProgram(patientProgram);
	}

	@Override
	public boolean enrolledInPNC(Patient patient) {
		Program pncProgram = programWorkflowService.getProgramByUuid(Context.getAdministrationService().getGlobalProperty(PNC_PROGRAM_UUID));
		Calendar minEnrollmentDate = Calendar.getInstance();
		minEnrollmentDate.add(Calendar.MONTH, -MAX_PNC_DURATION);
		List<PatientProgram> pncPatientPrograms = programWorkflowService.getPatientPrograms(patient, pncProgram, minEnrollmentDate.getTime(), null, null, null, false);
		if (pncPatientPrograms.size() > 0) {
			return true;
		}
		return false;
	}

	@Override
	public void enrollInPNC(Patient patient, Date dateEnrolled) {
		PatientProgram patientProgram = new PatientProgram();
		patientProgram.setPatient(patient);
		Program pncProgram = programWorkflowService.getProgramByUuid(Context.getAdministrationService().getGlobalProperty(PNC_PROGRAM_UUID));
		patientProgram.setProgram(pncProgram);
		patientProgram.setDateEnrolled(dateEnrolled);
		//TODO Add creator 
		programWorkflowService.savePatientProgram(patientProgram);
	}
}
