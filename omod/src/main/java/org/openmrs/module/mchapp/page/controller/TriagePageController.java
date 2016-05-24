package org.openmrs.module.mchapp.page.controller;

import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.HospitalCoreService;
import org.openmrs.module.hospitalcore.model.PatientSearch;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;

public class TriagePageController {

	public void get(@RequestParam("patientId") Patient patient,
					PageModel model) {
		MchService mchService = Context.getService(MchService.class);
		model.addAttribute("patient", patient);

        if (patient.getGender().equals("M")){
            model.addAttribute("gender", "Male");
        }
        else{
            model.addAttribute("gender", "Female");
        }

        boolean enrolledInANC = mchService.enrolledInANC(patient);
        boolean enrolledInPNC = mchService.enrolledInPNC(patient);
        boolean enrolledInCWC = mchService.enrolledInCWC(patient);

        model.addAttribute("enrolledInAnc", enrolledInANC);
        model.addAttribute("enrolledInPnc", enrolledInPNC);
        model.addAttribute("enrolledInCwc", enrolledInCWC);

        if (enrolledInANC){
            model.addAttribute("title", "ANC Triage");
        }
        else  if (enrolledInPNC){
            model.addAttribute("title", "PNC Triage");
        }
        else  if (enrolledInCWC){
            model.addAttribute("title", "CWC Triage");
        }
        else{
            model.addAttribute("title", "Triage");
        }

        HospitalCoreService hospitalCoreService = Context.getService(HospitalCoreService.class);
        PatientSearch patientSearch = hospitalCoreService.getPatientByPatientId(patient.getPatientId());

        String patientType = hospitalCoreService.getPatientType(patient);

        model.addAttribute("patientType", patientType);
        model.addAttribute("patientSearch", patientSearch);
        model.addAttribute("previousVisit",hospitalCoreService.getLastVisitTime(patient));
        model.addAttribute("patientCategory", patient.getAttribute(14));
        //model.addAttribute("serviceOrderSize", serviceOrderList.size());
        model.addAttribute("patientId", patient.getPatientId());
        model.addAttribute("date", new Date());
	}

}
