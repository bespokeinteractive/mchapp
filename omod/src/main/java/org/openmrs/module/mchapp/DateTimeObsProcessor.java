package org.openmrs.module.mchapp;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;

public class DateTimeObsProcessor implements ObsProcessor {

	@Override
	public List<Obs> createObs(Concept question, String[] answers, Patient patient) throws Exception {
		List<Obs> observations = new ArrayList<Obs>();
		for (int i = 0; i < answers.length; i++) {
			Obs obs = new Obs();
			obs.setConcept(question);
			SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
			dateFormatter.setLenient(false);
			Date valueDate = dateFormatter.parse(answers[i]);
			obs.setValueDatetime(valueDate);
			obs.setPerson(patient);
			obs.setObsDatetime(new Date());
			observations.add(obs);
		}
		return observations;
	}

}
