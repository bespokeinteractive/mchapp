package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsFactory;
import org.openmrs.module.mchapp.ObsProcessor;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

public class PostnatalTriageFragmentController {
	public void controller() {
		
	}
	
	@SuppressWarnings("unchecked")
	public SimpleObject savePostnatalTriageInformation(@RequestParam("patientId") Patient patient, PageRequest request) {
		List<Obs> observations = new ArrayList<Obs>();
		for (Map.Entry<String, String[]> postedParameter :
			((Map<String, String[]>)request.getRequest().getParameterMap()).entrySet()) {
			if (StringUtils.contains(postedParameter.getKey(), "concept.")) {
				String obsConceptUuid = postedParameter.getKey().substring("concept.".length());
				Concept obsConcept = Context.getConceptService().getConceptByUuid(obsConceptUuid);
				if (postedParameter.getValue().length > 0) {
					ObsProcessor obsProcessor = ObsFactory.getObsProcessor(obsConcept);
					try {
						observations.addAll(obsProcessor.createObs(obsConcept, postedParameter.getValue(), patient));
					} catch (Exception e) {
						return SimpleObject.create("status", "error", "message", e.getMessage());
					}
				}
			}
		}
		
		Context.getService(MchService.class).saveMchEncounter(patient, observations, MchMetadata._MchProgram.PNC_PROGRAM);
		
		return SimpleObject.create("status", "success", "message", "Triage information has been saved.");
	}
}
