package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;
import java.util.Map;

import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.ConceptClass;
import org.openmrs.ConceptDatatype;
import org.openmrs.ConceptSearchResult;
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
	
	public List<SimpleObject> searchFor(@RequestParam("findingQuery") String findingQuery) {
		List<ConceptClass> requiredConceptClasses = Arrays.asList(Context.getConceptService().getConceptClassByName("Finding"));
		List<ConceptDatatype> requiredConceptDataTypes = Arrays.asList(Context.getConceptService().getConceptDatatypeByName("Coded"));
		List<Locale> locales = new ArrayList<Locale>();
		locales.add(Context.getLocale());
		List<ConceptSearchResult> possibleMatches = Context.getConceptService().getConcepts(findingQuery, locales, false, requiredConceptClasses, null, requiredConceptDataTypes, null, null, null, null);
		List<SimpleObject> searchResults = new ArrayList<SimpleObject>();
		for (ConceptSearchResult conceptSearchResult : possibleMatches) {
			Concept concept = conceptSearchResult.getConcept();
			SimpleObject finding = new SimpleObject();
			finding.put("uuid", concept.getUuid());
			finding.put("display", concept.getName().getName());
			List<SimpleObject> findingAnswers = new ArrayList<SimpleObject>();
			for (ConceptAnswer answer : concept.getAnswers()) {
				SimpleObject findingAnswer = new SimpleObject();
				findingAnswer.put("uuid", answer.getAnswerConcept().getUuid());
				findingAnswer.put("display", answer.getAnswerConcept().getName().getName());
				findingAnswers.add(findingAnswer);
			}
			finding.put("answers", findingAnswers);
			searchResults.add(finding);
		}
		return searchResults;
	}
}
