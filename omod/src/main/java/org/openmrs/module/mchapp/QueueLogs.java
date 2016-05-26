package org.openmrs.module.mchapp;

import org.openmrs.Encounter;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.hospitalcore.model.TriagePatientQueueLog;

/**
 * Created by qqnarf on 5/24/16.
 */
public class QueueLogs {
    public TriagePatientQueueLog logTriagePatient(PatientQueueService queueService,
                                                   TriagePatientQueue queue, Encounter encounter) {
        TriagePatientQueueLog queueLog = new TriagePatientQueueLog();
        queueLog.setTriageConcept(queue.getTriageConcept());
        queueLog.setTriageConceptName(queue.getTriageConceptName());
        queueLog.setPatient(queue.getPatient());
        queueLog.setCreatedOn(queue.getCreatedOn());
        queueLog.setPatientIdentifier(queue.getPatientIdentifier());
        queueLog.setPatientName(queue.getPatientName());
        queueLog.setReferralConcept(queue.getReferralConcept());
        queueLog.setReferralConceptName(queue.getReferralConceptName());
        queueLog.setSex(queue.getSex());
        queueLog.setUser(Context.getAuthenticatedUser());
        queueLog.setStatus("Processed");
        queueLog.setBirthDate(queue.getBirthDate());
        queueLog.setEncounter(encounter);
        queueLog.setCategory(queue.getCategory());
        queueLog.setVisitStatus(queue.getVisitStatus());

        queueService.deleteTriagePatientQueue(queue);
        return queueService.saveTriagePatientQueueLog(queueLog);
    }
}
