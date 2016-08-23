package org.openmrs.module.mchapp;

import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Obs;
import org.openmrs.module.mchapp.api.parsers.ObsDatetimeUpdater;

public class ObsDatetimeUpdaterTest {

	@Test public void updateDatetime_shouldUpdateAllObsWithSpecifiedDate() {
		Calendar obsDatetime = Calendar.getInstance();
		obsDatetime.add(Calendar.MONTH, -1);
		List<Obs> observations = Arrays.asList(new Obs(),new Obs());
		
		List<Obs> updatedObservations = ObsDatetimeUpdater.updateDatetime(observations, obsDatetime.getTime());
		
		Assert.assertThat(updatedObservations.size(), Matchers.equalTo(2));
		Assert.assertThat(updatedObservations, Matchers.everyItem(Matchers.<Obs>hasProperty("obsDatetime", Matchers.equalTo(obsDatetime.getTime()))));
	}
}
