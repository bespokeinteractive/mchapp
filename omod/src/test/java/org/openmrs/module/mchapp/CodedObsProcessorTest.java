package org.openmrs.module.mchapp;

import java.util.List;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class CodedObsProcessorTest extends BaseModuleContextSensitiveTest{

	@Test
	public void createObs_shouldSkipConceptIfValueIsZero() {
		Concept codedConceptQuestion = Context.getConceptService().getConcept(4);
		Patient patient = Context.getPatientService().getPatient(2);
		String[] paramValue = new String[] { "0" };
		List<Obs> obs = new CodedObsProcessor().createObs(codedConceptQuestion, paramValue, patient);
		
		Assert.assertThat(obs.size(), Matchers.equalTo(0));
	}

	@Test
	public void createObs_shouldSkipConceptIfValueIsEmpty() {
		Concept codedConceptQuestion = Context.getConceptService().getConcept(4);
		Patient patient = Context.getPatientService().getPatient(2);
		String[] paramValue = new String[] { "" };
		List<Obs> obs = new CodedObsProcessor().createObs(codedConceptQuestion, paramValue, patient);
		
		Assert.assertThat(obs.size(), Matchers.equalTo(0));
	}

}
