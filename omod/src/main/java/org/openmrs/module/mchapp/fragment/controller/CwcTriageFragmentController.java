package org.openmrs.module.mchapp.fragment.controller;


import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.SendForExaminationParser;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;
import java.text.ParseException;

/**
 * Created by USER on 5/4/2016.
 */
public class CwcTriageFragmentController {

    public void controller(FragmentModel model, UiUtils ui) {
        model.addAttribute("internalReferralSources", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));
    }

    @SuppressWarnings("unchecked")

    public SimpleObject saveCwcTriageInfo(
            @RequestParam("patientId") Patient patient,
            UiSessionContext session,
            HttpServletRequest request) {
        List<Obs> observations = new ArrayList<Obs>();
        ObsParser obsParser = new ObsParser();
        for (Map.Entry<String, String[]> postedParams :
                ((Map<String, String[]>) request.getParameterMap()).entrySet()) {
            try {
                observations = obsParser.parse(
                        observations, patient, postedParams.getKey(),
                        postedParams.getValue());
                SendForExaminationParser.parse(postedParams.getKey(), postedParams.getValue(), patient);
            } catch (Exception e) {
                return SimpleObject.create("status", "error", "message", e.getMessage());
            }
        }

        Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST, Collections.EMPTY_LIST, MchMetadata._MchProgram.CWC_PROGRAM, null);
        return SimpleObject.create("status", "success", "message", "Triage information has been saved.");
    }

    public SimpleObject updatePatientProgram(HttpServletRequest request) {

        try {
            String programId = request.getParameter("programId");
            String enrollmentDateYmd = request.getParameter("enrollmentDateYmd");
            String completionDateYmd = request.getParameter("completionDateYmd");
            String outcomeId = request.getParameter("outcomeId");

            System.out.println(programId);
            System.out.println(enrollmentDateYmd);
            System.out.println(completionDateYmd);
            System.out.println(outcomeId);
            Context.getService(MchService.class).updatePatientProgram(Integer.parseInt(programId),
                    enrollmentDateYmd, completionDateYmd,null, Integer.parseInt(outcomeId));
        } catch (ParseException e) {
            return SimpleObject.create("status", "error", "message", e.getMessage());
        }
        return SimpleObject.create("status", "success", "message", "Patient Program Updated Successfully");
    }
}
