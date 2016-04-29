package org.openmrs.module.mchapp;

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
	public void parseRequest_shouldReturnAListOfObsFromRequest() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		Map<String,String[]> requestParameters = new HashMap<String,String[]>();
		requestParameters.put("concept.89ca642a-dab6-4f20-b712-e12ca4fc6d36", new String[] { "32d3611a-6699-4d52-823f-b4b788bac3e3" });
		requestParameters.put("concept.11716f9c-1434-4f8d-b9fc-9aa14c4d6126", new String[] { "29/04/2016" });
		requestParameters.put("concept.96408258-000b-424e-af1a-403919332938", new String[] { "Mix", "Wazito", "Mlima" });
		
		List<Obs> observations = ObsRequestParser.parseRequest(patient, requestParameters);
		
		Assert.assertThat(observations.size(), Matchers.is(5));
	}
	
	@Test public void parseRequest_shouldReturnEmptyListWhenRequestParamersDoNotHaveConcepts() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		Map<String,String[]> requestParameters = new HashMap<String,String[]>();
		requestParameters.put("some key", new String[] { "Some value" });
		
		List<Obs> observations = ObsRequestParser.parseRequest(patient, requestParameters);

		Assert.assertThat(observations, Matchers.is(Matchers.empty()));
	}

}
