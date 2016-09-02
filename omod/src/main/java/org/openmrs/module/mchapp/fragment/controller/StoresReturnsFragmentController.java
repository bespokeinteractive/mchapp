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
        return SimpleObject.fromCollection(transactionDetails, uiUtils, "createdOn", "storeDrug.inventoryDrug.name", "quantity", "vvmStage", "remark");
    }

    public SimpleObject saveImmunizationReturns(UiUtils uiUtils, @RequestParam("rtnsName") String rtnsName,
                                              @RequestParam("rtnsQuantity") Integer rtnsQuantity,
                                              @RequestParam("rtnsStage") Integer rtnsStage,
                                              @RequestParam("rtnsBatchNo") String rtnsBatchNo,
                                              @RequestParam(value = "patientId", required = false) Patient patient,
                                              @RequestParam(value = "rtnsRemarks" , required = false) String rtnsRemarks) {
        Person person = Context.getAuthenticatedUser().getPerson();
        ImmunizationStoreDrugTransactionDetail transactionDetail = new ImmunizationStoreDrugTransactionDetail();
        transactionDetail.setCreatedBy(person);
        transactionDetail.setCreatedOn(new Date());
//        TODO need rework
        if (patient != null) {
            transactionDetail.setPatient(patient);
        }
        transactionDetail.setQuantity(rtnsQuantity);
        ImmunizationStoreDrug drug = immunizationService.getImmunizationStoreDrugByBatchNo(rtnsBatchNo);
        if (drug != null) {
//            drug exists with the given batch
            int currentQuantity = drug.getCurrentQuantity();
            int i = currentQuantity - rtnsQuantity;
            transactionDetail.setClosingBalance(i);
            transactionDetail.setOpeningBalance(currentQuantity);

            drug.setCurrentQuantity(i);
            transactionDetail.setStoreDrug(drug);
        } else {
//            no current drug with this batch ae the drug, then assign
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
