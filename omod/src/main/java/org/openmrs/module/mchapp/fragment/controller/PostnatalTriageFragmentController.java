package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsRequestParser;
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
		try {
			observations.addAll(ObsRequestParser.parseRequest(patient, ((Map<String, String[]>)request.getRequest().getParameterMap())));
		} catch (Exception e) {
			return SimpleObject.create("status", "fail", "message", e.getMessage());
		}
		
		Context.getService(MchService.class).saveMchEncounter(patient, observations, MchMetadata._MchProgram.PNC_PROGRAM);
		
		return SimpleObject.create("status", "success", "message", "Triage information has been saved.");
	}
}
