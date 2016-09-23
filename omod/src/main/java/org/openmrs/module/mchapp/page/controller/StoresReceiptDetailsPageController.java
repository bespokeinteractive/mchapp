package org.openmrs.module.mchapp.page.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Stanslaus Odhiambo
 * Created on 9/23/2016.
 */
public class StoresReceiptDetailsPageController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    public void get(@RequestParam("receiptId") Integer receiptId, PageModel model) {
        model.addAttribute("receiptId",receiptId);
        model.addAttribute("title",receiptId);
        InventoryService service = Context.getService(InventoryService.class);

//        InventoryDrug inventoryDrug = service.getDrugById(drugId);
//        if(inventoryDrug!=null){
//            model.addAttribute("title",inventoryDrug.getName());
//            List<ImmunizationStoreDrug> storeDrugs = immunizationService.getImmunizationStoreDrugsForDrug(inventoryDrug);
//            model.addAttribute("storeDrugs",storeDrugs);
//        }
    }
}
