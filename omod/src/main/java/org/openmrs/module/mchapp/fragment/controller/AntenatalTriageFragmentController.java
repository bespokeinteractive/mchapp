package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.SendForExaminationParser;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

/**
 * Created by qqnarf on 4/27/16.
 */
public class AntenatalTriageFragmentController {
    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui) {
        config.require("patientId");
        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));
        model.addAttribute("patientProfile", PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM));
        model.addAttribute("internalReferrals", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));
    }
    @SuppressWarnings("unchecked")
    public SimpleObject saveAntenatalTriageInformation(@RequestParam("patientId") Patient patient, HttpServletRequest request) {
        SimpleObject saveStatus = null;
        List<Obs> observations = new ArrayList<Obs>();
        for (Map.Entry<String, String[]> postedParams: ((Map<String,String[]>)request.getParameterMap()).entrySet()) {
            try {
                observations = ObsParser.parse(observations, patient, postedParams.getKey(), postedParams.getValue());
                SendForExaminationParser.parse(postedParams.getKey(), postedParams.getValue(), patient);
            } catch (Exception e) {
                saveStatus = SimpleObject.create("status", "error", "message", e.getMessage());
            }
        }

        Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST, MchMetadata._MchProgram.ANC_PROGRAM);

        saveStatus = SimpleObject.create("status", "success", "message", "Triage information has been saved.");
        return saveStatus;
    }
}
