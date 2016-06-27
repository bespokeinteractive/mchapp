package org.openmrs.module.mchapp;

import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;

/**
 * Created by qqnarf on 5/26/16.
 */
public class InternalReferral {
    @Transactional
    public void sendToRefferedRoom(Patient patient, String refferedRoomConceptUuid){
        PatientQueueService queueService = Context.getService(PatientQueueService.class);
        Concept referralConcept = Context.getConceptService().getConceptByUuid(refferedRoomConceptUuid);
        OpdPatientQueue  opdPatientQueue = new OpdPatientQueue();
        opdPatientQueue.setUser(Context.getAuthenticatedUser());
        opdPatientQueue.setPatient(patient);
        opdPatientQueue.setCreatedOn(new Date());
        opdPatientQueue.setBirthDate(patient.getBirthdate());
        opdPatientQueue.setPatientIdentifier(patient.getPatientIdentifier().getIdentifier());
        opdPatientQueue.setOpdConcept(referralConcept);
        opdPatientQueue.setOpdConceptName(referralConcept.getName().getName());
        if(null!=patient.getMiddleName())
        {
            opdPatientQueue.setPatientName(patient.getGivenName() + " " + patient.getFamilyName() + " " + patient.getMiddleName());
        }
        else
        {
            opdPatientQueue.setPatientName(patient.getGivenName() + " " + patient.getFamilyName());
        }

        opdPatientQueue.setReferralConcept(referralConcept);
        opdPatientQueue.setSex(patient.getGender());
        OpdPatientQueue opdPatient = queueService.saveOpdPatientQueue(opdPatientQueue);
    }
}
