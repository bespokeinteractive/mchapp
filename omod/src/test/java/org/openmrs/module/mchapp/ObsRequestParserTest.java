package org.openmrs.module.mchapp;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class ObsRequestParserTest extends BaseModuleContextSensitiveTest {

	@Test
	public void parseRequest_shouldReturnAListOfObsFromRequestParameter() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		
		List<Obs> observations = new ArrayList<Obs>();
		observations = ObsRequestParser.parseRequestParameter(observations, patient, "concept.96408258-000b-424e-af1a-403919332938", new String[] { "Mix", "Wazito", "Mlima" });
		
		Assert.assertThat(observations.size(), Matchers.is(3));
	}
	
	@Test public void parseRequest_shouldReturnEmptyListWhenRequestParamerDoesNotHaveConcept() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new ArrayList<Obs>();
		observations = ObsRequestParser.parseRequestParameter(observations, patient, "some key", new String[] { "Some value" });

		Assert.assertThat(observations, Matchers.is(Matchers.empty()));
	}

}
