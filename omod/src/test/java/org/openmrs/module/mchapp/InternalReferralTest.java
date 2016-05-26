package org.openmrs.module.mchapp;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.test.BaseModuleContextSensitiveTest;

/**
 * Created by qqnarf on 5/26/16.
 */
public class InternalReferralTest extends BaseModuleContextSensitiveTest {
    @Test
    public void sendToRefferalRoom_shouldFetchPatientFromQueueAndAddToAnotherQueue() throws Exception {
        executeDataSet("mch-concepts.xml");
        Patient patient = Context.getPatientService().getPatient(2);
        PatientQueueService queueService = Context.getService(PatientQueueService.class);
        InternalReferral internalReferral = new InternalReferral();
        int patientsInQueueBefore  = queueService.getAllPatientInQueue().size();
        internalReferral.sendToRefferedRoom(patient,"7f5cd7ad-ff69-4d60-b70c-799a98b046ef");
        int patientsInQueueAfter  = queueService.getAllPatientInQueue().size();
        Assert.assertThat(patientsInQueueAfter, Matchers.equalTo(patientsInQueueBefore+1));
    }
}
