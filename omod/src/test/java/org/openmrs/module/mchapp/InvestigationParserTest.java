package org.openmrs.module.mchapp;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;
import org.openmrs.Patient;
import org.openmrs.User;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class InvestigationParserTest extends BaseModuleContextSensitiveTest {

	@Rule
	public ExpectedException expectedException = ExpectedException.none();

	@Test
	public void parse_shouldCreateATestOrderWhenAnInvestigationIsOrdered() throws Exception {
		executeDataSet("mch-concepts.xml");
		String testOrderKey = "test_order.122b36a4-9c07-4dfa-81ae-e6a4fe823077";
		String[] testOrderValue =  new String[] { "17a83f95-49d9-473c-9aeb-c20c874fa5a1" };
		Patient patient = Context.getPatientService().getPatient(2);
		String ordererLocation = "MCH CLINIC";
		User orderer = Context.getAuthenticatedUser();
		Date dateOrdered = new Date();
		
		List<OpdTestOrder> opdTestOrders = new ArrayList<OpdTestOrder>();
		InvestigationParser.parse(patient, testOrderKey, testOrderValue, ordererLocation, orderer,
				dateOrdered, opdTestOrders);
		
		Assert.assertThat(opdTestOrders.size(), Matchers.is(1));
	}
	
	@Test
	public void parse_shouldCreateMultipleTestOrderWhenMultipleInvestigationIsOrdered() throws Exception {
		executeDataSet("mch-concepts.xml");
		String testOrderKey = "test_order.122b36a4-9c07-4dfa-81ae-e6a4fe823077";
		String[] testOrderValue =  new String[] { "17a83f95-49d9-473c-9aeb-c20c874fa5a1", "53a5e2de-b5c9-4c01-92fa-f3f8ad838e56" };
		Patient patient = Context.getPatientService().getPatient(2);
		String ordererLocation = "MCH CLINIC";
		User orderer = Context.getAuthenticatedUser();
		Date dateOrdered = new Date();
		
		List<OpdTestOrder> opdTestOrders = new ArrayList<OpdTestOrder>();
		InvestigationParser.parse(patient, testOrderKey, testOrderValue, ordererLocation, orderer,
				dateOrdered, opdTestOrders);
		
		Assert.assertThat(opdTestOrders.size(), Matchers.is(2));
	}
	
	@Test public void parse_shouldThrowNullPointerExceptionWhenInvestigationQuestionConceptIsNotDefined() throws Exception {
		executeDataSet("mch-concepts.xml");
		String testOrderKey = "test_order.NonExistant";
		String[] testOrderValue =  new String[] { "17a83f95-49d9-473c-9aeb-c20c874fa5a1" };
		Patient patient = Context.getPatientService().getPatient(2);
		String ordererLocation = "MCH CLINIC";
		User orderer = Context.getAuthenticatedUser();
		Date dateOrdered = new Date();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("No concept with uuid: NonExistant, found.");
		InvestigationParser.parse(patient, testOrderKey, testOrderValue, ordererLocation, orderer,
				dateOrdered, new ArrayList<OpdTestOrder>());
	}
	
	@Test public void parse_shouldThrowNullPointerExceptionWhenInvestigationConceptIsNotDefined() throws Exception {
		executeDataSet("mch-concepts.xml");
		String testOrderKey = "test_order.122b36a4-9c07-4dfa-81ae-e6a4fe823077";
		String[] testOrderValue =  new String[] { "NonExistant" };
		Patient patient = Context.getPatientService().getPatient(2);
		String ordererLocation = "MCH CLINIC";
		User orderer = Context.getAuthenticatedUser();
		Date dateOrdered = new Date();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("No concept with uuid: NonExistant, found.");
		InvestigationParser.parse(patient, testOrderKey, testOrderValue, ordererLocation, orderer,
				dateOrdered, new ArrayList<OpdTestOrder>());
	}

	@Test public void parse_shouldThrowNullPointerWhenInvestigationConceptIsNotABillableService() throws Exception {
		executeDataSet("mch-concepts.xml");
		String testOrderKey = "test_order.122b36a4-9c07-4dfa-81ae-e6a4fe823077";
		String[] testOrderValue =  new String[] { "122b36a4-9c07-4dfa-81ae-e6a4fe823077" };
		Patient patient = Context.getPatientService().getPatient(2);
		String ordererLocation = "MCH CLINIC";
		User orderer = Context.getAuthenticatedUser();
		Date dateOrdered = new Date();
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("Concept with uuid: 122b36a4-9c07-4dfa-81ae-e6a4fe823077, is not a billable service.");
		InvestigationParser.parse(patient, testOrderKey, testOrderValue, ordererLocation, orderer,
				dateOrdered, new ArrayList<OpdTestOrder>());
	}
}
