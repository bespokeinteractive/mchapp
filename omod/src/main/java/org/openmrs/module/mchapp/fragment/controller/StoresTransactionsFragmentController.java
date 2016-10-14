package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.ImmunizationStorePatientTransaction;
import org.openmrs.module.mchapp.model.TransactionType;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;
import java.util.List;

/**
 * Created by daugm on 10/3/2016.
 */
public class StoresTransactionsFragmentController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationTransactions(UiUtils uiUtils,
                                                       @RequestParam(value = "transType", required = false) int transType,
                                                       @RequestParam(value = "transName", required = false) String transName,
                                                       @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                       @RequestParam(value = "toDate", required = false) Date toDate) {
        TransactionType transactionType = null;
        if (transType == 1){
            transactionType = TransactionType.RECEIPTS;
        }
        else if (transType == 2){
            transactionType = TransactionType.ISSUES;
        }
        else if (transType == 3){
            transactionType = TransactionType.RETURNS;
        }

        List<ImmunizationStoreDrugTransactionDetail> transactionDetails = immunizationService.listImmunizationTransactions(transactionType, transName, fromDate, toDate);
        return SimpleObject.fromCollection(transactionDetails, uiUtils, "createdOn", "storeDrug.inventoryDrug.name", "storeDrug.inventoryDrug.id", "quantity", "vvmStage", "remark", "id", "transactionType.transactionType");
    }
}
