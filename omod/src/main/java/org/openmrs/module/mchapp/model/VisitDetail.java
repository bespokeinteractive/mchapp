package org.openmrs.module.mchapp.model;

import java.util.ArrayList;
import java.util.List;

import org.openmrs.Concept;
import org.openmrs.Drug;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.util.PatientDashboardConstants;
import org.openmrs.module.mchapp.MchMetadata;

public class VisitDetail {
	private static final String FINAL_DIAGNOSIS_CONCEPT_NAME = "FINAL DIAGNOSIS";
	private String history = "Not Specified";
	private String symptoms = "Not Specified";
	private String diagnosis = "Not Specified";
	private String investigations = "Not Specified";
	private String procedures = "Not Specified";
	private String examinations = "Not Specified";
    private String visitOutcome = "Not Specified";
	private String internalReferral = "Not Specified";
    private String externalReferral = "Not Specified";

	private String cwcFollowUp = "Not Specified";
	private String cwcBreastFeedingInfected = "Not Specified";
	private String cwcBreastFeedingExclussive = "Not Specified";
	private String cwcBreastFeedingCouncelling = "Not Specified";

	private String hivPriorStatus = "Not Specified";
	private String hivPartnerStatus = "Not Specified";
	private String hivPartnerTested = "Not Specified";
	private String hivCoupleCouncelled = "Not Specified";

	private String pncExcercise = "Not Specified";
	private String pncMultivitamin = "Not Specified";
	private String pncVitaminA = "Not Specified";
	private String pncHaematinics = "Not Specified";
	private String pncFamilyPlanning = "Not Specified";

	private String ancCouncelling = "Not Specified";
	private String ancExlussiveBF = "Not Specified";
	private String ancForInfected = "Not Specified";
	private String ancDecisionOnBF = "Not Specified";

	private String ancDeworming = "Not Specified";
	private String ancExcercise = "Not Specified";
	private String ancLLITN = "Not Specified";

	public String getAncDeworming() {
		return ancDeworming;
	}

	public void setAncDeworming(String ancDeworming) {
		this.ancDeworming = ancDeworming;
	}

	public String getAncExcercise() {
		return ancExcercise;
	}

	public void setAncExcercise(String ancExcercise) {
		this.ancExcercise = ancExcercise;
	}

	public String getAncLLITN() {
		return ancLLITN;
	}

	public void setAncLLITN(String ancLLITN) {
		this.ancLLITN = ancLLITN;
	}

	public String getAncCouncelling() {
		return ancCouncelling;
	}

	public void setAncCouncelling(String ancCouncelling) {
		this.ancCouncelling = ancCouncelling;
	}

	public String getAncExlussiveBF() {
		return ancExlussiveBF;
	}

	public void setAncExlussiveBF(String ancExlussiveBF) {
		this.ancExlussiveBF = ancExlussiveBF;
	}

	public String getAncForInfected() {
		return ancForInfected;
	}

	public void setAncForInfected(String ancForInfected) {
		this.ancForInfected = ancForInfected;
	}

	public String getAncDecisionOnBF() {
		return ancDecisionOnBF;
	}

	public void setAncDecisionOnBF(String ancDecisionOnBF) {
		this.ancDecisionOnBF = ancDecisionOnBF;
	}

	public String getPncFamilyPlanning() {
		return pncFamilyPlanning;
	}

	public void setPncFamilyPlanning(String pncFamilyPlanning) {
		this.pncFamilyPlanning = pncFamilyPlanning;
	}

	public String getPncExcercise() {
		return pncExcercise;
	}

	public void setPncExcercise(String pncExcercise) {
		this.pncExcercise = pncExcercise;
	}

	public String getPncMultivitamin() {
		return pncMultivitamin;
	}

	public void setPncMultivitamin(String pncMultivitamin) {
		this.pncMultivitamin = pncMultivitamin;
	}

	public String getPncVitaminA() {
		return pncVitaminA;
	}

	public void setPncVitaminA(String pncVitaminA) {
		this.pncVitaminA = pncVitaminA;
	}

	public String getPncHaematinics() {
		return pncHaematinics;
	}

	public void setPncHaematinics(String pncHaematinics) {
		this.pncHaematinics = pncHaematinics;
	}

	public String getHivCoupleCouncelled() {
		return hivCoupleCouncelled;
	}

	public void setHivCoupleCouncelled(String hivCoupleCouncelled) {
		this.hivCoupleCouncelled = hivCoupleCouncelled;
	}

