package org.openmrs.module.mchapp;

import java.util.Calendar;
import java.util.Date;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class MchServiceTest extends BaseModuleContextSensitiveTest {

	@Before public void setup() throws Exception {
		executeDataSet("mch-programs.xml");
	}
	
	@Test public void enrolledInANC_shouldReturnFalseWhenPatientIsNotEnrolled() throws Exception {
		int patientId = 3;
		Patient patient = Context.getPatientService().getPatient(patientId);
		Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
	}

	
	@Test public void enrolledInANC_shouldReturnTrueWhenPatientIsEnrolled() throws Exception {
		int patientId = 2;
		Patient patient = Context.getPatientService().getPatient(patientId);
		PatientProgram ancPatientProgram = new PatientProgram();
		Calendar dateEnrolled = Calendar.getInstance();
		dateEnrolled.add(Calendar.MONTH, -6);
		ancPatientProgram.setPatient(patient);
		ancPatientProgram.setDateEnrolled(dateEnrolled.getTime());
		ancPatientProgram.setProgram(Context.getProgramWorkflowService().getProgram(1));
		Context.getProgramWorkflowService().savePatientProgram(ancPatientProgram);

		Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
	}
	
	@Test public void enrolledInANC_shouldReturnFalseWhenPatientEnrollmentDateIsMoreThan9MonthsAgo() throws Exception {
		int patientId = 2;
		Patient patient = Context.getPatientService().getPatient(patientId);
		PatientProgram ancPatientProgram = new PatientProgram();
		Calendar dateEnrolled = Calendar.getInstance();
		dateEnrolled.add(Calendar.MONTH, -10);
		ancPatientProgram.setPatient(patient);
		ancPatientProgram.setDateEnrolled(dateEnrolled.getTime());
		ancPatientProgram.setProgram(Context.getProgramWorkflowService().getProgram(1));
		Context.getProgramWorkflowService().savePatientProgram(ancPatientProgram);
		
		Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
	}

	@Test public void enroll_shouldEnrollPatientIntoANCProgram() {
		int patientId = 3;
		Patient patient = Context.getPatientService().getPatient(patientId);
		Context.getService(MchService.class).enrollInANC(patient, new Date());
		
		Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
	}
}
