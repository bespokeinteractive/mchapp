package org.openmrs.module.mchapp.page.controller;

import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by qqnarf on 4/27/16.
 */
public class MainPageController {
    public void get(@RequestParam("patientId") Patient patient, PageModel model) {
        MchService mchService = Context.getService(MchService.class);
        model.addAttribute("patient", patient);
        model.addAttribute("enrolledInAnc", mchService.enrolledInANC(patient));
        model.addAttribute("enrolledInPnc", mchService.enrolledInPNC(patient));
        //TODO add check for enrolled in Cwc to MchService
        model.addAttribute("enrolledInCwc", false);
    }
}
