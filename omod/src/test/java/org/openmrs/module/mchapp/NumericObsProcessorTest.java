package org.openmrs.module.mchapp;

import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.springframework.test.annotation.ExpectedException;

public class NumericObsProcessorTest extends BaseModuleContextSensitiveTest {

	@Test
	@ExpectedException(NumberFormatException.class)
	public void createObs_shouldThrowNumberFormatException() {
		Concept question = Context.getConceptService().getConceptByUuid("f4d0b584-6ce5-40e2-9ce5-fa7ec07b32b4");
		Patient patient = Context.getPatientService().getPatient(2);
		new NumericObsProcessor().createObs(question, new String[] { "number" }, patient);
	}

}