	public String getHivPriorStatus() {
		return hivPriorStatus;
	}
	public void setHivPriorStatus(String hivPriorStatus) {
		this.hivPriorStatus = hivPriorStatus;
	}
	public String getHivPartnerStatus() {
		return hivPartnerStatus;
	}

	public void setHivPartnerStatus(String hivPartnerStatus) {
		this.hivPartnerStatus = hivPartnerStatus;
	}

	public String getHivPartnerTested() {
		return hivPartnerTested;
	}

	public void setHivPartnerTested(String hivPartnerTested) {
		this.hivPartnerTested = hivPartnerTested;
	}

	public String getCwcBreastFeedingCouncelling() {
		return cwcBreastFeedingCouncelling;
	}

	public void setCwcBreastFeedingCouncelling(String cwcBreastFeedingCouncelling) {
		this.cwcBreastFeedingCouncelling = cwcBreastFeedingCouncelling;
	}

	public String getCwcBreastFeedingExclussive() {
		return cwcBreastFeedingExclussive;
	}

	public void setCwcBreastFeedingExclussive(String cwcBreastFeedingExclussive) {
		this.cwcBreastFeedingExclussive = cwcBreastFeedingExclussive;
	}

	public String getCwcBreastFeedingInfected() {
		return cwcBreastFeedingInfected;
	}

	public void setCwcBreastFeedingInfected(String cwcBreastFeedingInfected) {
		this.cwcBreastFeedingInfected = cwcBreastFeedingInfected;
	}

	public String getCwcFollowUp() {
		return cwcFollowUp;
	}

	public void setCwcFollowUp(String cwcFollowUp) {
		this.cwcFollowUp = cwcFollowUp;
	}

    public String getExternalReferral() {
        return externalReferral;
    }

    public void setExternalReferral(String externalReferral) {
        this.externalReferral = externalReferral;
    }

    public String getInternalReferral() {
        return internalReferral;
    }

    public void setInternalReferral(String internalReferral) {
        this.internalReferral = internalReferral;
    }

    public String getVisitOutcome() {
        return visitOutcome;
    }

    public void setVisitOutcome(String visitOutcome) {
        this.visitOutcome = visitOutcome;
    }

	public String getExaminations() {
		return examinations;
	}

	public void setExaminations(String examination) {
		this.examinations = examination;
	}

	private List<Drug> drugs = new ArrayList<Drug>();

	public String getHistory() {
		return history;
	}

	public void setHistory(String history) {
		this.history = history;
	}

	public String getSymptoms() {
		return symptoms;
	}

	public void setSymptoms(String symptoms) {
		this.symptoms = symptoms;
	}

	public String getDiagnosis() {
		return diagnosis;
	}

	public void setDiagnosis(String diagnosis) {
		this.diagnosis = diagnosis;
	}

	public String getInvestigations() {
		return investigations;
	}

	public void setInvestigations(String investigations) {
		this.investigations = investigations;
	}

	public String getProcedures() {
		return procedures;
	}

	public void setProcedures(String procedures) {
		this.procedures = procedures;
	}

	public List<Drug> getDrugs() {
		return drugs;
	}

	public void setDrugs(List<Drug> drugs) {
		this.drugs = drugs;
	}
	
