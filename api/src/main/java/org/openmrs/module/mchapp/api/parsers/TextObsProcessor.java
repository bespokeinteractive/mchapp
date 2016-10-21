package org.openmrs.module.mchapp.api.parsers;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;

public class TextObsProcessor implements ObsProcessor {

	@Override
	public List<Obs> createObs(Concept question, String[] answers, Patient patient) {
		List<Obs> observations = new ArrayList<Obs>();
		for (int i = 0; i < answers.length; i++) {
			Obs obs = new Obs();
			obs.setConcept(question);
			obs.setValueText(answers[i]);
			obs.setPerson(patient);
			obs.setObsDatetime(new Date());
			observations.add(obs);
		}
		return observations;
	}

}
