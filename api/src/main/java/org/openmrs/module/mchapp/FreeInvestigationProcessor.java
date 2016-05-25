package org.openmrs.module.mchapp;

import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.openmrs.Concept;
import org.openmrs.ConceptAnswer;
import org.openmrs.Encounter;
import org.openmrs.EncounterType;
import org.openmrs.Location;
import org.openmrs.Order;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingConstants;
import org.openmrs.module.hospitalcore.LabService;
import org.openmrs.module.hospitalcore.RadiologyCoreService;
import org.openmrs.module.hospitalcore.model.Lab;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.hospitalcore.model.RadiologyDepartment;

public class FreeInvestigationProcessor {
	private static Set<Integer> collectionOfLabConceptIds = new HashSet<Integer>();
	private static Set<Integer> collectionOfRadiologyConceptIds = new HashSet<Integer>();

	static {
		List<Lab> labs = Context.getService(LabService.class).getAllLab();
		for (Lab lab : labs) {
			for (Concept labInvestigationCategoryConcept : lab.getInvestigationsToDisplay()) {
				for (ConceptAnswer labInvestigationConcept : labInvestigationCategoryConcept.getAnswers()) {
					collectionOfLabConceptIds.add(labInvestigationConcept.getAnswerConcept().getConceptId());
				}
			}
		}
		List<RadiologyDepartment> radiologyDepts = Context.getService(RadiologyCoreService.class).getAllRadiologyDepartments();
		for (RadiologyDepartment department : radiologyDepts) {
			for (Concept radiologyInvestigationCategoryConcept : department.getInvestigations()) {
				for (ConceptAnswer radiologyInvestigationConcept : radiologyInvestigationCategoryConcept.getAnswers()) {
					collectionOfRadiologyConceptIds.add(radiologyInvestigationConcept.getAnswerConcept().getConceptId());
				}
			}
		}
	}

	public static Encounter process(OpdTestOrder opdTestOrder, Location encounterLocation) {
		Encounter orderEncounter = null;
		if (opdTestOrder.getBillingStatus() == 1) {
			Integer investigationConceptId = opdTestOrder.getValueCoded().getConceptId();
			if (FreeInvestigationProcessor.collectionOfLabConceptIds.contains(investigationConceptId)) {
				String labEncounterTypeString = Context.getAdministrationService().getGlobalProperty(BillingConstants.GLOBAL_PROPRETY_LAB_ENCOUNTER_TYPE, "LABENCOUNTER");
				EncounterType labEncounterType = Context.getEncounterService().getEncounterType(labEncounterTypeString);
				Encounter encounter = getInvestigationEncounter(opdTestOrder,
						encounterLocation, labEncounterType);
				String labOrderTypeId = Context.getAdministrationService().getGlobalProperty(BillingConstants.GLOBAL_PROPRETY_LAB_ORDER_TYPE);
				generateInvestigationOrder(opdTestOrder, encounter, labOrderTypeId);
				orderEncounter = Context.getEncounterService().saveEncounter(encounter);
			}

			if (FreeInvestigationProcessor.collectionOfRadiologyConceptIds.contains(investigationConceptId)) {
				String radiologyEncounterTypeString = Context.getAdministrationService().getGlobalProperty(BillingConstants.GLOBAL_PROPRETY_RADIOLOGY_ENCOUNTER_TYPE, "RADIOLOGYENCOUNTER");
				EncounterType radiologyEncounterType = Context.getEncounterService().getEncounterType(radiologyEncounterTypeString);
				Encounter encounter = getInvestigationEncounter(opdTestOrder,
						encounterLocation, radiologyEncounterType);

				String labOrderTypeId = Context.getAdministrationService().getGlobalProperty(BillingConstants.GLOBAL_PROPRETY_RADIOLOGY_ORDER_TYPE);
				generateInvestigationOrder(opdTestOrder, encounter, labOrderTypeId);
				orderEncounter = Context.getEncounterService().saveEncounter(encounter);
			}
		}
		return orderEncounter;
	}

	@SuppressWarnings("deprecation")
	private static void generateInvestigationOrder(OpdTestOrder opdTestOrder,
			Encounter encounter, String orderTypeId) {
		Order order = new Order();
		order.setConcept(opdTestOrder.getValueCoded());
		order.setCreator(opdTestOrder.getCreator());
		order.setDateCreated(opdTestOrder.getCreatedOn());
		order.setOrderer(opdTestOrder.getCreator());
		order.setPatient(opdTestOrder.getPatient());
		order.setStartDate(new Date());
		order.setAccessionNumber("0");
		try {
			order.setOrderType(Context.getOrderService().getOrderType(Integer.parseInt(orderTypeId)));
		} catch (NumberFormatException nfe) {
			order.setOrderType(Context.getOrderService().getOrderType(8));
		}
		order.setEncounter(encounter);
		encounter.addOrder(order);
	}

	private static Encounter getInvestigationEncounter(OpdTestOrder opdTestOrder,
			Location encounterLocation, EncounterType encounterType) {
		List<Encounter> investigationEncounters = Context.getEncounterService().getEncounters(opdTestOrder.getPatient(), null, opdTestOrder.getCreatedOn(), null, null, Arrays.asList(encounterType), null, null, null, false);
		Encounter encounter = null;
		if (investigationEncounters.size() > 0) {
			encounter = investigationEncounters.get(0);
		} else {
			encounter = new Encounter();
			encounter.setCreator(opdTestOrder.getCreator());
			encounter.setLocation(encounterLocation);
			encounter.setDateCreated(opdTestOrder.getCreatedOn());
			encounter.setEncounterDatetime(opdTestOrder.getCreatedOn());
			encounter.setEncounterType(encounterType);
			encounter.setPatient(opdTestOrder.getPatient());
		}
		return encounter;
	}
}
