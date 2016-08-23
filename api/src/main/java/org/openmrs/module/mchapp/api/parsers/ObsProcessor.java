package org.openmrs.module.mchapp.api.parsers;

import java.text.ParseException;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;

public interface ObsProcessor {
	List<Obs> createObs(Concept question, String[] answers, Patient patient) throws NullPointerException, ParseException;
}
