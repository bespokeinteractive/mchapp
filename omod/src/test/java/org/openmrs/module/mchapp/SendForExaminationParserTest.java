package org.openmrs.module.mchapp;

import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class SendForExaminationParserTest extends BaseModuleContextSensitiveTest {

	@Test public void parse_shouldSendPatientToExamRoomWhenReferOptionIsExamination() throws Exception {
		executeDataSet("mch-concepts.xml");
		String referParamKey = "send_for_examination";
		String[] referParamValue = new String[] { "examination" };
		Patient patient = Context.getPatientService().getPatient(2);
		OpdPatientQueue opdPatient =  null;
		String visitStatus = "REVISIT";
		
		opdPatient = SendForExaminationParser.parse(referParamKey, referParamValue, patient, visitStatus);
		
		Assert.assertNotNull(opdPatient);
		Assert.assertNotNull(opdPatient.getId());
	}

}
