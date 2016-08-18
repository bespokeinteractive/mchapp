package org.openmrs.module.mchapp.page.controller;

import org.openmrs.ConceptAnswer;
import org.openmrs.Patient;
import org.openmrs.PatientProgram;
import org.openmrs.Program;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.api.ListItem;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

/**
 * @author Stanslaus Odhiambo
 *         Created by on 8/18/2016.
 */
public class MchCwcImmunizationPageController {

    private static final int MAX_CWC_DURATION = 5;
    private static final int MAX_ANC_PNC_DURATION = 9;

    public String get(
            @RequestParam("patientId") Patient patient, PageModel model, UiUtils uiUtils) {

        MchService mchService = Context.getService(MchService.class);
        model.addAttribute("patient", patient);

        boolean enrolledInCWC = mchService.enrolledInCWC(patient);
        boolean enrolledInPNC = mchService.enrolledInPNC(patient);
        boolean enrolledInANC = mchService.enrolledInANC(patient);
        model.addAttribute("enrolledInAnc", enrolledInANC);
        model.addAttribute("enrolledInPnc", enrolledInPNC);
        model.addAttribute("enrolledInCwc", enrolledInCWC);
        if (patient.getGender().equals("M")) {
            model.addAttribute("gender", "Male");
        } else {
            model.addAttribute("gender", "Female");
        }

        Program program = null;
        Calendar minEnrollmentDate = Calendar.getInstance();
        List<ListItem> possibleProgramOutcomes = new ArrayList<ListItem>();
        Collection<ConceptAnswer> cwcFollowUps = new ArrayList<ConceptAnswer>();
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
        } else if (enrolledInCWC) {
            model.addAttribute("title", "CWC Immunization");
            program = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM);
            minEnrollmentDate.add(Calendar.YEAR, -MAX_CWC_DURATION);
            possibleProgramOutcomes = mchService.getPossibleOutcomes(program.getProgramId());
            cwcFollowUps = Context.getConceptService().getConceptByName("CWC FOLLOW UP").getAnswers();
            model.addAttribute("cwcFollowUpList", cwcFollowUps);
        }


//        TODO modify code to ensure that the last program enrolled is pulled
        List<PatientProgram> patientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, program, minEnrollmentDate.getTime(), null, null, null, false);

        //handles case when patient is yet to enroll in a patient program
        PatientProgram patientProgram = null;
        if (patientPrograms.size() > 0) {
            patientProgram = patientPrograms.get(0);
            //        TODO pull the correct enrollment Date
            model.addAttribute("enrollmentDate", patientProgram.getDateEnrolled());
        } else {
            patientProgram = new PatientProgram();
            model.addAttribute("enrollmentDate", new Date());
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

        return null;
    }
}
