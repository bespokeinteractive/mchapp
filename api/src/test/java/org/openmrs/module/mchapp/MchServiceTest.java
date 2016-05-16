package org.openmrs.module.mchapp;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata._MchProgram;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.openmrs.ui.framework.SimpleObject;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;

public class MchServiceTest extends BaseModuleContextSensitiveTest {

    @Autowired
    MchMetadata mchMetadata;


    @Before
    public void setup() throws Exception {
        executeDataSet("mch-programs.xml");
        mchMetadata.install();
    }

    @Test
    public void enrolledInANC_shouldReturnFalseWhenPatientIsNotEnrolled() throws Exception {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
    }

    @Test
    public void enrolledInPNC_shouldReturnFalseWhenPatientIsNotEnrolled() throws Exception {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInPNC(patient));
    }

    @Test
    public void enrolledInANC_shouldReturnTrueWhenPatientIsRecentlyEnrolledInANC() throws Exception {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        PatientProgram ancPatientProgram = new PatientProgram();
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.MONTH, -6);
        ancPatientProgram.setPatient(patient);
        ancPatientProgram.setDateEnrolled(dateEnrolled.getTime());
        ancPatientProgram.setProgram(Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM));
        Context.getProgramWorkflowService().savePatientProgram(ancPatientProgram);
        Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
    }

    @Test
    public void enrolledInPNC_shouldReturnTrueWhenPatientIsRecentlyEnrolledInPNC() throws Exception {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        PatientProgram pncPatientProgram = new PatientProgram();
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.MONTH, -3);
        pncPatientProgram.setPatient(patient);
        pncPatientProgram.setDateEnrolled(dateEnrolled.getTime());
        pncPatientProgram.setProgram(Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM));
        Context.getProgramWorkflowService().savePatientProgram(pncPatientProgram);
        Assert.assertTrue(Context.getService(MchService.class).enrolledInPNC(patient));
    }

    @Test
    public void enrolledInCWC_shouldReturnFalseWhenPatientIsNotEnrolledInCWC() throws Exception {
        int patientId = 4;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
    }

    @Test
    public void enrolledInCWC_shouldReturnTrueWhenPatientIsRecentlyEnrolledInCWC() throws Exception {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        PatientProgram cwcPatientProgram = new PatientProgram();
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.YEAR, -3);
        cwcPatientProgram.setPatient(patient);
        cwcPatientProgram.setDateEnrolled(dateEnrolled.getTime());
        cwcPatientProgram.setProgram(Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM));
        Context.getProgramWorkflowService().savePatientProgram(cwcPatientProgram);
        Assert.assertTrue(Context.getService(MchService.class).enrolledInCWC(patient));
    }

    @Test
    public void enrolledInCWC_shouldReturnFalseWhenPatientEnrollmentDateIsMoreThan5YearsAgo() throws Exception {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        PatientProgram cwcPatientProgram = new PatientProgram();
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.YEAR, -6);
        cwcPatientProgram.setPatient(patient);
        cwcPatientProgram.setDateEnrolled(dateEnrolled.getTime());
        cwcPatientProgram.setProgram(Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM));
        Context.getProgramWorkflowService().savePatientProgram(cwcPatientProgram);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
    }

    @Test
    public void enroll_shouldEnrollPatientIntoCWCCProgram() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
//        TODO Change map of initial states once loaded as concepts in DB
//        SimpleObject simpleObject = Context.getService(MchService.class).enrollInCWC(patient, new Date(),_MchProgram.CWC_BCG_WORKFLOW_STATE);
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInCWC(patient, new Date(), new HashMap<String, String>());
        Assert.assertEquals(simpleObject.get("status"), "success");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInCWC(patient));
    }

    @Test
    public void enroll_shouldNotEnrollPatientIntoCWCProgramWhenAlreadyEnrolled() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
        //        TODO Change map of initial states once loaded as concepts in DB
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInCWC(patient, new Date(), new HashMap<String, String>());
        Assert.assertEquals(simpleObject.get("status"), "success");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInCWC(patient));
        //re-enroll the patient within the same period
        SimpleObject simpleObject1 = Context.getService(MchService.class).enrollInCWC(patient, new Date(), new HashMap<String, String>());
        Assert.assertEquals(simpleObject1.get("status"), "error");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInCWC(patient));
    }

    @Test
    public void enroll_shouldReturnErrorWhenPatientAlreadyEnrolledIntoCWCProgramWithinTimePeriod() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
