package org.openmrs.module.mchapp.api.parsers;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by qqnarf on 4/28/16.
 */
public class ObsParser {
    private Map<String, String> unprocessedComments = new HashMap<String, String>();

    public List<Obs> parse(List<Obs> observations, Patient patient, String parameterKey, String[] parameterValues) throws NullPointerException, ParseException
    {
        if (observations == null) {
            observations = new ArrayList<Obs>();
        }
        if (StringUtils.contains(parameterKey, "concept.")
                || StringUtils.contains(parameterKey, "test_order")) {
            String obsConceptUuid;
            if (StringUtils.contains(parameterKey, "concept.")) {
                obsConceptUuid = parameterKey.substring("concept.".length());
            } else {
                obsConceptUuid = parameterKey.substring("test_order.".length());
            }
            Concept obsConcept = Context.getConceptService().getConceptByUuid(obsConceptUuid);
            if (obsConcept ==  null) {
                throw new NullPointerException("concept with uuid: " + obsConceptUuid + " is not defined.");
            }
            if (parameterValues.length > 0) {
                ObsProcessor obsProcessor = ObsFactory.getObsProcessor(obsConcept);
                List<Obs> obs = obsProcessor.createObs(obsConcept, parameterValues, patient);
                for (Obs ob : obs) {
                    if (unprocessedComments.containsKey(ob.getConcept().getUuid())) {
                        ob.setComment(unprocessedComments.get(ob.getConcept().getUuid()));
                        unprocessedComments.remove(ob.getConcept().getUuid());
                    }
                }
                observations.addAll(obs);
            }
        }

        if (StringUtils.contains(parameterKey, "comment")) {
            Boolean commentProcessed = false;
            String obsConceptUuid = parameterKey.substring("concept.".length());
            for (Obs obs : observations) {
                if (StringUtils.equalsIgnoreCase(obs.getConcept().getUuid(), obsConceptUuid)) {
                    obs.setComment(parameterValues[0]);
                    commentProcessed = false;
                }
            }
            
            if (!commentProcessed) {
                unprocessedComments.put(obsConceptUuid, parameterValues[0]);
            }
        }

        return observations;
    }
}
