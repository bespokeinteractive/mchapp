package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsRequestParser;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.page.PageRequest;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Created by qqnarf on 4/27/16.
 */
public class AntenatalTriageFragmentController {
    public void controller() {
    }
    @SuppressWarnings("unchecked")
    public SimpleObject saveAntenatalTriageInformation(@RequestParam("patientId") Patient patient, PageRequest request) {
        SimpleObject saveStatus = null;
        List<Obs> observations = new ArrayList<Obs>();
        try {
            observations = ObsRequestParser.parseRequest(patient, (Map<String,String[]>)request.getRequest().getParameterMap());
        } catch (Exception e) {
            saveStatus = SimpleObject.create("status", "error", "message", e.getMessage());
        }

        Context.getService(MchService.class).saveMchEncounter(patient, observations, MchMetadata._MchProgram.ANC_PROGRAM);

        saveStatus = SimpleObject.create("status", "success", "message", "Triage information has been saved.");
        return saveStatus;
    }
}
