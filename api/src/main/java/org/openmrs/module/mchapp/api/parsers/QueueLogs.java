package org.openmrs.module.mchapp.api.parsers;

import org.openmrs.Encounter;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.openmrs.module.hospitalcore.model.OpdPatientQueueLog;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.hospitalcore.model.TriagePatientQueueLog;

/**
 * Created by qqnarf on 5/24/16.
 */
public class QueueLogs {
    public static TriagePatientQueueLog logTriagePatient(TriagePatientQueue queue,
                                                   Encounter encounter) {
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

        Context.getService(PatientQueueService.class).deleteTriagePatientQueue(queue);
        return Context.getService(PatientQueueService.class).saveTriagePatientQueueLog(queueLog);
    }

    public static OpdPatientQueueLog logOpdPatient(OpdPatientQueue queue, Encounter encounter) {
        OpdPatientQueueLog queueLog = new OpdPatientQueueLog();
        queueLog.setOpdConcept(queue.getOpdConcept());
        queueLog.setOpdConceptName(queue.getOpdConceptName());
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
        Context.getService(PatientQueueService.class).deleteOpdPatientQueue(queue);
        return Context.getService(PatientQueueService.class).saveOpdPatientQueueLog(queueLog);
    }
}
