package org.openmrs.module.mchapp;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.is;

import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;
import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.Location;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.model.DepartmentConcept;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugFormulation;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.MchMetadata._MchProgram;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.openmrs.ui.framework.SimpleObject;
import org.springframework.beans.factory.annotation.Autowired;

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
    public void enroll_shouldReturnErrorWhenPatientToEnrollIntoCWCProgramIsOlderThanFiveYears() {
        int patientId = 2;
        Patient patient = Context.getPatientService().getPatient(patientId);
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
//        TODO Change map of initial states once loaded as concepts in DB
        SimpleObject simpleObject = Context.getService(MchService.class).enrollInCWC(patient, new Date(), new HashMap<String, String>());
        Assert.assertFalse(Context.getService(MchService.class).enrolledInCWC(patient));
        Assert.assertEquals(simpleObject.get("status"), "error");
        Assert.assertEquals(simpleObject.get("message"), "CWC only allowed for Child under 5 Years");
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
        Obs ancObs = generateObs(ultrasoundDone, yes);
        OpdDrugOrder drugOrder = generateDrugOrder();
        OpdTestOrder testOrder = generateTestOrder(patient);
        ClinicalForm form = Mockito.mock(ClinicalForm.class);
        Mockito.when(form.getObservations()).thenReturn(Arrays.asList(ancObs));
        Mockito.when(form.getDrugOrders()).thenReturn(Arrays.asList(drugOrder));
        Mockito.when(form.getTestOrders()).thenReturn(Arrays.asList(testOrder));
        Mockito.when(form.getPatient()).thenReturn(patient);
        Location location = Context.getLocationService().getLocation(1);

        Assert.assertNull(drugOrder.getOpdDrugOrderId());
        Encounter encounter = Context.getService(MchService.class)
                .saveMchEncounter(form,  MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE, location);

        Assert.assertNotNull(encounter.getId());
        Assert.assertThat(encounter.getLocation(), equalTo(location));
        Assert.assertThat(encounter.getAllObs().size(), is(1));
        Assert.assertThat(encounter.getEncounterType().getUuid(), is(MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE));
        Assert.assertNotNull(drugOrder.getOpdDrugOrderId());
        Assert.assertThat(drugOrder.getEncounter(), equalTo(encounter));
        Assert.assertNotNull(testOrder.getOpdOrderId());
        Assert.assertThat(testOrder.getEncounter(), equalTo(encounter));
    }

	private OpdTestOrder generateTestOrder(Patient patient) {
		Concept investigationQuestionConcept = Context.getConceptService()
				.getConcept(9999);
		Concept investigationConcept = Context.getConceptService().getConcept(
				9996);
		OpdTestOrder testOrder = new OpdTestOrder();
		BillableService billableService = Context.getService(
				BillingService.class).getServiceByConceptId(
				investigationConcept.getConceptId());
		testOrder.setPatient(patient);
		testOrder.setConcept(investigationQuestionConcept);
		testOrder.setTypeConcept(DepartmentConcept.TYPES[2]);
		testOrder.setValueCoded(investigationConcept);
		testOrder.setBillableService(billableService);
		testOrder.setFromDept("MCH Clinic");
		testOrder.setCreator(Context.getAuthenticatedUser());
		testOrder.setCreatedOn(new Date());
		return testOrder;
	}

	private Obs generateObs(Concept question, Concept answer) {
		Obs ancObs = new Obs();
        ancObs.setConcept(question);
        ancObs.setValueCoded(answer);
        ancObs.setObsDatetime(new Date());
        ancObs.setCreator(Context.getAuthenticatedUser());
		return ancObs;
	}

	private OpdDrugOrder generateDrugOrder() {
		OpdDrugOrder drugOrder = new OpdDrugOrder();
        InventoryDrug drug = Context.getService(InventoryService.class).getDrugById(1);
        drugOrder.setInventoryDrug(drug);
        InventoryDrugFormulation formulation = Context.getService(InventoryService.class).getDrugFormulationById(1);
        drugOrder.setInventoryDrugFormulation(formulation);
        drugOrder.setCreatedOn(new Date());
        drugOrder.setReferralWardName("Ward A");
		return drugOrder;
	}

    @Test
    public void getPatientProfile_shouldGetProfileForCurrentProgram() {
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.MONTH, -1);
        Patient patient = Context.getPatientService().getPatient(2);
        MchService mchService = Context.getService(MchService.class);
        mchService.enrollInANC(patient, dateEnrolled.getTime());

        Concept parity = Context.getConceptService().getConcept(1745);
        Concept gravida = Context.getConceptService().getConcept(1746);
        Concept lmp = Context.getConceptService().getConcept(1747);
        Encounter encounter = generateEncounter(patient, dateEnrolled);
        Obs parityObs = generateObs(patient, parity, 2D, dateEnrolled.getTime());
        encounter.addObs(parityObs);
        Obs gravidaObs = generateObs(patient, gravida, 1D, dateEnrolled.getTime());
        encounter.addObs(gravidaObs);
        Calendar lmpDate = Calendar.getInstance();
        lmpDate.add(Calendar.MONTH, -2);
        Obs lmpObs = generateObs(patient, lmp, lmpDate.getTime(), dateEnrolled.getTime());
        encounter.addObs(lmpObs);
        Context.getEncounterService().saveEncounter(encounter);

        List<Obs> profile = mchService.getPatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM);

        Assert.assertThat(profile.size(), is(3));
    }

    @Test
    public void getPatientProfile_shouldReturnMostCurrentProfileForCurrentProgram() {
        Calendar dateEnrolled = Calendar.getInstance();
        dateEnrolled.add(Calendar.MONTH, -1);
        Patient patient = Context.getPatientService().getPatient(2);
        MchService mchService = Context.getService(MchService.class);
        mchService.enrollInANC(patient, dateEnrolled.getTime());

        Concept parity = Context.getConceptService().getConcept(1745);
        Concept gravida = Context.getConceptService().getConcept(1746);
        Concept lmp = Context.getConceptService().getConcept(1747);
        Calendar latestObsDate = Calendar.getInstance();
        latestObsDate.add(Calendar.DATE, -7);
        Encounter firstEncounter = generateEncounter(patient, dateEnrolled);
        Obs oldParityObs = generateObs(patient, parity, 2D, dateEnrolled.getTime());
        firstEncounter.addObs(oldParityObs);
        Obs gravidaObs = generateObs(patient, gravida, 1D, dateEnrolled.getTime());
        firstEncounter.addObs(gravidaObs);
        Calendar lmpDate = Calendar.getInstance();
        lmpDate.add(Calendar.MONTH, -2);
        Obs lmpObs = generateObs(patient, lmp, lmpDate.getTime(), dateEnrolled.getTime());
        firstEncounter.addObs(lmpObs);
        Context.getEncounterService().saveEncounter(firstEncounter);

        Encounter secondEncounter = generateEncounter(patient, latestObsDate);
        Obs updatedParityObs = generateObs(patient, parity, 3D, latestObsDate.getTime());
        secondEncounter.addObs(updatedParityObs);
        Obs updatedGravidaObs = generateObs(patient, gravida, 2D, latestObsDate.getTime());
        secondEncounter.addObs(updatedGravidaObs);
        Calendar updatedLmpDate = Calendar.getInstance();
        updatedLmpDate.add(Calendar.MONTH, -1);
        Obs updatedLmpObs = generateObs(patient, lmp, updatedLmpDate.getTime(), latestObsDate.getTime());
        secondEncounter.addObs(updatedLmpObs);
        Context.getEncounterService().saveEncounter(secondEncounter);

        List<Obs> profile = mchService.getPatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM);

        Assert.assertThat(profile.size(), is(3));
        Assert.assertThat(profile, Matchers.containsInAnyOrder(updatedParityObs, updatedGravidaObs, updatedLmpObs));
    }

    private Obs generateObs(Patient patient, Concept question,
            Object obsValue, Date obsDatetime) {
        Obs obs = new Obs();
        obs.setConcept(question);
        if (question.isNumeric()) {
            obs.setValueNumeric((Double)obsValue);
        } else if (question.getDatatype().isDateTime() || question.getDatatype().isDate()) {
            obs.setValueDatetime((Date)obsValue);
        }
        obs.setPerson(patient);
        obs.setObsDatetime(obsDatetime);
        return obs;
    }

	private Encounter generateEncounter(Patient patient, Calendar encounterDate) {
		Encounter encounter = new Encounter();
        encounter.setLocation(Context.getLocationService().getLocation(1));
        encounter.setEncounterType(Context.getEncounterService().getEncounterType(1));
        encounter.setEncounterDatetime(encounterDate.getTime());
        encounter.setPatient(patient);
        encounter.addProvider(Context.getEncounterService().getEncounterRole(1), Context.getProviderService().getProvider(1));
		return encounter;
	}
}
