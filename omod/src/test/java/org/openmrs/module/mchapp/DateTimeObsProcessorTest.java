package org.openmrs.module.mchapp;

import java.text.ParseException;

import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.springframework.test.annotation.ExpectedException;

public class DateTimeObsProcessorTest extends BaseModuleContextSensitiveTest {

	@Test
	@ExpectedException(ParseException.class)
	public void createObs_shouldThrowParseExceptionWhenDateIsWronglyFormatted() throws Exception {
		Concept question = Context.getConceptService().getConceptByUuid("11716f9c-1434-4f8d-b9fc-9aa14c4d6126");
		Patient patient = Context.getPatientService().getPatient(2);
		new DateTimeObsProcessor().createObs(question, new String[] {"2016/23/6"}, patient);
	}

}