	public static VisitDetail create(Encounter encounter) {
        String historyConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_HISTORY_OF_PRESENT_ILLNESS);
		String symptomConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_SYMPTOM);
		String provisionalDiagnosisConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_PROVISIONAL_DIAGNOSIS);
		String investigationConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_FOR_INVESTIGATION);
		String procedureConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_POST_FOR_PROCEDURE);
        String physicalExaminationConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_PHYSICAL_EXAMINATION);
        String visitOutcomeName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_VISIT_OUTCOME);
        String internalReferralConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_INTERNAL_REFERRAL);
        String externalReferralConceptName = Context.getAdministrationService().getGlobalProperty(PatientDashboardConstants.PROPERTY_EXTERNAL_REFERRAL);

        String cwcFollowUpConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.CWC_FOLLOW_UP).getDisplayString();
		String cwcBreastFeedingInfectedConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.CWC_BREASTFEEDING_FOR_INFECTED).getDisplayString();
		String cwcBreastFeedingExclussiveConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.CWC_BREASTFEEDING_EXCLUSSIVE).getDisplayString();

		String hivPriorStatusConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.MCH_HIV_PRIOR_STATUS).getDisplayString();
		String hivPartnerStatusConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.MCH_HIV_PARTNER_STATUS).getDisplayString();
		String hivPartnerTestedConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.MCH_HIV_PARTNER_TESTED).getDisplayString();
		String hivCoupleCouncelledConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.MCH_HIV_PARTNER_TESTED).getDisplayString();
		
		String pncExcerciseConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.PNC_EXCERCISE).getDisplayString();
		String pncMultivitaminConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.PNC_MULTIVITAMIN).getDisplayString();
		String pncVitaminAConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.PNC_VITAMIN_A).getDisplayString();
		String pncHaematinicsConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.PNC_HAEMATINICS).getDisplayString();
		String pncFamilyPlanningConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.PNC_FAMILY_PLANNING).getDisplayString();
		
		String ancCouncellingConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_FEEDING_COUNCELLING).getDisplayString();
		String ancExlussiveBFConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_FEEDING_EXCLUSSIVE).getDisplayString();
		String ancForInfectedConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_FEEDING_INFECTED).getDisplayString();
		String ancDecisionOnBFConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_FEEDING_DECISION).getDisplayString();
		
		String ancDewormingConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_DEWORMING).getDisplayString();
		String ancExcerciseConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_EXCERCISE).getDisplayString();
		String ancLLITNConceptName =  Context.getConceptService().getConceptByUuid(MchMetadata.MchAppConstants.ANC_LLITN).getDisplayString();
		
		//Concepts
		Concept symptomConcept = Context.getConceptService().getConcept(symptomConceptName);
		Concept provisionalDiagnosisConcept = Context.getConceptService().getConcept(provisionalDiagnosisConceptName);
		Concept finalDiagnosisConcept = Context.getConceptService().getConcept(FINAL_DIAGNOSIS_CONCEPT_NAME);
		Concept investigationConcept = Context.getConceptService().getConcept(investigationConceptName);
		Concept procedureConcept = Context.getConceptService().getConcept(procedureConceptName);
		Concept physicalExaminationConcept = Context.getConceptService().getConcept(physicalExaminationConceptName);
        Concept historyConcept = Context.getConceptService().getConcept(historyConceptName);
        Concept visitOutcomeConcept = Context.getConceptService().getConcept(visitOutcomeName);
        Concept internalReferralConcept = Context.getConceptService().getConcept(internalReferralConceptName);
        Concept externalReferralConcept = Context.getConceptService().getConcept(externalReferralConceptName);

        Concept cwcFollowUpConcept = Context.getConceptService().getConcept(cwcFollowUpConceptName);
		Concept cwcBreastFeedingInfectedConcept = Context.getConceptService().getConcept(cwcBreastFeedingInfectedConceptName);
		Concept cwcBreastFeedingExclussiveConcept = Context.getConceptService().getConcept(cwcBreastFeedingExclussiveConceptName);

		Concept hivPriorStatusConcept = Context.getConceptService().getConcept(hivPriorStatusConceptName);
		Concept hivPartnerStatusConcept = Context.getConceptService().getConcept(hivPartnerStatusConceptName);
		Concept hivPartnerTestedConcept = Context.getConceptService().getConcept(hivPartnerTestedConceptName);
		Concept hivCoupleCouncelledConcept = Context.getConceptService().getConcept(hivCoupleCouncelledConceptName);
		
		Concept pncExcerciseConcept = Context.getConceptService().getConcept(pncExcerciseConceptName);
		Concept pncMultivitaminConcept = Context.getConceptService().getConcept(pncMultivitaminConceptName);
		Concept pncVitaminAConcept = Context.getConceptService().getConcept(pncVitaminAConceptName);
		Concept pncHaematinicsConcept = Context.getConceptService().getConcept(pncHaematinicsConceptName);
		Concept pncFamilyPlanningConcept = Context.getConceptService().getConcept(pncFamilyPlanningConceptName);
		
		Concept ancCouncellingConcept = Context.getConceptService().getConcept(ancCouncellingConceptName);
		Concept ancExlussiveBFConcept = Context.getConceptService().getConcept(ancExlussiveBFConceptName);
		Concept ancForInfectedConcept = Context.getConceptService().getConcept(ancForInfectedConceptName);
		Concept ancDecisionOnBFConcept = Context.getConceptService().getConcept(ancDecisionOnBFConceptName);
		
		Concept ancDewormingConcept = Context.getConceptService().getConcept(ancDewormingConceptName);
		Concept ancExcerciseConcept = Context.getConceptService().getConcept(ancExcerciseConceptName);
		Concept ancLLITNConcept = Context.getConceptService().getConcept(ancLLITNConceptName);

		//String Buffers
		StringBuffer symptomList = new StringBuffer();
		StringBuffer provisionalDiagnosisList = new StringBuffer();
		StringBuffer finalDiagnosisList = new StringBuffer();
		StringBuffer investigationList = new StringBuffer();
		StringBuffer procedureList = new StringBuffer();
		StringBuffer examination = new StringBuffer();
		StringBuffer history = new StringBuffer();
        StringBuffer visitOutcome = new StringBuffer();
        StringBuffer internalReferral = new StringBuffer();
        StringBuffer externalReferral = new StringBuffer();

        StringBuffer cwcFollowUp = new StringBuffer();
		StringBuffer cwcBreastFeedingInfected = new StringBuffer();
		StringBuffer cwcBreastFeedingExclussive = new StringBuffer();

		StringBuffer hivPriorStatus = new StringBuffer();
		StringBuffer hivPartnerStatus = new StringBuffer();
		StringBuffer hivPartnerTested = new StringBuffer();
		StringBuffer hivCoupleCouncelled = new StringBuffer();
		
		StringBuffer pncExcercise = new StringBuffer();
		StringBuffer pncMultivitamin = new StringBuffer();
		StringBuffer pncVitaminA = new StringBuffer();
		StringBuffer pncHaematinics = new StringBuffer();
		StringBuffer pncFamilyPlanning = new StringBuffer();
		
		StringBuffer ancCouncelling = new StringBuffer();
		StringBuffer ancExlussiveBF = new StringBuffer();
		StringBuffer ancForInfected = new StringBuffer();
		StringBuffer ancDecisionOnBF = new StringBuffer();
		
		StringBuffer ancDeworming = new StringBuffer();
		StringBuffer ancExcercise = new StringBuffer();
		StringBuffer ancLLITN = new StringBuffer();

		for (Obs obs : encounter.getAllObs()) {
			if (obs.getConcept().equals(symptomConcept)) {
				symptomList.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if (obs.getConcept().equals(provisionalDiagnosisConcept)) {
				provisionalDiagnosisList.append(obs.getValueCoded().getDisplayString()).append(" (Provisional)<br/>");
			}
			if (obs.getConcept().equals(finalDiagnosisConcept)) {
				finalDiagnosisList.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if (obs.getConcept().equals(investigationConcept)) {
				String investigationName = Context.getConceptService().getConceptByUuid(obs.getValueText()).getDisplayString();
				investigationList.append(investigationName).append("<br/>");
			}
			if (obs.getConcept().equals(procedureConcept)) {
				procedureList.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if (obs.getConcept().getConceptClass().getUuid().equals(MchMetadata.MchAppConstants.CWC_EXAMINATION_CLASS) && obs.getConcept().getDatatype().getUuid().equals(MchMetadata.MchAppConstants.CWC_EXAMINATION_DATATYPE)){
				String testName = obs.getConcept().getDisplayString();
				String testAnswer = obs.getValueCoded().getDisplayString();
				examination.append(testName + " : "+ testAnswer).append("<br/>");
			}
			if (obs.getConcept().equals(historyConcept)){
				history.append(obs.getValueText()).append("<br/>");
			}
            if (obs.getConcept().equals(visitOutcomeConcept)){
                visitOutcome.append(obs.getValueText()).append("<br/>");
            }
            if (obs.getConcept().equals(internalReferralConcept)){
				if (obs.getValueCoded() != null){
					internalReferral.append(obs.getValueCoded().getDisplayString()).append("<br/>");
				}
            }
            if(obs.getConcept().equals(externalReferralConcept)){
                externalReferral.append(obs.getValueCoded().getDisplayString()).append("<br/>");
            }
			if(obs.getConcept().equals(cwcFollowUpConcept)){
				cwcFollowUp.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(cwcBreastFeedingExclussiveConcept)){
				cwcBreastFeedingExclussive.append(obs.getValueCoded().getDisplayString()).append(" (0-6mnths)<br/>");
			}
			if(obs.getConcept().equals(cwcBreastFeedingInfectedConcept)){
				cwcBreastFeedingInfected.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(hivPriorStatusConcept)){
				hivPriorStatus.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(hivPartnerStatusConcept)){
				hivPartnerStatus.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(hivPartnerTestedConcept)){
				hivPartnerTested.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(hivCoupleCouncelledConcept)){
				hivCoupleCouncelled.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(pncExcerciseConcept)){
				pncExcercise.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(pncMultivitaminConcept)){
				pncMultivitamin.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(pncVitaminAConcept)){
				pncVitaminA.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(pncHaematinicsConcept)){
				pncHaematinics.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(pncFamilyPlanningConcept)){
				pncFamilyPlanning.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}			
			if(obs.getConcept().equals(ancCouncellingConcept)){
				ancCouncelling.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(ancExlussiveBFConcept)){
				ancExlussiveBF.append(obs.getValueCoded().getDisplayString()).append(" (Councelling)<br/>");
			}
			if(obs.getConcept().equals(ancForInfectedConcept)){
				ancForInfected.append(obs.getValueCoded().getDisplayString()).append(" (For Infected)<br/>");
			}
			if(obs.getConcept().equals(ancDecisionOnBFConcept)){
				ancDecisionOnBF.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}			
			if(obs.getConcept().equals(ancDewormingConcept)){
				ancDeworming.append(obs.getValueCoded().getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(ancExcerciseConcept)){
				ancExcercise.append(Context.getConceptService().getConceptByUuid(obs.getValueText()).getDisplayString()).append("<br/>");
			}
			if(obs.getConcept().equals(ancLLITNConcept)){
				ancLLITN.append(Context.getConceptService().getConceptByUuid(obs.getValueText()).getDisplayString()).append("<br/>");
			}
		}
		
		VisitDetail visitDetail = new VisitDetail();

		if (provisionalDiagnosisList.length() > 0) {
			visitDetail.setDiagnosis(provisionalDiagnosisList.toString());
		}
		if (symptomList.length() > 0) {
			visitDetail.setSymptoms(symptomList.toString());
		}
		if (procedureList.length() > 0) {
			visitDetail.setProcedures(procedureList.toString());
		}
		if (investigationList.length() > 0) {
			visitDetail.setInvestigations(investigationList.toString());
		}
        if (examination.length()>0){
            visitDetail.setExaminations(examination.toString());
        }
        if (history.length()>0){
            visitDetail.setHistory(history.toString());
        }
        if (visitOutcome.length()>0){
            visitDetail.setVisitOutcome(visitOutcome.toString());
        }
        if (internalReferral.length()>0){
            visitDetail.setInternalReferral(internalReferral.toString());
        }
        if (externalReferral.length()>0){
            visitDetail.setExternalReferral(externalReferral.toString());
        }
		if (cwcFollowUp.length()>0){
			visitDetail.setCwcFollowUp(cwcFollowUp.toString());
		}
		if (cwcBreastFeedingExclussive.length()>0){
			visitDetail.setCwcBreastFeedingExclussive(cwcBreastFeedingExclussive.toString());
		}
		if (cwcBreastFeedingInfected.length()>0){
			visitDetail.setCwcBreastFeedingInfected(cwcBreastFeedingInfected.toString());
		}
		if (hivPriorStatus.length()>0){
			visitDetail.setHivPriorStatus(hivPriorStatus.toString());
		}
		if (hivPartnerStatus.length()>0){
			visitDetail.setHivPartnerStatus(hivPartnerStatus.toString());
		}
		if (hivPartnerTested.length()>0){
			visitDetail.setHivPartnerTested(hivPartnerTested.toString());
		}
		if (hivCoupleCouncelled.length()>0){
			visitDetail.setHivCoupleCouncelled(hivCoupleCouncelled.toString());
		}			
		if (pncExcercise.length()>0){
			visitDetail.setPncExcercise(pncExcercise.toString());
		}	
		if (pncMultivitamin.length()>0){
			visitDetail.setPncMultivitamin(pncMultivitamin.toString());
		}	
		if (pncVitaminA.length()>0){
			visitDetail.setPncVitaminA(pncVitaminA.toString());
		}	
		if (pncHaematinics.length()>0){
			visitDetail.setPncHaematinics(pncHaematinics.toString());
		}
		if (pncFamilyPlanning.length()>0){
			visitDetail.setPncFamilyPlanning(pncFamilyPlanning.toString());
		}		
		if (ancCouncelling.length()>0){
			visitDetail.setAncCouncelling(ancCouncelling.toString());
		}
		if (ancExlussiveBF.length()>0){
			visitDetail.setAncExlussiveBF(ancExlussiveBF.toString());
		}
		if (ancForInfected.length()>0){
			visitDetail.setAncForInfected(ancForInfected.toString());
		}
		if (ancDecisionOnBF.length()>0){
			visitDetail.setAncDecisionOnBF(ancDecisionOnBF.toString());
		}
		
		if (ancDeworming.length()>0){
			visitDetail.setAncDeworming(ancDeworming.toString());
		}
		if (ancExcercise.length()>0){
			visitDetail.setAncExcercise(ancExcercise.toString());
		}
		if (ancLLITN.length()>0){
			visitDetail.setAncLLITN(ancLLITN.toString());
		}

		return visitDetail;
	}
}
