package org.openmrs.module.mchapp.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdPatientQueueLog;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.hospitalcore.model.TriagePatientQueueLog;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.QueueLogs;
import org.openmrs.module.mchapp.SendForExaminationParser;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.util.*;

/**
 * Created by qqnarf on 4/27/16.
 */
public class AntenatalTriageFragmentController {
    private static final Log log = LogFactory.getLog(AntenatalTriageFragmentController.class);


    private int visitTypeId;

    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui) {
        config.require("patientId");
        config.require("queueId");
        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));
        model.addAttribute("patientProfile", PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM));
        model.addAttribute("internalReferrals", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));
        model.addAttribute("queueId", config.get("queueId"));
    }

    @SuppressWarnings("unchecked")
    public SimpleObject saveAntenatalTriageInformation(
            @RequestParam("patientId") Patient patient,
            @RequestParam("queueId") Integer queueId,
            @RequestParam("patientEnrollmentDate") Date patientEnrollmentDate,
            UiSessionContext session,
            HttpServletRequest request) {
        SimpleObject saveStatus = null;
        PatientQueueService queueService = Context.getService(PatientQueueService.class);
        TriagePatientQueue queue = queueService.getTriagePatientQueueById(queueId);
        List<Obs> observations = new ArrayList<Obs>();
        ObsParser obsParser = new ObsParser();
        for (Map.Entry<String, String[]> postedParams : ((Map<String, String[]>) request.getParameterMap()).entrySet()) {
            try {
                observations = obsParser.parse(observations, patient, postedParams.getKey(), postedParams.getValue());
            } catch (Exception e) {
                saveStatus = SimpleObject.create("status", "error", "message", e.getMessage());
            }
        }
        List<Object> previousVisitsByPatient = Context.getService(MchService.class).findVisitsByPatient(patient, true, true, patientEnrollmentDate);
        if (previousVisitsByPatient.size() == 0) {
            visitTypeId = MchMetadata._MchProgram.INITIAL_MCH_CLINIC_VISIT;
        } else {
            visitTypeId = MchMetadata._MchProgram.RETURN_ANC_CLINIC_VISIT;
        }
        Encounter encounter = Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST,
                Collections.EMPTY_LIST, MchMetadata._MchProgram.ANC_PROGRAM, session.getSessionLocation(), visitTypeId);

        if (request.getParameter("send_for_examination") != null) {
            String visitStatus = queue.getVisitStatus();
            SendForExaminationParser.parse("send_for_examination", request.getParameterValues("send_for_examination"), patient, visitStatus);
        }
        QueueLogs.logTriagePatient(queue, encounter);
        saveStatus = SimpleObject.create("status", "success", "message", "Triage information has been saved.");
        return saveStatus;
    }

}
