package org.openmrs.module.mchapp;

import java.util.ArrayList;
import java.util.List;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class ObsParserTest extends BaseModuleContextSensitiveTest {

	@Rule
	public ExpectedException expectedException = ExpectedException.none();

	@Test
	public void parse_shouldReturnAListOfObsFromRequestParameter() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		
		List<Obs> observations = new ArrayList<Obs>();
		observations = ObsParser.parse(observations, patient, "concept.96408258-000b-424e-af1a-403919332938", new String[] { "Mix", "Wazito", "Mlima" });
		
		Assert.assertThat(observations.size(), Matchers.is(3));
	}
	
	@Test public void parse_shouldReturnEmptyListWhenRequestParamerDoesNotHaveConcept() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new ArrayList<Obs>();
		observations = ObsParser.parse(observations, patient, "some key", new String[] { "Some value" });

		Assert.assertThat(observations, Matchers.is(Matchers.empty()));
	}
	
	@Test
	public void parse_shouldThrowANullPointerExceptionWhenObsConceptIsNull() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new ArrayList<Obs>();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("concept with uuid: NONEXISTANTUUID is not defined.");
		observations = ObsParser.parse(observations, patient, "concept.NONEXISTANTUUID", new String[] { "Some value" });
	}

}