//        TODO Change map of initial states once loaded as concepts in DB
        Context.getService(MchService.class).enrollInCWC(patient, new Date(), new HashMap<String, String>());
        Assert.assertTrue(Context.getService(MchService.class).enrolledInCWC(patient));
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInCWC(patient, new Date(), new HashMap<String, String>());
        Assert.assertEquals(simpleObject.get("status"), "error");
    }

    @Test
    public void enrolledInANC_shouldReturnFalseWhenPatientEnrollmentDateIsMoreThan9MonthsAgo() throws Exception {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        PatientProgram ancPatientProgram = new PatientProgram();
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.MONTH, -10);
        ancPatientProgram.setPatient(patient);
        ancPatientProgram.setDateEnrolled(dateEnrolled.getTime());
        ancPatientProgram.setProgram(Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM));
        Context.getProgramWorkflowService().savePatientProgram(ancPatientProgram);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
    }

    @Test
    public void enrolledInPNC_shouldReturnFalseWhenPatientHasNotBeenRecentlyEnrolledInPNC() throws Exception {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        PatientProgram pncPatientProgram = new PatientProgram();
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.MONTH, -12);
        pncPatientProgram.setPatient(patient);
        pncPatientProgram.setDateEnrolled(dateEnrolled.getTime());
        pncPatientProgram.setProgram(Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM));
        Context.getProgramWorkflowService().savePatientProgram(pncPatientProgram);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInPNC(patient));
    }

    @Test
    public void enroll_shouldEnrollPatientIntoANCProgram() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInANC(patient, new Date());
        Assert.assertEquals(simpleObject.get("status"), "success");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
    }

    @Test
    public void enroll_shouldNotEnrollPatientIntoANCProgramWhenAlreadyEnrolled() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInANC(patient, new Date());
        Assert.assertEquals(simpleObject.get("status"), "success");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
        //re-enroll the patient within the same period
        SimpleObject simpleObject1 = Context.getService(MchService.class).enrollInANC(patient, new Date());
        Assert.assertEquals(simpleObject1.get("status"), "error");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
    }

    @Test
    public void enroll_shouldReturnErrorWhenPatientAlreadyEnrolledIntoANCProgramWithinTimePeriod() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInANC(patient));
        Context.getService(MchService.class).enrollInANC(patient, new Date());
        Assert.assertTrue(Context.getService(MchService.class).enrolledInANC(patient));
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInANC(patient, new Date());
        Assert.assertEquals(simpleObject.get("status"), "error");
    }

    @Test
    public void enroll_shouldEnrollPatientIntoPNCProgram() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInPNC(patient));
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInPNC(patient, new Date());
        Assert.assertEquals(simpleObject.get("status"), "success");
        Assert.assertTrue(Context.getService(MchService.class).enrolledInPNC(patient));
    }

    @Test
    public void enroll_shouldReturnErrorWhenPatientAlreadyEnrolledIntoPNCProgramWithinTimePeriod() {
        int patientId = 3;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInPNC(patient));
        Context.getService(MchService.class).enrollInPNC(patient, new Date());
        Assert.assertTrue(Context.getService(MchService.class).enrolledInPNC(patient));
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInPNC(patient, new Date());
        Assert.assertEquals(simpleObject.get("status"), "error");
    }

    @Test
    public void mchProgramsShouldBeInstalled() {
        Assert.assertNotNull(Context.getProgramWorkflowService().getProgramByUuid(_MchProgram.ANC_PROGRAM));
        Assert.assertNotNull(Context.getProgramWorkflowService().getProgramByUuid(_MchProgram.PNC_PROGRAM));
        Assert.assertNotNull(Context.getProgramWorkflowService().getProgramByUuid(_MchProgram.CWC_PROGRAM));
    }

    @Test
    public void saveMchEncounter_shouldSaveANCEncounter() {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Concept ultrasoundDone = Context.getConceptService().getConcept(1744);
        Concept yes = Context.getConceptService().getConcept(7);
        Obs ancObs = new Obs();
        ancObs.setConcept(ultrasoundDone);
        ancObs.setValueCoded(yes);
        ancObs.setObsDatetime(new Date());
        ancObs.setCreator(Context.getAuthenticatedUser());
        Encounter encounter = Context.getService(MchService.class).saveMchEncounter(patient, Arrays.asList(ancObs), MchMetadata._MchProgram.ANC_PROGRAM);
        Assert.assertNotNull(encounter.getId());
        Assert.assertEquals(1, encounter.getAllObs().size());
        Assert.assertEquals(MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE, encounter.getEncounterType().getUuid());
    }

    @Test
    public void saveMchEncounter_shouldSavePNCEncounter() {

    }
}
