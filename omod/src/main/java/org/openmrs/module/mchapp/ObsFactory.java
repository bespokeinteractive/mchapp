package org.openmrs.module.mchapp;

import org.openmrs.Concept;

public class ObsFactory {
	public static ObsProcessor getObsProcessor(Concept concept) {
		if (concept.getDatatype().isDateTime() || concept.getDatatype().isDate()) {
			return new DateTimeObsProcessor();
		} else if (concept.getDatatype().isCoded()) {
			return new CodedObsProcessor();
		} else if (concept.getDatatype().isNumeric()) {
			return new NumericObsProcessor();
		} else {
			return new TextObsProcessor();
		}
	}
}
