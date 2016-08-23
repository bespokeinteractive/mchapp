package org.openmrs.module.mchapp.api.parsers;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.openmrs.Obs;

public class ObsDatetimeUpdater {
	public static List<Obs> updateDatetime(List<Obs> observationsToUpdate, Date obsDatetime) {
		List<Obs> updatedObservations = new ArrayList<Obs>();
		for (Obs observation : observationsToUpdate) {
			observation.setObsDatetime(obsDatetime);
			updatedObservations.add(observation);
		}
		return updatedObservations;
	}
}
