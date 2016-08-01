package org.openmrs.module.mchapp.fragment.controller;


import org.apache.commons.lang.StringUtils;
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
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
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

    private int visitTypeId;
    protected final Log log = LogFactory.getLog(getClass());
    DateFormat ymdDf = new SimpleDateFormat("yyyy-MM-dd");

    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui,HttpServletRequest request) {
    	String enc = request.getParameter("encounterId");
    	
    	if(StringUtils.isNotEmpty(enc)){
    		model.addAttribute("weightCategoryValue", "");
    		Encounter current =Context.getEncounterService().getEncounter(Integer.parseInt(enc));
    	      
    	      //pull teh encounter id- from the url
    	      
    	        Set<Obs> obs= Context.getEncounterService().getEncounterByUuid(current.getUuid()).getAllObs();
    	        	for(Obs s:obs){
    	        		switch(s.getConcept().getId()){
    	        		case 5089:{
    	        			model.addAttribute("weight", s.getValueNumeric());
    	        			break;
    	        		}
    	        		case 5090:{
    	        			model.addAttribute("height", s.getValueNumeric());
    	        			break;
    	        		}
    	        		case 5712:{
    	        			model.addAttribute("muac", s.getValueNumeric());
    	        			break;
    	        		}
    	        		case 1854:{
    	        			//get the coded value - concept id
    	        			//Get concept by id
    	        			//get concept uuid
    	        			//supply uuid
    	        			Concept wCat=s.getValueCoded();
    	        			
    	        			model.addAttribute("weightCategoryValue", wCat.getUuid());
    	        			
    	        			break;
    	        		}
    	        		case 100126186:{
    	        			Concept gStat=s.getValueCoded();
    	        			model.addAttribute("growthStatusValue", gStat.getUuid());
    	        			break;
    	        		}
    	        	}
    	        }
    	}else{
    		model.addAttribute("weightCategoryValue", "");
    		model.addAttribute("growthStatusValue", "");
    		model.addAttribute("muac", "");
    		model.addAttribute("height", "");
    		model.addAttribute("weight", "");
    		
    	}
    	
    	
    	
    	
    	
        model.addAttribute("internalReferralSources", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id"));

        Concept  growthCategory= Context.getConceptService().getConceptByUuid(MchMetadata._MchProgram.MCH_GROWTH_MONITOR);
        List<SimpleObject> growthCategories = new ArrayList<SimpleObject>();
        
        if(growthCategory!=null){

            for (ConceptAnswer answer : growthCategory.getAnswers()) {
                growthCategories.add(SimpleObject.create("uuid", answer.getAnswerConcept().getUuid(),
                        "label", answer.getAnswerConcept().getDisplayString()));
            }
        }
        model.addAttribute("growthCategories", growthCategories);

        Concept weightCategory = Context.getConceptService().getConceptByUuid(MchMetadata._MchProgram.MCH_WEIGHT_CATEGORIES);
        List<SimpleObject> weightCategories = new ArrayList<SimpleObject>();
        if(weightCategory!=null){

            for (ConceptAnswer answer : weightCategory.getAnswers()) {
                weightCategories.add(SimpleObject.create("uuid", answer.getAnswerConcept().getUuid(),
                        "label", answer.getAnswerConcept().getDisplayString()));
            }
        }

        model.addAttribute("weightCategories", weightCategories);
      

      
 }

    @SuppressWarnings("unchecked")

    public SimpleObject saveCwcTriageInfo(
            @RequestParam("patientId") Patient patient, 
            @RequestParam("queueId") Integer queueId,
            @RequestParam("patientEnrollmentDate") Date patientEnrollmentDate,
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
        List<Object> previousVisitsByPatient = Context.getService(MchService.class).findVisitsByPatient(patient, true, true, patientEnrollmentDate);
        if (previousVisitsByPatient.size() == 0) {
            visitTypeId = MchMetadata._MchProgram.INITIAL_MCH_CLINIC_VISIT;
        } else {
            visitTypeId = MchMetadata._MchProgram.RETURN_CWC_CLINIC_VISIT;
        }
        Encounter encounter = Context.getService(MchService.class).saveMchEncounter(patient, observations, Collections.EMPTY_LIST,
                Collections.EMPTY_LIST, MchMetadata._MchProgram.CWC_PROGRAM,
                MchMetadata._MchEncounterType.CWC_TRIAGE_ENCOUNTER_TYPE, session.getSessionLocation(), visitTypeId);
        if (request.getParameter("send_for_examination") != null) {
            String visitStatus = queue.getVisitStatus();
            SendForExaminationParser.parse("send_for_examination", request.getParameterValues("send_for_examination"), patient, visitStatus);
        }
        boolean isEdit = Boolean.parseBoolean(request.getParameter("isEdit"));
        
        if(!isEdit){
        	QueueLogs.logTriagePatient(queue, encounter);
        }
        		
        return SimpleObject.create("status", "success", "message", "Triage information has been saved.", "isEdit",isEdit);
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
        return SimpleObject.create("status", "success", "message", "State changed Successfully");

    }
}
