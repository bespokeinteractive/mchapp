package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.QueueLogs;
import org.openmrs.module.mchapp.SendForExaminationParser;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;

import java.util.*;

public class PostnatalTriageFragmentController {
	public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui) {
		config.require("patientId");
		config.require("queueId");
		Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));

        Concept modeOfDelivery = Context.getConceptService().getConceptByUuid(MchMetadata._MchProgram.PNC_DELIVERY_MODES);
        		List<SimpleObject> modesOfDelivery = new ArrayList<SimpleObject>();
        		for (ConceptAnswer answer : modeOfDelivery.getAnswers()) {
            			modesOfDelivery.add(SimpleObject.create("uuid", answer.getAnswerConcept().getUuid(), "label", answer.getAnswerConcept().getDisplayString()));
            		}

		model.addAttribute("patient", patient);
		model.addAttribute("patientProfile", PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.PNC_PROGRAM));
		model.addAttribute("queueId", config.get("queueId"));
        model.addAttribute("deliveryMode", modesOfDelivery);
	}
	
	@SuppressWarnings("unchecked")
	public SimpleObject savePostnatalTriageInformation(
			@RequestParam("patientId") Patient patient,
			@RequestParam("queueId") Integer queueId,
			UiSessionContext session,
			HttpServletRequest request) {
		PatientQueueService queueService = Context.getService(PatientQueueService.class);
		TriagePatientQueue queue = queueService.getTriagePatientQueueById(queueId);
		List<Obs> observations = new ArrayList<Obs>();
		ObsParser obsParser = new ObsParser();
		for (Map.Entry<String, String[]> postedParams : 
			((Map<String, String[]>) request.getParameterMap()).entrySet()) {
			try {
				observations = obsParser.parse(
						observations, patient, postedParams.getKey(),
						postedParams.getValue());
			} catch (Exception e) {
				return SimpleObject.create("status", "error", "message", e.getMessage());
			}
		}
		Encounter encounter = Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST, Collections.EMPTY_LIST, MchMetadata._MchProgram.PNC_PROGRAM, session.getSessionLocation());
		if (request.getParameter("send_for_examination") != null) {
			SendForExaminationParser.parse("send_for_examination", request.getParameterValues("send_for_examination"), patient);
		}
		QueueLogs.logTriagePatient(queue, encounter);
		return SimpleObject.create("status", "success", "message", "Triage information has been saved.");
	}
}
