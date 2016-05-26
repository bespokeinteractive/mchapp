package org.openmrs.module.mchapp.fragment.controller;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.hospitalcore.model.OpdPatientQueue;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.mchapp.DrugOrdersParser;
import org.openmrs.module.mchapp.InvestigationParser;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.ObsParser;
import org.openmrs.module.mchapp.QueueLogs;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.module.patientdashboardapp.model.ReferralReasons;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by qqnarf on 5/18/16.
 */
public class AntenatalExaminationFragmentController {
    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui) {
        config.require("patientId");
        config.require("queueId");
        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));
        model.addAttribute("patient", patient);
        model.addAttribute("patientProfile", PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM));
        model.addAttribute("internalReferrals", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("externalReferrals", SimpleObject.fromCollection(Referral.getExternalReferralOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("referralReasons", SimpleObject.fromCollection(ReferralReasons.getReferralReasonsOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("queueId", config.get("queueId"));
    }

	@SuppressWarnings("unchecked")
	public SimpleObject saveAntenatalExaminationInformation(
			@RequestParam("patientId") Patient patient,
			@RequestParam("queueId") Integer queueId,
			UiSessionContext session,
			HttpServletRequest request) {
		OpdPatientQueue patientQueue = Context.getService(
				PatientQueueService.class).getOpdPatientQueueById(queueId);
		String location = "PNC Exam Room";
		if (patientQueue != null) {
			location = patientQueue.getOpdConceptName();
		}
		List<Obs> observations = new ArrayList<Obs>();
		List<OpdDrugOrder> drugOrders = new ArrayList<OpdDrugOrder>();
		List<OpdTestOrder> testOrders = new ArrayList<OpdTestOrder>();
		ObsParser obsParser = new ObsParser();
		for (Map.Entry<String, String[]> postedParams : ((Map<String, String[]>) 
				request.getParameterMap()).entrySet()) {
			try {
				observations = obsParser.parse(
						observations, patient, postedParams.getKey(),
						postedParams.getValue());
				drugOrders = DrugOrdersParser.parseDrugOrders(patient,
						drugOrders, postedParams.getKey(),
						postedParams.getValue(), location);
				InvestigationParser.parse(patient, postedParams.getKey(), postedParams.getValue(), location, Context.getAuthenticatedUser(), new Date(), testOrders);
				
			} catch (Exception e) {
				return SimpleObject.create("status", "error", "message",
						e.getMessage());
			}
		}

		Encounter encounter = Context.getService(MchService.class).saveMchEncounter(patient,
				observations, drugOrders, testOrders, MchMetadata._MchProgram.ANC_PROGRAM, null);
		QueueLogs.logOpdPatient(patientQueue, encounter);
		return SimpleObject.create("status", "success", "message",
				"Triage information has been saved.");
	}
}
