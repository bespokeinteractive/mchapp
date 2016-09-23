package org.openmrs.module.mchapp.page.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.page.PageModel;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * @author Stanslaus Odhiambo
 * Created on 9/23/2016.
 */
public class StoresReceiptDetailsPageController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    public void get(@RequestParam("receiptId") Integer receiptId, PageModel model,UiUtils uiUtils) {
        model.addAttribute("receiptId",receiptId);
        model.addAttribute("title",receiptId);
        InventoryService service = Context.getService(InventoryService.class);

        ImmunizationStoreDrugTransactionDetail drugTransactionDetail = immunizationService.getImmunizationStoreDrugTransactionDetailById(receiptId);
        model.addAttribute("drugTransactionDetail",drugTransactionDetail);
        SimpleObject object = SimpleObject.fromObject(drugTransactionDetail, uiUtils,"id", "vvmStage", "remark", "quantity", "createdOn",
                "createdBy", "storeDrug.inventoryDrug.name", "storeDrug.batchNo", "transactionType.transactionType", "patient.name");
        model.addAttribute("drugTransactionDetails",drugTransactionDetail);
        model.addAttribute("drugObject",object);

    }
}
