package org.openmrs.module.mchapp;

import java.util.Date;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.Location;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.BillingService;
import org.openmrs.module.hospitalcore.model.BillableService;
import org.openmrs.module.hospitalcore.model.DepartmentConcept;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class FreeInvestigationProcessorTest extends BaseModuleContextSensitiveTest {

	@Test public void process_shouldReturnAnEncounterWithAnOrderIfTestOrderBillHasBeenProcessed() throws Exception {
		executeDataSet("mch-programs.xml");
		Patient patient = Context.getPatientService().getPatient(2);
		Location location = Context.getLocationService().getLocation(2);
		Concept investigationQuestionConcept = Context.getConceptService().getConcept(9999);
		Concept investigationConcept = Context.getConceptService().getConcept(9996);
		OpdTestOrder testOrder = new OpdTestOrder();
		BillableService billableService = Context.getService(BillingService.class).getServiceByConceptId(investigationConcept.getConceptId());
		testOrder.setPatient(patient);
		testOrder.setConcept(investigationQuestionConcept);
		testOrder.setTypeConcept(DepartmentConcept.TYPES[2]);
		testOrder.setValueCoded(investigationConcept);
		testOrder.setBillableService(billableService);
		testOrder.setFromDept("MCH Clinic");
		testOrder.setBillingStatus(1);
		testOrder.setCreator(Context.getAuthenticatedUser());
		testOrder.setCreatedOn(new Date());
		
		Encounter encounter = FreeInvestigationProcessor.process(testOrder, location);
		
		Assert.assertNotNull(encounter);
		Assert.assertThat(encounter.getOrders().size(), Matchers.equalTo(1));
	}

}
