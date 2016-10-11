package org.openmrs.module.mchapp.page.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 9/7/2016.
 */
public class StoresVaccinesPageController {

    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    public void get(@RequestParam("drugId") Integer drugId, PageModel model) {
        model.addAttribute("drugId",drugId);
        InventoryService service = Context.getService(InventoryService.class);
        InventoryDrug inventoryDrug = service.getDrugById(drugId);
        if(inventoryDrug!=null){
            List<ImmunizationStoreDrug> storeDrugs = immunizationService.getImmunizationStoreDrugsForDrug(inventoryDrug);

            List<ImmunizationStoreDrugTransactionDetail> transactionDetails = immunizationService.listImmunizationTransactions(188);

            model.addAttribute("storeDrugs",storeDrugs);
            model.addAttribute("title",inventoryDrug.getName());
        }
    }
}
