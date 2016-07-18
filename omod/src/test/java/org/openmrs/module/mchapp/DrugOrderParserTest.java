package org.openmrs.module.mchapp;

import static org.hamcrest.Matchers.contains;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.beans.HasPropertyWithValue.hasProperty;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class DrugOrderParserTest extends BaseModuleContextSensitiveTest {

	@Test
	public void parseDrugOrders_shouldReturnOpdDrugOrder() throws Exception {
		executeDataSet("mch-concepts.xml");
		Patient patient = Context.getPatientService().getPatient(2);
		Map<String, String[]> postedDrugOrders = new HashMap<String, String[]>();
		String formulationKey = "drug_order.1.formulation";
		String formulation = "1";
		postedDrugOrders.put(formulationKey, new String[] { formulation });
		String frequencyKey = "drug_order.1.frequency";
		String frequency = "9960";
		postedDrugOrders.put(frequencyKey, new String[] { frequency });
		String numberOfDaysKey = "drug_order.1.number_of_days";
		String numberOfDays = "10";
		postedDrugOrders.put(numberOfDaysKey, new String[] { numberOfDays });
		String dosageKey = "drug_order.1.dosage";
		String dosage = "2";
		postedDrugOrders.put(dosageKey, new String[] { dosage });
		String drugUnitKey = "drug_order.1.drug_unit";
		String drugUnit = "9961";
		postedDrugOrders.put(drugUnitKey, new String[] { drugUnit });
		String commentsKey = "drug_order.1.comments";
		String comments = "Some comment";
		postedDrugOrders.put(commentsKey, new String[] { comments });
		List<OpdDrugOrder> drugOrders = new ArrayList<OpdDrugOrder>();
		for (Map.Entry<String, String[]> postedDrugOrder : postedDrugOrders
				.entrySet()) {
			DrugOrdersParser.parseDrugOrders(patient, drugOrders,
					postedDrugOrder.getKey(), postedDrugOrder.getValue(), null);
		}

		Assert.assertThat(drugOrders.size(), is(1));
		Assert.assertThat(drugOrders, 
			contains(
				hasProperty("patient", 
					hasProperty("patientId", is(2))
				)
			)
		);

	}

	@Test
	public void parseDrugOrder_shouldSetFormulationToDrugOrder()
			throws Exception {
		executeDataSet("mch-concepts.xml");
		Patient patient = Context.getPatientService().getPatient(2);
		String formulationKey = "drug_order.1.formulation";
		String formulation = "1";
		List<OpdDrugOrder> drugOrders = new ArrayList<OpdDrugOrder>();

		DrugOrdersParser.parseDrugOrders(patient, drugOrders, formulationKey,
				new String[] { formulation }, null);

		Assert.assertThat(drugOrders.size(), is(1));
		Assert.assertThat(
				drugOrders,
				contains(hasProperty("inventoryDrugFormulation",
						hasProperty("id", is(1)))));
	}

}
