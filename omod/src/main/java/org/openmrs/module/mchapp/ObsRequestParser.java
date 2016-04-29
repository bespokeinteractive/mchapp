package org.openmrs.module.mchapp;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by qqnarf on 4/28/16.
 */
public class ObsRequestParser {
    public static List<Obs> parseRequest(Patient patient, Map<String, String[]> postedParameters) throws Exception
    {
        List<Obs> observations = new ArrayList<Obs>();

        for (Map.Entry<String, String[]> postedParameter :
                (postedParameters.entrySet())) {
            if (StringUtils.contains(postedParameter.getKey(), "concept.")) {
                String obsConceptUuid = postedParameter.getKey().substring("concept.".length());
                Concept obsConcept = Context.getConceptService().getConceptByUuid(obsConceptUuid);
                if (postedParameter.getValue().length > 0) {
                    ObsProcessor obsProcessor = ObsFactory.getObsProcessor(obsConcept);
                    observations.addAll(obsProcessor.createObs(obsConcept, postedParameter.getValue(), patient));
                }
            }
        }

        return observations;
    }
}
