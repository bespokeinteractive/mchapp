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
		observations = new ObsParser().parse(observations, patient, "concept.96408258-000b-424e-af1a-403919332938", new String[] { "Mix", "Wazito", "Mlima" });
		
		Assert.assertThat(observations.size(), Matchers.is(3));
	}
	
	@Test public void parse_shouldReturnEmptyListWhenRequestParamerDoesNotHaveConcept() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new ArrayList<Obs>();
		observations = new ObsParser().parse(observations, patient, "some key", new String[] { "Some value" });

		Assert.assertThat(observations, Matchers.is(Matchers.empty()));
	}
	
	@Test
	public void parse_shouldThrowANullPointerExceptionWhenObsConceptIsNull() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new ArrayList<Obs>();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("concept with uuid: NONEXISTANTUUID is not defined.");
		observations = new ObsParser().parse(observations, patient, "concept.NONEXISTANTUUID", new String[] { "Some value" });
	}

	@Test public void parse_shouldReturnAListOfObsWhenParameterHasTestOrder() throws Exception {
		executeDataSet("mch-concepts.xml");
		Patient patient = Context.getPatientService().getPatient(2);
		
		List<Obs> observations = new ArrayList<Obs>();
		observations = new ObsParser().parse(observations, patient, "test_order.122b36a4-9c07-4dfa-81ae-e6a4fe823077", new String[] { "17a83f95-49d9-473c-9aeb-c20c874fa5a1" });
		
		Assert.assertThat(observations.size(), Matchers.is(1));
	}
	
	@Test public void parse_shouldReturnAnObsWithCommentWhenParameterHasComment() throws Exception {
		Patient patient = Context.getPatientService().getPatient(2);
		
		List<Obs> observations = new ArrayList<Obs>();
		ObsParser obsParser = new ObsParser();
		observations = obsParser.parse(observations, patient, "comment.96408258-000b-424e-af1a-403919332938", new String[] { "Some comment" });
		Assert.assertThat(observations.size(), Matchers.is(0));
		
		observations = obsParser.parse(observations, patient, "concept.96408258-000b-424e-af1a-403919332938", new String[] { "Mix" });
		
		Assert.assertThat(observations.size(), Matchers.is(1));
		Assert.assertThat(observations.get(0).getValueText(), Matchers.equalTo("Mix"));
		Assert.assertThat(observations.get(0).getComment(), Matchers.equalTo("Some comment"));
	}
}
