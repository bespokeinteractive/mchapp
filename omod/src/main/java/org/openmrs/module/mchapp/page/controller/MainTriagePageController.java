package org.openmrs.module.mchapp.page.controller;

import org.openmrs.Patient;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

public class MainTriagePageController {

	public void get(@RequestParam("patientId") Patient patient, PageModel model) {
		model.addAttribute("patient", patient);
	}

}
