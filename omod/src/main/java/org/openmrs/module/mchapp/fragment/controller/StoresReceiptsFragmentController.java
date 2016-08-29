package org.openmrs.module.mchapp.fragment.controller;

import org.hibernate.cfg.NotYetImplementedException;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.TransactionType;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/29/2016.
 */
public class StoresReceiptsFragmentController {
    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationReceipts(UiUtils uiUtils,
                                                       @RequestParam(value = "rcptNames", required = false) String rcptNames,
                                                       @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                       @RequestParam(value = "toDate", required = false) Date toDate) {
        ImmunizationService immunizationService = Context.getService(ImmunizationService.class);
        List<ImmunizationStoreDrugTransactionDetail> transactionDetails = immunizationService.listImmunizationReceipts(TransactionType.RECEIPTS, rcptNames, fromDate, toDate);
        return SimpleObject.fromCollection(transactionDetails, uiUtils, "createdOn", "storeDrug", "quantity", "vvmStage", "remark");
    }

    public SimpleObject addImmunizationReceipt(UiUtils uiUtils, @RequestParam("rcptData") String rcptData) {
        throw new NotYetImplementedException("Yet to be Implemented");
    }

}
