package org.openmrs.module.mchapp;

import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.hospitalcore.model.InventoryDrugFormulation;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.inventory.InventoryService;

public class DrugOrdersParser {
	public static final Pattern digitPattern = Pattern.compile("\\d+");
	public static final InventoryService inventoryService = Context.getService(InventoryService.class);;

	private static OpdDrugOrder getOpdDrugOrder(InventoryDrug drug, Patient patient, List<OpdDrugOrder> drugOrderList, String orderSource) {
		OpdDrugOrder opdDrugOrder = new OpdDrugOrder();
		boolean found = false;
		for (OpdDrugOrder drugOrder : drugOrderList) {
			if (drugOrder.getInventoryDrug().getId() == drug.getId() &&
					drugOrder.getPatient().equals(patient)) {
				opdDrugOrder = drugOrder;
				found = true;
				break;
			}
		}
		if (!found) {
			opdDrugOrder.setInventoryDrug(drug);
			opdDrugOrder.setPatient(patient);
			//TODO externalise date
			opdDrugOrder.setCreatedOn(new Date());
			//TODO externalise creator
			opdDrugOrder.setCreator(Context.getAuthenticatedUser());
			opdDrugOrder.setReferralWardName(orderSource);
			drugOrderList.add(opdDrugOrder);
		}
		return opdDrugOrder;
	}

	public static List<OpdDrugOrder> parseDrugOrders(Patient patient, List<OpdDrugOrder> drugOrders, String parameterKey, String[] parameterValues, String orderSource) {
			Matcher matcher = digitPattern.matcher(parameterKey);
			if (parameterKey.contains("drug_order") && parameterValues.length > 0 && matcher.find()) {
				String drugOrderValue = parameterValues[0];
				if (parameterKey.contains("formulation")) {
					Integer drugId = Integer.parseInt(matcher.group());
					InventoryDrug inventoryDrug = inventoryService.getDrugById(drugId);
					OpdDrugOrder drugOrder = getOpdDrugOrder(inventoryDrug, patient, drugOrders, orderSource);
					Integer formulationId = Integer.parseInt(drugOrderValue);
					InventoryDrugFormulation drugFormulation = inventoryService.getDrugFormulationById(formulationId);
					drugOrder.setInventoryDrugFormulation(drugFormulation);
				}
				if (parameterKey.contains("frequency")) {
					Integer drugId = Integer.parseInt(matcher.group());
					InventoryDrug inventoryDrug = inventoryService.getDrugById(drugId);
					OpdDrugOrder drugOrder = getOpdDrugOrder(inventoryDrug, patient, drugOrders, orderSource);
					String frequencyUuid = drugOrderValue;
					Concept drugFrequency = Context.getConceptService().getConceptByUuid(frequencyUuid);
					drugOrder.setFrequency(drugFrequency);
				}
				if (parameterKey.contains("number_of_days")) {
					Integer drugId = Integer.parseInt(matcher.group());
					InventoryDrug inventoryDrug = inventoryService.getDrugById(drugId);
					OpdDrugOrder drugOrder = getOpdDrugOrder(inventoryDrug, patient, drugOrders, orderSource);
					try {
						Integer duration = Integer.parseInt(drugOrderValue);
						drugOrder.setNoOfDays(duration);
					} catch (NumberFormatException nfe) {
						//TODO
					}
				}
				if (parameterKey.contains("dosage_unit")) {
					Integer drugId = Integer.parseInt(matcher.group());
					InventoryDrug inventoryDrug = inventoryService.getDrugById(drugId);
					OpdDrugOrder drugOrder = getOpdDrugOrder(inventoryDrug, patient, drugOrders, orderSource);
					String dosageUnitId = drugOrderValue;
					Concept drugDosageUnit = Context.getConceptService().getConcept(dosageUnitId);
					drugOrder.setDosageUnit(drugDosageUnit);
				}
				if (parameterKey.contains("dosage")) {
					Integer drugId = Integer.parseInt(matcher.group());
					InventoryDrug inventoryDrug = inventoryService.getDrugById(drugId);
					OpdDrugOrder drugOrder = getOpdDrugOrder(inventoryDrug, patient, drugOrders, orderSource);
					drugOrder.setDosage(drugOrderValue);
				}
				if (parameterKey.contains("comments")) {
					Integer drugId = Integer.parseInt(matcher.group());
					InventoryDrug inventoryDrug = inventoryService.getDrugById(drugId);
					OpdDrugOrder drugOrder = getOpdDrugOrder(inventoryDrug, patient, drugOrders, orderSource);
					drugOrder.setComments(drugOrderValue);
				}
		}
		return drugOrders;
	}
}