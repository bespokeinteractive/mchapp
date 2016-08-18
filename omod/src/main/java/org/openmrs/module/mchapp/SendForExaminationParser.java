package org.openmrs.module.mchapp;

import org.apache.commons.lang3.StringUtils;
import org.openmrs.Concept;
import org.openmrs.Patient;
import org.openmrs.PersonAttribute;
import org.openmrs.PersonAttributeType;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;

import java.util.Date;
import java.util.List;

public class SendForExaminationParser {
    private static final String TRIAGE_ROOM_CONCEPT_UUID = "7f5cd7ad-ff69-4d60-b70c-799a98b046ef";
    private static final String EXAM_ROOM_CONCEPT_UUID = "11303942-75cd-442a-aead-ae1d2ea9b3eb";

    public static OpdPatientQueue parse(String referParamKey, String[] referParamValue, Patient patient, String visitStatus) {
        Concept mchTriageConcept = Context.getConceptService().getConceptByUuid(TRIAGE_ROOM_CONCEPT_UUID);
        Concept mchExamRoomConcept = Context.getConceptService().getConceptByUuid(EXAM_ROOM_CONCEPT_UUID);
        OpdPatientQueue opdPatient = new OpdPatientQueue();
        if (StringUtils.equalsIgnoreCase(referParamKey, "send_for_examination") &&
                referParamValue.length > 0 &&
                StringUtils.equalsIgnoreCase(referParamValue[0], "examination")) {
            List<PersonAttribute> pas = Context.getService(HospitalCoreService.class).getPersonAttributes(patient.getPatientId());
            String selectedCategory = "";
            for (PersonAttribute pa : pas) {
                PersonAttributeType attributeType = pa.getAttributeType();
                if (attributeType.getPersonAttributeTypeId() == 14) {
                    selectedCategory = pa.getValue();
                }
            }
            OpdPatientQueue queue = new OpdPatientQueue();
            queue.setPatient(patient);
            queue.setCreatedOn(new Date());
            queue.setBirthDate(patient.getBirthdate());
            queue.setPatientIdentifier(patient.getPatientIdentifier().getIdentifier());
            queue.setOpdConcept(mchExamRoomConcept);
            queue.setOpdConceptName(mchExamRoomConcept.getName().getName());
            if (patient.getMiddleName() != null) {
                queue.setPatientName(patient.getGivenName() + " "
                        + patient.getFamilyName() + " "
                        + patient.getMiddleName().replace(",", " "));
            } else {
                queue.setPatientName(patient.getGivenName() + " "
                        + patient.getFamilyName());
            }
            queue.setReferralConcept(mchTriageConcept);
            queue.setReferralConceptName(mchTriageConcept.getName().getName());
            queue.setSex(patient.getGender());
            queue.setTriageDataId(null);
            queue.setCategory(selectedCategory);
            queue.setVisitStatus(visitStatus);
            opdPatient = Context.getService(PatientQueueService.class).saveOpdPatientQueue(queue);
        }
        return opdPatient;
    }

}
