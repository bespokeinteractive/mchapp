package org.openmrs.module.mchapp.api.parsers;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.User;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.model.DepartmentConcept;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;

public class InvestigationParser {

	public static void parse(Patient patient, String testOrderKey,
			String[] testOrderValue, String ordererLocation, User orderer,
			Date dateOrdered, List<OpdTestOrder> opdTestOrders) {
		if (StringUtils.contains(testOrderKey, "test_order")
				&& testOrderValue.length > 0) {
			String investigationQuestionConceptUuid = testOrderKey.substring("test_order.".length());
			Concept investigationQuestionConcept = Context.getConceptService().getConceptByUuid(investigationQuestionConceptUuid);
			if (investigationQuestionConcept == null){
				throw new NullPointerException("No concept with uuid: " + investigationQuestionConceptUuid + ", found.");
			}
			for (int i = 0; i < testOrderValue.length; i++) {
				Concept investigationConcept = Context.getConceptService().getConceptByUuid(testOrderValue[i]);
				if (investigationConcept == null){
					throw new NullPointerException("No concept with uuid: " + testOrderValue[i] + ", found.");
				}
				BillableService billableService = Context.getService(BillingService.class).getServiceByConceptId(investigationConcept.getConceptId());
				if (billableService == null){
					throw new NullPointerException("Concept with uuid: " + testOrderValue[i] + ", is not a billable service.");
				}
				OpdTestOrder opdTestOrder = new OpdTestOrder();
				opdTestOrder.setPatient(patient);
				opdTestOrder.setConcept(investigationQuestionConcept);
				opdTestOrder.setTypeConcept(DepartmentConcept.TYPES[2]);
				opdTestOrder.setValueCoded(investigationConcept);
				opdTestOrder.setBillableService(billableService);
				opdTestOrder.setFromDept(ordererLocation);
				opdTestOrder.setCreator(orderer);
				opdTestOrder.setCreatedOn(dateOrdered);
				opdTestOrder.setScheduleDate(dateOrdered);
				if (billableService.getPrice().compareTo(BigDecimal.ZERO) == 0) {
					opdTestOrder.setBillingStatus(1);
				}
				opdTestOrders.add(opdTestOrder);
			}
		}
	}

}
