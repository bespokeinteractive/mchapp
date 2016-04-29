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

public class ObsProcessorTest extends BaseModuleContextSensitiveTest {

	@Test
	public void createObs_shouldReturnASingleObsWhenOnlyASingleValueIsSubmitted() {
		Concept question = Context.getConceptService().getConceptByUuid("89ca642a-dab6-4f20-b712-e12ca4fc6d36");
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new CodedObsProcessor().createObs(question, new String[] { "32d3611a-6699-4d52-823f-b4b788bac3e3" }, patient);
		
		Assert.assertThat(observations.size(), Matchers.is(1));
	}
	
	@Test
	public void createObs_shouldReturnMultipleObsWhenMultipleValuesAreSubmitted() {
		Concept question = Context.getConceptService().getConceptByUuid("96408258-000b-424e-af1a-403919332938");
		Patient patient = Context.getPatientService().getPatient(2);
		List<Obs> observations = new TextObsProcessor().createObs(question, new String[] { "Mix", "Wazito", "Mlima" }, patient);
		
		Assert.assertThat(observations.size(), Matchers.is(3));
	}

}
