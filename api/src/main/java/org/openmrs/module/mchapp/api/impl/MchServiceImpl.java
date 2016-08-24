package org.openmrs.module.mchapp.api.impl;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.*;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.messagesource.MessageSourceService;
import org.openmrs.module.hospitalcore.PatientDashboardService;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.mchapp.FreeInvestigationProcessor;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.MchProfileConcepts;
import org.openmrs.module.mchapp.VisitListItem;
import org.openmrs.module.mchapp.api.ListItem;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.util.OpenmrsUtil;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import static java.lang.Math.max;

public class MchServiceImpl implements MchService {
    protected final Log log = LogFactory.getLog(getClass());

    private static final int MAX_ANC_DURATION = 9;
    private static final int MAX_PNC_DURATION = 9;
    private static final int MAX_CWC_DURATION = 5;
    DateFormat ymdDf = new SimpleDateFormat("yyyy-MM-dd");

    /********
     * ANC Operations
     *****/

    public boolean enrolledInProgram(Patient patient, Program program){
        Calendar minEnrollmentDate = Calendar.getInstance();
        Calendar minCompletionDate = Calendar.getInstance();

        minCompletionDate.add(Calendar.DAY_OF_MONTH, 1);

        if (program.getName().toLowerCase().contains("antenatal") || program.getName().toLowerCase().contains("anc")){
            minEnrollmentDate.add(Calendar.MONTH, -MAX_ANC_DURATION);
        }
        else if (program.getName().toLowerCase().contains("postnatal") || program.getName().toLowerCase().contains("pnc")){
            minEnrollmentDate.add(Calendar.MONTH, -MAX_PNC_DURATION);
        }
        else{
            minEnrollmentDate.add(Calendar.YEAR, -MAX_CWC_DURATION);
        }

        List<PatientProgram> ancPatientPrograms = Context.getProgramWorkflowService().getPatientPrograms(patient, program, minEnrollmentDate.getTime(), null, minCompletionDate.getTime(), null, false);
        if (ancPatientPrograms.size() > 0) {
            return true;
        }
        return false;
    }

