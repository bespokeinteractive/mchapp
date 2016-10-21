package org.openmrs.module.mchapp.page.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStockout;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * Created by Dennis on 10/12/2016.
 */
public class StockoutsDetailsPageController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    public void get(@RequestParam("transactionId") Integer transactionId,
                    PageModel model,
                    UiUtils uiUtils) {
        ImmunizationStockout stockout = immunizationService.getImmunizationStockoutById(transactionId);
        model.addAttribute("transactionId",transactionId);
        model.addAttribute("stockout", stockout);


    }
}
