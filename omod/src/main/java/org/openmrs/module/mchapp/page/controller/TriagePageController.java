package org.openmrs.module.mchapp.page.controller;

import org.apache.commons.lang.StringUtils;
import org.openmrs.Encounter;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Program;
import org.openmrs.api.EncounterService;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.model.TriageDetail;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

public class TriagePageController {
    private static final int MAX_CWC_DURATION = 5;
    private static final int MAX_ANC_PNC_DURATION = 9;

    public void get(
            @RequestParam("patientId") Patient patient,
            @RequestParam(value = "queueId") Integer queueId,
            @RequestParam(value = "isEdit",required=false) Boolean isEdit,
            @RequestParam(value = "encounterId",required=false) String encounterId,
            PageModel model) {
        MchService mchService = Context.getService(MchService.class);
        model.addAttribute("patient", patient);
        
        if(isEdit != null) {
        	model.addAttribute("isEdit", isEdit);
        } else {
        	model.addAttribute("isEdit", false);
        }
        
        model.addAttribute("queueId", queueId);
        
        if(StringUtils.isEmpty(encounterId)) {
        	model.addAttribute("encounterId", "");
        } else {
        	model.addAttribute("encounterId", encounterId);
        }

        if (patient.getGender().equals("M")) {
            model.addAttribute("gender", "Male");
        } else {
            model.addAttribute("gender", "Female");
        }

        boolean enrolledInANC = mchService.enrolledInANC(patient);
        boolean enrolledInPNC = mchService.enrolledInPNC(patient);
        boolean enrolledInCWC = mchService.enrolledInCWC(patient);

        model.addAttribute("enrolledInAnc", enrolledInANC);
        model.addAttribute("enrolledInPnc", enrolledInPNC);
        model.addAttribute("enrolledInCwc", enrolledInCWC);
        Calendar minEnrollmentDate = Calendar.getInstance();
        Program program = null;

        if (enrolledInANC) {
            model.addAttribute("title", "ANC Triage");
            minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_PNC_DURATION);
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM);
        } else if (enrolledInPNC) {
            model.addAttribute("title", "PNC Triage");
            minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_PNC_DURATION);
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM);
        } else if (enrolledInCWC) {
            model.addAttribute("title", "CWC Triage");
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM);
            minEnrollmentDate.add(Calendar.YEAR, -MAX_CWC_DURATION);
        } else {
            model.addAttribute("title", "Triage");
        }

        if (program != null) {
            List<PatientProgram> patientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, program, minEnrollmentDate.getTime(), null, null, null, false);

            //handles case when patient is yet to enroll in a patient program
            PatientProgram patientProgram = null;
            if (patientPrograms.size() > 0) {
                patientProgram = patientPrograms.get(0);
            }
            model.addAttribute("patientProgram", patientProgram);

        } else {
            model.addAttribute("patientProgram", new PatientProgram());
        }


        HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patient.getPatientId());

        String patientType = hospitalCoreService.getPatientType(patient);

        model.addAttribute("patientType", patientType);
        model.addAttribute("patientSearch", patientSearch);
        model.addAttribute("previousVisit", hospitalCoreService.getLastVisitTime(patient));
        model.addAttribute("patientCategory", patient.getAttribute(14));
        //model.addAttribute("serviceOrderSize", serviceOrderList.size());
        model.addAttribute("patientId", patient.getPatientId());
        model.addAttribute("date", new Date());
        
    }

	
}
