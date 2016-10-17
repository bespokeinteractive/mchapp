package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;
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
public class StoresReturnsFragmentController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationReturns(UiUtils uiUtils,
                                                     @RequestParam(value = "returnNames", required = false) String returnNames,
                                                     @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                     @RequestParam(value = "toDate", required = false) Date toDate) {

        List<ImmunizationStoreDrugTransactionDetail> transactionDetails = immunizationService.listImmunizationTransactions(TransactionType.RETURNS, returnNames, fromDate, toDate);
        return SimpleObject.fromCollection(transactionDetails, uiUtils, "createdOn", "storeDrug.inventoryDrug.name", "storeDrug.inventoryDrug.id", "quantity", "vvmStage", "remark", "id");
    }

    public SimpleObject saveImmunizationReturns(UiUtils uiUtils, @RequestParam("rtnsName") String rtnsName,
                                              @RequestParam("rtnsQuantity") Integer rtnsQuantity,
                                              @RequestParam("rtnsStage") Integer rtnsStage,
                                              @RequestParam("rtnsBatchNo") String rtnsBatchNo,
                                              @RequestParam(value = "patientId", required = false) Patient patient,
                                              @RequestParam(value = "rtnsRemarks" , required = false) String rtnsRemarks) {
        Person person = Context.getAuthenticatedUser().getPerson();
        ImmunizationStoreDrugTransactionDetail transactionDetail = new ImmunizationStoreDrugTransactionDetail();
        ImmunizationStoreDrug drugBatch = immunizationService.getImmunizationStoreDrugByBatchNo(rtnsBatchNo, rtnsName);

        List<ImmunizationStoreDrug> drugs = immunizationService.getImmunizationStoreDrugByName(drugBatch.getInventoryDrug().getName());
        int cummulativeQuantity = 0; //GET QUANTITY FROM THE LAST TRANSACTION IN THE immunization_store_drug_transaction_detail TABLE

        for(ImmunizationStoreDrug drug : drugs) {
            cummulativeQuantity += drug.getCurrentQuantity();
        }

        transactionDetail.setCreatedBy(person);
        transactionDetail.setCreatedOn(new Date());
        transactionDetail.setOpeningBalance(cummulativeQuantity);
        transactionDetail.setClosingBalance(cummulativeQuantity + rtnsQuantity);

//        TODO need rework
        if (patient != null) {
            transactionDetail.setPatient(patient);
        }
        transactionDetail.setQuantity(rtnsQuantity);
        if (drugBatch != null) {
//            drugBatch exists with the given batch
            int currentQuantity = drugBatch.getCurrentQuantity();

            drugBatch.setCurrentQuantity(currentQuantity + rtnsQuantity);
            transactionDetail.setStoreDrug(drugBatch);
        } else {
//            no current drugBatch with this batch ae the drugBatch, then assign
            return SimpleObject.create("status", "error","message","No Drug Found for selected Batch");
        }
        //process the batch
        transactionDetail.setVvmStage(rtnsStage);
        transactionDetail.setRemark(rtnsRemarks);
        ImmunizationStoreTransactionType transactionType = immunizationService.getTransactionTypeById(TransactionType.RETURNS.getValue());
        transactionDetail.setTransactionType(transactionType);
        ImmunizationStoreDrugTransactionDetail storeDrugTransactionDetail = immunizationService.saveImmunizationStoreDrugTransactionDetail(transactionDetail);
        if (storeDrugTransactionDetail != null) {
            return SimpleObject.create("status", "success","message","Drug Return Saved Successfully");
        } else {
            return SimpleObject.create("status", "error","message","Error occurred while saving Return");
        }


    }

}
