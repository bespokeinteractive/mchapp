package org.openmrs.module.mchapp.api.parsers;

import java.util.Date;

import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Encounter;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.openmrs.module.hospitalcore.model.OpdPatientQueueLog;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.hospitalcore.model.TriagePatientQueueLog;
import org.openmrs.module.mchapp.api.parsers.QueueLogs;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class QueueLogsTest extends BaseModuleContextSensitiveTest {
	@Test
	public void logTriagePatient_shouldLogTriagePatientQueueDataAndClearQueue() throws Exception {
		executeDataSet("mch-concepts.xml");
		Patient patient = Context.getPatientService().getPatient(2);
		PatientQueueService queueService = Context.getService(PatientQueueService.class);
		TriagePatientQueue patientQueue = queueService.getTriagePatientQueueById(14);
		Encounter encounter = new Encounter();
		encounter.setLocation(Context.getLocationService().getLocation(1));
		encounter.setEncounterType(Context.getEncounterService().getEncounterType(1));
		encounter.setEncounterDatetime(new Date());
		encounter.setPatient(patient);
		encounter.addProvider(Context.getEncounterService().getEncounterRole(1), Context.getProviderService().getProvider(1));
		Context.getEncounterService().saveEncounter(encounter);
		
		TriagePatientQueueLog queueLog = QueueLogs.logTriagePatient(patientQueue, encounter);
		patientQueue = queueService.getTriagePatientQueueById(14);
		
		Assert.assertNotNull(queueLog);
		Assert.assertNull(patientQueue);
	}
	
	@Test
	public void logOpdPatient_shouldLogOpdPatientQueueDataAndClearQueue() throws Exception {
		executeDataSet("mch-concepts.xml");
		Patient patient = Context.getPatientService().getPatient(2);
		PatientQueueService queueService = Context.getService(PatientQueueService.class);
		OpdPatientQueue patientQueue = queueService.getOpdPatientQueueById(14);
		Encounter encounter = new Encounter();
		encounter.setLocation(Context.getLocationService().getLocation(1));
		encounter.setEncounterType(Context.getEncounterService().getEncounterType(1));
		encounter.setEncounterDatetime(new Date());
		encounter.setPatient(patient);
		encounter.addProvider(Context.getEncounterService().getEncounterRole(1), Context.getProviderService().getProvider(1));
		Context.getEncounterService().saveEncounter(encounter);
		
		OpdPatientQueueLog queueLog = QueueLogs.logOpdPatient(patientQueue, encounter);
		patientQueue = queueService.getOpdPatientQueueById(14);
		
		Assert.assertNotNull(queueLog);
		Assert.assertNull(patientQueue);
	}
}
