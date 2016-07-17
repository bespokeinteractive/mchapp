package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.ConceptClass;
import org.openmrs.ConceptDatatype;
import org.openmrs.ConceptSearchResult;
import org.openmrs.api.context.Context;
import org.openmrs.ui.framework.SimpleObject;
import org.springframework.web.bind.annotation.RequestParam;

public class ExaminationFilterFragmentController {
	public List<SimpleObject> searchFor(@RequestParam("findingQuery") String findingQuery) {
		List<ConceptClass> requiredConceptClasses = Arrays.asList(Context.getConceptService().getConceptClassByName("Finding"));
		List<ConceptDatatype> requiredConceptDataTypes = Arrays.asList(Context.getConceptService().getConceptDatatypeByName("Coded"), Context.getConceptService().getConceptDatatypeByName("Text"));
		List<Locale> locales = new ArrayList<Locale>();
		locales.add(Context.getLocale());
		List<ConceptSearchResult> possibleMatches = Context.getConceptService().getConcepts(findingQuery, locales, false, requiredConceptClasses, null, requiredConceptDataTypes, null, null, null, null);
		List<SimpleObject> searchResults = new ArrayList<SimpleObject>();


		for (ConceptSearchResult conceptSearchResult : possibleMatches) {
			Concept concept = conceptSearchResult.getConcept();
			SimpleObject finding = new SimpleObject();

			String text_name = "";
			String text_type = "hidden";

			finding.put("value", concept.getUuid());
			finding.put("label", concept.getName().getName());

			if (concept.getDatatype().getName().equals("Text")){
				text_type = "text";
				text_name = "concept." + concept.getUuid();
			}

			finding.put("text_name", text_name);
			finding.put("text_type", text_type);

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
