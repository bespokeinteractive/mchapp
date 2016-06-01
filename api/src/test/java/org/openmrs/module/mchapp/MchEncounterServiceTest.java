package org.openmrs.module.mchapp;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.Matchers.equalTo;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchEncounterService;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.springframework.beans.factory.annotation.Autowired;

public class MchEncounterServiceTest extends BaseModuleContextSensitiveTest {

	@Autowired
	MchMetadata mchMetadata;

	@Test public void getConditions_shouldReturnMostRecentConditions() throws Exception {
		executeDataSet("mch-programs.xml");
		mchMetadata.install();
		Patient patient = Context.getPatientService().getPatient(2);
		Calendar date = Calendar.getInstance();
		date.add(Calendar.MONTH, -1);
		Context.getService(MchService.class).enrollInPNC(patient, date.getTime());
		
		Concept diagnosis = Context.getConceptService().getConcept(10000);
		Concept onTreatmentStatus = Context.getConceptService().getConcept(10003);
		
		Concept malaria = Context.getConceptService().getConcept(10004);
		Concept malariaTreatmentStatus = Context.getConceptService().getConcept(10005);
		Obs malariaDiagnosisObs = generateObs(patient, diagnosis, malaria, date.getTime());
		Obs malariaTreatmentStatusObs = generateObs(patient, malariaTreatmentStatus, onTreatmentStatus, date.getTime());
		Encounter malariaDiagnosisEncounter = generateEncounter(patient, date.getTime());
		malariaDiagnosisEncounter.addObs(malariaDiagnosisObs);
		malariaDiagnosisEncounter.addObs(malariaTreatmentStatusObs);
		Context.getEncounterService().saveEncounter(malariaDiagnosisEncounter);
		
		date.add(Calendar.MONTH, 1);
		Concept diabetes = Context.getConceptService().getConcept(10001);
		Obs diabetesObs = generateObs(patient, diagnosis, diabetes, date.getTime());
		Concept diabetesTreatmentStatus = Context.getConceptService().getConcept(10002);
		Obs treatmentStatusObs = generateObs(patient, diabetesTreatmentStatus, onTreatmentStatus, date.getTime());
		Encounter diabetesDiagnosisEncounter = generateEncounter(patient, date.getTime());
		diabetesDiagnosisEncounter.addObs(diabetesObs);
		diabetesDiagnosisEncounter.addObs(treatmentStatusObs);
		Context.getEncounterService().saveEncounter(diabetesDiagnosisEncounter);
		
		List<String> conditions = Context.getService(MchEncounterService.class).getConditions(patient);
		
		Assert.assertThat(conditions.size(), equalTo(1));
		Assert.assertThat(conditions, contains(diabetes.getUuid()));
	}

	private Obs generateObs(Patient patient, Concept question, Object obsValue,
			Date obsDatetime) {
		Obs obs = new Obs();
		obs.setConcept(question);
		if (question.isNumeric()) {
			obs.setValueNumeric((Double) obsValue);
		} else if (question.getDatatype().isDateTime()
				|| question.getDatatype().isDate()) {
			obs.setValueDatetime((Date) obsValue);
		} else if (question.getDatatype().isCoded()) {
			obs.setValueCoded((Concept) obsValue);
		}
		obs.setPerson(patient);
		obs.setObsDatetime(obsDatetime);
		return obs;
	}

	private Encounter generateEncounter(Patient patient, Date encounterDate) {
		Encounter encounter = new Encounter();
		encounter.setLocation(Context.getLocationService().getLocation(1));
		encounter.setEncounterType(Context.getEncounterService()
				.getEncounterType(1));
		encounter.setEncounterDatetime(encounterDate);
		encounter.setPatient(patient);
		encounter.addProvider(
				Context.getEncounterService().getEncounterRole(1), Context
						.getProviderService().getProvider(1));
		return encounter;
	}
}