    @Override
    public boolean enrolledInANC(Patient patient) {
        return enrolledInProgram(patient, Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.ANC_PROGRAM));
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
        return enrolledInProgram(patient, Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.PNC_PROGRAM));
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
        return enrolledInProgram(patient, Context.getProgramWorkflowService().getProgramByUuid(MchMetadata._MchProgram.CWC_PROGRAM));
    }

    @Override
    public SimpleObject enrollInCWC(Patient patient, Date dateEnrolled, Map<String, String> cwcInitialStates) {
        if (patient.getAge() != null) {
            if (patient.getAge() > 5) {
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
    public Encounter saveMchEncounter(ClinicalForm form, String encounterType,
                                      Location location, Integer visitTypeId) {
        Encounter mchEncounter = saveMchEncounter(form,
                encounterType, location);
        Visit visit = new Visit();
        visit.setLocation(location);
        visit.setPatient(form.getPatient());
        visit.setDateCreated(new Date());
        visit.setStartDatetime(new Date());
        VisitType visitType = Context.getVisitService().getVisitType(visitTypeId);
        visit.setVisitType(visitType);
        mchEncounter.setVisit(visit);
        return mchEncounter;
    }


    @Override
    public Encounter saveMchEncounter(ClinicalForm form, String encounterType,
            Location location) {
        if (form == null) {
            throw new IllegalArgumentException("form argument cannot be null");
        }
        Encounter mchEncounter = new Encounter();
        mchEncounter.setPatient(form.getPatient());
        mchEncounter.setLocation(location);
        Date encounterDateTime = new Date();
        if (form.getObservations().size() > 0) {
            encounterDateTime = form.getObservations().get(0).getObsDatetime();
        }
        mchEncounter.setEncounterDatetime(encounterDateTime);
        EncounterType mchEncounterType = Context.getEncounterService().getEncounterTypeByUuid(encounterType);
        mchEncounter.setEncounterType(mchEncounterType);
        for (Obs obs : form.getObservations()) {
            mchEncounter.addObs(obs);
        }
        mchEncounter = Context.getEncounterService().saveEncounter(mchEncounter);
        for (OpdDrugOrder drugOrder : form.getDrugOrders()) {
            drugOrder.setEncounter(mchEncounter);
            Context.getService(PatientDashboardService.class).saveOrUpdateOpdDrugOrder(drugOrder);
        }
        for (OpdTestOrder testOrder : form.getTestOrders()) {
            testOrder.setEncounter(mchEncounter);
            testOrder = Context.getService(PatientDashboardService.class).saveOrUpdateOpdOrder(testOrder);
            FreeInvestigationProcessor.process(testOrder, location);
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
            List<Obs> allProfileObs = Context.getObsService().getObservations(Arrays.asList((Person) patient), null, questions, null, null, null, Arrays.asList("obsDatetime"), null, null, dateEnrolled, null, false);
            getCurrentProfileInfo(currentProfileObs, allProfileObs);
        }
        return currentProfileObs;
    }

    @Override
    public List<Obs> getHistoricalPatientProfile(Patient patient, String programUuid) {
        List<Obs> allProfileObs = new ArrayList<Obs>();
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
        if (currentProgram != null) {
            Date dateEnrolled = currentProgram.getDateEnrolled();
            List<Concept> questions = getProfileConcepts(currentProgram);
            allProfileObs = Context.getObsService().getObservations(Arrays.asList((Person) patient), null, questions, null, null, null, Arrays.asList("obsDatetime"), null, null, dateEnrolled, null, false);
        }
        return allProfileObs;
    }

    @Override
    public List<ListItem> getPossibleOutcomes(Integer programId) {
        List<ListItem> ret = new ArrayList<ListItem>();
        List<Concept> possibleOutcomes = Context.getProgramWorkflowService().getPossibleOutcomes(programId);
        for (Concept possibleOutcome : possibleOutcomes) {
            ListItem li = new ListItem();
            li.setName(possibleOutcome.getName().getName());
            li.setId(possibleOutcome.getConceptId());
            ret.add(li);
        }
        return ret;
    }

    /**
     * Updates enrollment date, completion date, and location for a PatientProgram. Compares @param
     * enrollmentDateYmd with {@link PatientProgram#getDateEnrolled()} compares @param
     * completionDateYmd with {@link PatientProgram#getDateCompleted()}, compares @param locationId
     * with {@link PatientProgram#getLocation()}, compares @param outcomeId with {@link org.openmrs.PatientProgram#getOutcome()}.
     * At least one of these comparisons must indicate a change in order to update the PatientProgram. In other words, if neither the @param
     * enrollmentDateYmd, the @param completionDateYmd, or the @param locationId or the @param outcomeId
     * match with the persisted object, then the PatientProgram will not be updated.
     * <p>Also, if the enrollment date comes after the completion date, the PatientProgram will not be updated.</p>
     *
     * @param patientProgramId
     * @param enrollmentDateYmd
     * @param completionDateYmd
     * @param locationId
     * @param outcomeId
     * @throws ParseException
     */
    @Override
    public void updatePatientProgram(Integer patientProgramId, String enrollmentDateYmd, String completionDateYmd,
                                     Integer locationId, Integer outcomeId) throws ParseException {
        PatientProgram pp = Context.getProgramWorkflowService().getPatientProgram(patientProgramId);
        Location loc = null;
        if (locationId != null) {
            loc = Context.getLocationService().getLocation(locationId);
        }
        Concept outcomeConcept = null;
        if (outcomeId != null) {
            outcomeConcept = Context.getConceptService().getConcept(outcomeId);
        }
        Date dateEnrolled = null;
        Date dateCompleted = null;
        Date ppDateEnrolled = null;
        Date ppDateCompleted = null;
        Location ppLocation = pp.getLocation();
        Concept ppOutcome = pp.getOutcome();
        // If persisted date enrolled is not null then parse to ymdDf format.
        if (null != pp.getDateEnrolled()) {
            String enrolled = ymdDf.format(pp.getDateEnrolled());
            if (null != enrolled && enrolled.length() > 0)
                ppDateEnrolled = ymdDf.parse(enrolled);
        }
        // If persisted date enrolled is not null then parse to ymdDf format.
        if (null != pp.getDateCompleted()) {
            String completed = ymdDf.format(pp.getDateCompleted());
            if (null != completed && completed.length() > 0)
                ppDateCompleted = ymdDf.parse(completed);
        }
        // Parse parameter dates to ymdDf format.
        if (enrollmentDateYmd != null && enrollmentDateYmd.length() > 0)
            dateEnrolled = ymdDf.parse(enrollmentDateYmd);
        if (completionDateYmd != null && completionDateYmd.length() > 0)
            dateCompleted = ymdDf.parse(completionDateYmd);
        // If either either parameter and persisted instances
        // of enrollment and completion dates are equal, then anyChange is true.
        boolean anyChange = OpenmrsUtil.nullSafeEquals(dateEnrolled, ppDateEnrolled);
        anyChange |= OpenmrsUtil.nullSafeEquals(dateCompleted, ppDateCompleted);
        anyChange |= OpenmrsUtil.nullSafeEquals(loc, ppLocation);
        anyChange |= OpenmrsUtil.nullSafeEquals(outcomeConcept, ppOutcome);
        // Do not update if the enrollment date is after the completion date.
        if (null != dateEnrolled && null != dateCompleted && dateCompleted.before(dateEnrolled)) {
            anyChange = false;
        }
        if (anyChange) {
            pp.setDateEnrolled(dateEnrolled);
            pp.setDateCompleted(dateCompleted);
            pp.setLocation(loc);
            pp.setOutcome(outcomeConcept);
            Context.getProgramWorkflowService().savePatientProgram(pp);
        }
    }

    private void getCurrentProfileInfo(List<Obs> currentProfileObs, List<Obs> allProfileObs) {
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


    @Override
    public List<Object> findVisitsByPatient(Patient patient, boolean includeInactive, boolean includeVoided, Date dateEnrolled)
            throws APIException {
        // List to return
        List<Object> objectList = new ArrayList<Object>();
        MessageSourceService mss = Context.getMessageSourceService();
        try {
            List<Visit> visits = new ArrayList<Visit>();
            if (patient != null) {
                visits = Context.getVisitService().getVisitsByPatient(patient, includeInactive, includeVoided);
            } else {
                throw new APIException(mss.getMessage("Patient can not be null", null, "Patient cannot be null",
                        Context.getLocale()));
            }

            if (visits.size() > 0) {
                objectList = new ArrayList<Object>();
                for (Visit v : visits) {
                    if (v.getStartDatetime().after(dateEnrolled)) {
                        objectList.add(new VisitListItem(v));
                    }
                }
            }
        } catch (Exception e) {
            log.error("Error while searching for visits", e);
            objectList.add(mss.getMessage("Visit Search Error"));
        }
        return objectList;
    }

}
