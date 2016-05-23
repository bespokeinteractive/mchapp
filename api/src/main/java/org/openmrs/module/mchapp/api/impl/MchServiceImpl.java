package org.openmrs.module.mchapp.api.impl;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.PatientDashboardService;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.MchProfileConcepts;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;

import java.util.*;

import static java.lang.Math.max;

public class MchServiceImpl implements MchService {
    protected final Log log = LogFactory.getLog(getClass());

    private static final int MAX_ANC_DURATION = 9;
    private static final int MAX_PNC_DURATION = 9;
    private static final int MAX_CWC_DURATION = 5;

    /********
     * ANC Operations
     *****/

    @Override
    public boolean enrolledInANC(Patient patient) {
        Program ancProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM);
        Calendar minEnrollmentDate = Calendar.getInstance();
        minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_DURATION);
        List<PatientProgram> ancPatientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, ancProgram, minEnrollmentDate.getTime(), null, null, null, false);
        if (ancPatientPrograms.size() > 0) {
            return true;
        }
        return false;
    }

    @Override
    public SimpleObject enrollInANC(Patient patient, Date dateEnrolled) {
        Program ancProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM);
        if (!enrolledInANC(patient)) {
            PatientProgram patientProgram = new PatientProgram();
            patientProgram.setPatient(patient);
            patientProgram.setProgram(ancProgram);
            patientProgram.setDateEnrolled(dateEnrolled);
            //TODO Add creator
            Context.getProgramWorkflowService().savePatientProgram(patientProgram);
            return SimpleObject.create("status", "success", "message", "Patient enrolled in ANC successfully");
        } else {
            return SimpleObject.create("status", "error", "message", "Patient already enrolled in ANC program");
        }
    }


    /********
     * PNC Operations
     *****/
    @Override
    public boolean enrolledInPNC(Patient patient) {
        Program pncProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM);
        Calendar minEnrollmentDate = Calendar.getInstance();
        minEnrollmentDate.add(Calendar.MONTH, -MAX_PNC_DURATION);
        List<PatientProgram> pncPatientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, pncProgram, minEnrollmentDate.getTime(), null, null, null, false);
        if (pncPatientPrograms.size() > 0) {
            return true;
        }
        return false;
    }

    @Override
    public SimpleObject enrollInPNC(Patient patient, Date dateEnrolled) {
        Program pncProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM);
        if (!enrolledInPNC(patient)) {
            PatientProgram patientProgram = new PatientProgram();
            patientProgram.setPatient(patient);
            patientProgram.setProgram(pncProgram);
            patientProgram.setDateEnrolled(dateEnrolled);
            //TODO Add creator
            Context.getProgramWorkflowService().savePatientProgram(patientProgram);
            return SimpleObject.create("status", "success", "message", "Patient enrolled in PNC successfully");
        }
        return SimpleObject.create("status", "error", "message", "Patient already enrolled in PNC program");
    }

    /********
     * CWC Operations
     *****/

    @Override
    public boolean enrolledInCWC(Patient patient) {
        Program cwcProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM);
        Calendar minEnrollmentDate = Calendar.getInstance();
        minEnrollmentDate.add(Calendar.YEAR, -MAX_CWC_DURATION);
        List<PatientProgram> cwcPatientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, cwcProgram, minEnrollmentDate.getTime(), null, null, null, false);
        if (cwcPatientPrograms.size() > 0) {
            return true;
        }
        return false;
    }

    @Override
    public SimpleObject enrollInCWC(Patient patient, Date dateEnrolled, Map<String, String> cwcInitialStates) {
        if (patient.getAge() != null) {
            if (patient.getAge() >  5){
                return SimpleObject.create("status", "error", "message", "CWC only allowed for Child under 5 Years");
            }
        }

        Program cwcProgram = Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM);
        if (!enrolledInCWC(patient)) {
            PatientProgram patientProgram = new PatientProgram();
            patientProgram.setPatient(patient);
            patientProgram.setProgram(cwcProgram);
            patientProgram.setDateEnrolled(dateEnrolled);
            //TODO Add creator
            for (ProgramWorkflow programWorkflow : cwcProgram.getAllWorkflows()) {
                String workflowUuid = programWorkflow.getUuid();
                if (cwcInitialStates.containsKey(workflowUuid)) {
                    ProgramWorkflowState state = programWorkflow.getState(cwcInitialStates.get(workflowUuid));
                    log.debug("Transitioning to state: " + state);
                    patientProgram.transitionToState(state, dateEnrolled);
                }
            }
            Context.getProgramWorkflowService().savePatientProgram(patientProgram);
            return SimpleObject.create("status", "success", "message", "Patient enrolled in CWC successfully");
        } else {
            return SimpleObject.create("status", "error", "message", "Patient already enrolled in CWC program");
        }
    }

    @Override
    public Encounter saveMchEncounter(Patient patient, List<Obs> encounterObservations, List<OpdDrugOrder> drugOrders, String program) {
        Encounter mchEncounter = new Encounter();
        mchEncounter.setPatient(patient);
        Date encounterDateTime = new Date();
        if (encounterObservations.size() > 0) {
            encounterDateTime = encounterObservations.get(0).getObsDatetime();
        }
        mchEncounter.setEncounterDatetime(encounterDateTime);
        EncounterType mchEncounterType = null;
        if (StringUtils.equalsIgnoreCase(MchMetadata._MchProgram.ANC_PROGRAM, program)) {
            mchEncounterType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE);
        } else if (StringUtils.equalsIgnoreCase(MchMetadata._MchProgram.PNC_PROGRAM, program)) {
            mchEncounterType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.PNC_ENCOUNTER_TYPE);
        } else if (StringUtils.equalsIgnoreCase(MchMetadata._MchProgram.CWC_PROGRAM, program)) {
            mchEncounterType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.CWC_ENCOUNTER_TYPE);
        }
        mchEncounter.setEncounterType(mchEncounterType);
        for (Obs obs : encounterObservations) {
            mchEncounter.addObs(obs);
        }
        mchEncounter = Context.getEncounterService().saveEncounter(mchEncounter);
        for (OpdDrugOrder drugOrder : drugOrders) {
            drugOrder.setEncounter(mchEncounter);
            Context.getService(PatientDashboardService.class).saveOrUpdateOpdDrugOrder(drugOrder);
        }
        return mchEncounter;
    }

	@Override
	public List<Obs> getPatientProfile(Patient patient, String programUuid) {
		Program program = Context.getProgramWorkflowService().getProgramByUuid(programUuid);
		Calendar minEnrollmentDate = Calendar.getInstance();
		minEnrollmentDate.add(Calendar.MONTH, -max(max(MAX_CWC_DURATION, MAX_ANC_DURATION), MAX_PNC_DURATION));
		List<PatientProgram> patientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, program, minEnrollmentDate.getTime(), null, null, null, false);
		PatientProgram currentProgram = null;
		for (PatientProgram patientProgram : patientPrograms) {
			if (patientProgram.getActive()) {
				currentProgram = patientProgram;
				break;
			}
		}
		List<Obs> currentProfileObs = new ArrayList<Obs>();
		if (currentProgram != null) {
			Date dateEnrolled = currentProgram.getDateEnrolled();
			List<Concept> questions = getProfileConcepts(currentProgram);
			List<Obs> allProfileObs = Context.getObsService().getObservations(Arrays.asList((Person)patient), null, questions, null, null, null, Arrays.asList("obsDatetime"), null, null, dateEnrolled, null, false);
			getCurrentProfileInfo(currentProfileObs, allProfileObs);
		}
		return currentProfileObs;
	}

	private void getCurrentProfileInfo(List<Obs> currentProfileObs,
			List<Obs> allProfileObs) {
		List<Integer> addedProfileInfo = new ArrayList<Integer>();
		for (Obs profileMatch : allProfileObs) {
			if (!addedProfileInfo.contains(profileMatch.getConcept().getConceptId())) {
				addedProfileInfo.add(profileMatch.getConcept().getConceptId());
				currentProfileObs.add(profileMatch);
			}
		}
	}

	private List<Concept> getProfileConcepts(PatientProgram currentProgram) {
		List<Concept> questions = new ArrayList<Concept>();
		if (StringUtils.equalsIgnoreCase(currentProgram.getProgram().getUuid(), MchMetadata._MchProgram.ANC_PROGRAM)) {
			for (String conceptUuid : MchProfileConcepts.ANC_PROFILE_CONCEPTS) {
				questions.add(Context.getConceptService().getConceptByUuid(conceptUuid));
			}
		}
		if (StringUtils.equalsIgnoreCase(currentProgram.getProgram().getUuid(), MchMetadata._MchProgram.PNC_PROGRAM)) {
			for (String conceptUuid : MchProfileConcepts.PNC_PROFILE_CONCEPTS) {
				questions.add(Context.getConceptService().getConceptByUuid(conceptUuid));
			}
		}
		return questions;
	}

}
