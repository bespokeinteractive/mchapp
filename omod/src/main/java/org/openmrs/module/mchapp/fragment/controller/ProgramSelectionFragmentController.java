package org.openmrs.module.mchapp.fragment.controller;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.SimpleObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

public class ProgramSelectionFragmentController {

	protected Logger logger = LoggerFactory.getLogger(ProgramSelectionFragmentController.class);
	public void controller(){};
	
	public SimpleObject enrollInAnc(
			@RequestParam("patientId") Patient patient,
			@RequestParam("dateEnrolled") String dateEnrolledAsString
			) {
		MchService mchService = Context.getService(MchService.class);
		SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
		Date dateEnrolled;
		try {
			dateEnrolled = dateFormatter.parse(dateEnrolledAsString);
			mchService.enrollInANC(patient, dateEnrolled);
			return SimpleObject.create("status", "success", "message", patient + " has been enrolled into ANC");
		} catch (ParseException e) {
			logger.error(e.getMessage());
			return SimpleObject.create("status", "error", "message", dateEnrolledAsString + " is not in the correct format.");
		}
	}
	public SimpleObject enrollInPnc(
			@RequestParam("patientId") Patient patient,
			@RequestParam("dateEnrolled") String dateEnrolledAsString
			) {
		MchService mchService = Context.getService(MchService.class);
		SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
		Date dateEnrolled;
		try {
			dateEnrolled = dateFormatter.parse(dateEnrolledAsString);
			mchService.enrollInPNC(patient, dateEnrolled);
			return SimpleObject.create("status", "success", "message", patient + " has been enrolled into ANC");
		} catch (ParseException e) {
			logger.error(e.getMessage());
			return SimpleObject.create("status", "error", "message", dateEnrolledAsString + " is not in the correct format.");
		}
	}
	public SimpleObject enrollInCwc(
			@RequestParam("patientId") Patient patient,
			@RequestParam("dateEnrolled") String dateEnrolledAsString
			) {
		MchService mchService = Context.getService(MchService.class);
		SimpleDateFormat dateFormatter = new SimpleDateFormat("dd/MM/yyyy");
		Date dateEnrolled;
		try {
			dateEnrolled = dateFormatter.parse(dateEnrolledAsString);
			//TODO add method to enroll in CWC and call from here
			//mchService.enrollInCWC(patient, dateEnrolled);
			return SimpleObject.create("status", "success", "message", patient + " has been enrolled into ANC");
		} catch (ParseException e) {
			logger.error(e.getMessage());
			return SimpleObject.create("status", "error", "message", dateEnrolledAsString + " is not in the correct format.");
		}
	}

}
