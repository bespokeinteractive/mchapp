package org.openmrs.module.mchapp.page.controller;

import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Program;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.ListItem;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Created by qqnarf on 4/27/16.
 */
public class MainPageController {
    private static final int MAX_CWC_DURATION = 5;
    private static final int MAX_ANC_PNC_DURATION = 9;

    public void get(
        @RequestParam("patientId") Patient patient,
        @RequestParam(value = "queueId") Integer queueId,
        PageModel model) {

        MchService mchService = Context.getService(MchService.class);
        model.addAttribute("patient", patient);
        model.addAttribute("queueId", queueId);

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

        model.addAttribute("enrollmentDate", new Date());

        Program program = null;
        Calendar minEnrollmentDate = Calendar.getInstance();
        List<ListItem> possibleProgramOutcomes = new ArrayList<ListItem>();
        if (enrolledInANC) {
            model.addAttribute("title", "ANC Clinic");
            minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_PNC_DURATION);
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM);
            possibleProgramOutcomes = mchService.getPossibleOutcomes(program.getProgramId());
        } else if (enrolledInPNC) {
            model.addAttribute("title", "PNC Clinic");
            minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_PNC_DURATION);
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM);
            possibleProgramOutcomes = mchService.getPossibleOutcomes(program.getProgramId());
        }
        else{
            model.addAttribute("title", "MCH Clinic");
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM);
            minEnrollmentDate.add(Calendar.YEAR, -MAX_CWC_DURATION);
            possibleProgramOutcomes = mchService.getPossibleOutcomes(program.getProgramId());

        }

//        TODO modify code to ensure that the last program enrolled is pulled
        List<PatientProgram> patientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, program, minEnrollmentDate.getTime(), null, null, null, false);

        //handles case when patient is yet to enroll in a patient program
        PatientProgram patientProgram = null;
        if(patientPrograms.size() > 0){
            patientProgram = patientPrograms.get(0);
        }
        model.addAttribute("patientProgram", patientProgram);
        model.addAttribute("possibleProgramOutcomes", possibleProgramOutcomes);

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
