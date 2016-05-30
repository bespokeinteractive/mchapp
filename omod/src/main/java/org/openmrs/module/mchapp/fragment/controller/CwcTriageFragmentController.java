package org.openmrs.module.mchapp.fragment.controller;


import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.ProgramWorkflowService;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.TriagePatientQueue;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.QueueLogs;
import org.openmrs.module.mchapp.SendForExaminationParser;
import org.openmrs.module.mchapp.api.ListItem;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.PatientStateItem;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Created by USER on 5/4/2016.
 */
public class CwcTriageFragmentController {

    protected final Log log = LogFactory.getLog(getClass());
    DateFormat ymdDf = new SimpleDateFormat("yyyy-MM-dd");

    public void controller(FragmentModel model, UiUtils ui) {
        model.addAttribute("internalReferralSources", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));
    }

    @SuppressWarnings("unchecked")

    public SimpleObject saveCwcTriageInfo(
            @RequestParam("patientId") Patient patient, 
            @RequestParam("queueId") Integer queueId,
            UiSessionContext session,
            HttpServletRequest request) {
        PatientQueueService queueService = Context.getService(PatientQueueService.class);
        TriagePatientQueue queue = queueService.getTriagePatientQueueById(queueId);
        List<Obs> observations = new ArrayList<Obs>();
        ObsParser obsParser = new ObsParser();
        for (Map.Entry<String, String[]> postedParams :
                ((Map<String, String[]>) request.getParameterMap()).entrySet()) {
            try {
                observations = obsParser.parse(
                        observations, patient, postedParams.getKey(),
                        postedParams.getValue());
            } catch (Exception e) {
                return SimpleObject.create("status", "error", "message", e.getMessage());
            }
        }
        Encounter encounter = Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST,
                Collections.EMPTY_LIST, MchMetadata._MchProgram.CWC_PROGRAM, session.getSessionLocation());
        if (request.getParameter("send_for_examination") != null) {
            SendForExaminationParser.parse("send_for_examination", request.getParameterValues("send_for_examination"), patient);
        }
        QueueLogs.logTriagePatient(queue, encounter);
        return SimpleObject.create("status", "success", "message", "Triage information has been saved.");
    }

    public SimpleObject updatePatientProgram(HttpServletRequest request) {

        try {
            String programId = request.getParameter("programId");
            String enrollmentDateYmd = request.getParameter("enrollmentDateYmd");
            String completionDateYmd = request.getParameter("completionDateYmd");
            String outcomeId = request.getParameter("outcomeId");
            Context.getService(MchService.class).updatePatientProgram(Integer.parseInt(programId),
                    enrollmentDateYmd, completionDateYmd, null, Integer.parseInt(outcomeId));
        } catch (ParseException e) {
            return SimpleObject.create("status", "error", "message", e.getMessage());
        }
        return SimpleObject.create("status", "success", "message", "Patient Program Updated Successfully");
    }

    public List<SimpleObject> getPatientStates(HttpServletRequest request, UiUtils uiUtils) {
        Integer patientProgramId = Integer.parseInt(request.getParameter("patientProgramId"));
        Integer programWorkflowId = Integer.parseInt(request.getParameter("programWorkflowId"));
        List<PatientStateItem> ret = new ArrayList<PatientStateItem>();
        ProgramWorkflowService s = Context.getProgramWorkflowService();
        PatientProgram p = s.getPatientProgram(patientProgramId);
        ProgramWorkflow wf = p.getProgram().getWorkflow(programWorkflowId);
        for (PatientState st : p.statesInWorkflow(wf, false)) {
            ret.add(new PatientStateItem(st));
        }
        return SimpleObject.fromCollection(ret, uiUtils, "patientStateId", "programWorkflowId", "stateName", "workflowName",
                "startDate", "endDate","dateCreated","creator");
    }

    public List<SimpleObject> getPossibleNextStates(HttpServletRequest request, UiUtils uiUtils) {
        Integer patientProgramId = Integer.parseInt(request.getParameter("patientProgramId"));
        Integer programWorkflowId = Integer.parseInt(request.getParameter("programWorkflowId"));
        List<ListItem> ret = new ArrayList<ListItem>();
        PatientProgram pp = Context.getProgramWorkflowService().getPatientProgram(patientProgramId);
        ProgramWorkflow pw = pp.getProgram().getWorkflow(programWorkflowId);
        List<ProgramWorkflowState> states = pw.getPossibleNextStates(pp);
        for (ProgramWorkflowState state : states) {
            ListItem li = new ListItem();
            li.setId(state.getProgramWorkflowStateId());
            li.setName(state.getConcept().getName(Context.getLocale(), false).getName());
            ret.add(li);
        }
        return SimpleObject.fromCollection(ret, uiUtils, "id", "name", "description");
    }

    public SimpleObject changeToState(HttpServletRequest request, UiUtils uiUtils) {
        Integer patientProgramId = Integer.parseInt(request.getParameter("patientProgramId"));
        Integer programWorkflowId = Integer.parseInt(request.getParameter("programWorkflowId"));
        Integer programWorkflowStateId = Integer.parseInt(request.getParameter("programWorkflowStateId"));
        String onDateDMY = request.getParameter("onDateDMY");
        ProgramWorkflowService s = Context.getProgramWorkflowService();
        PatientProgram pp = s.getPatientProgram(patientProgramId);
        ProgramWorkflowState st = pp.getProgram().getWorkflow(programWorkflowId).getState(programWorkflowStateId);
        Date onDate = null;
        if (onDateDMY != null && onDateDMY.length() > 0) {
            try {
                onDate = ymdDf.parse(onDateDMY);
                pp.transitionToState(st, onDate);
                s.savePatientProgram(pp);
            } catch (ParseException e) {
                return SimpleObject.create("status", "error", "message", e.getMessage());
            } catch (Exception e) {
                return SimpleObject.create("status", "error", "message", e.getMessage());
            }
        }
        return SimpleObject.create("status", "success", "message", "Successfully");

    }
}
