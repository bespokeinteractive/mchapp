package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.inventory.InventoryService;
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
public class StoresIssuesFragmentController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationIssues(UiUtils uiUtils,
                                                       @RequestParam(value = "issueNames", required = false) String rcptNames,
                                                       @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                       @RequestParam(value = "toDate", required = false) Date toDate) {

        List<ImmunizationStoreDrugTransactionDetail> transactionDetails = immunizationService.listImmunizationReceipts(TransactionType.ISSUES, rcptNames, fromDate, toDate);
        return SimpleObject.fromCollection(transactionDetails, uiUtils, "createdOn", "storeDrug.inventoryDrug.name", "quantity", "vvmStage", "remark");
    }

    public SimpleObject saveImmunizationIssue(UiUtils uiUtils, @RequestParam("storeDrugName") String storeDrugName,
                                                 @RequestParam("quantity") Integer quantity,
                                                 @RequestParam("vvmStage") Integer vvmStage,
                                                 @RequestParam("rcptBatchNo") String rcptBatchNo,
                                                 @RequestParam("expiryDate") Date expiryDate,
                                                 @RequestParam(value = "patient", required = false) Patient patient,
                                                 @RequestParam("remarks") String remarks) {
        Person person = Context.getAuthenticatedUser().getPerson();
        ImmunizationStoreDrugTransactionDetail transactionDetail = new ImmunizationStoreDrugTransactionDetail();
        transactionDetail.setCreatedBy(person);
        transactionDetail.setCreatedOn(new Date());
//        TODO need rework
        transactionDetail.setClosingBalance(quantity);
        transactionDetail.setOpeningBalance(quantity);
        if (patient != null) {
            transactionDetail.setPatient(patient);
        }
        transactionDetail.setQuantity(quantity);

        ImmunizationStoreDrug drug = immunizationService.getImmunizationStoreDrugByBatchNo(rcptBatchNo);
        if (drug != null) {
//            drug exists with the given batch
            int currentQuantity = drug.getCurrentQuantity();
            currentQuantity += quantity;
            drug.setCurrentQuantity(currentQuantity);
            transactionDetail.setStoreDrug(drug);
        } else {
//            no current drug with this batch ae the drug, then assign
            InventoryDrug inventoryDrug = Context.getService(InventoryService.class).getDrugByName(storeDrugName);
            ImmunizationStoreDrug immunizationStoreDrug = new ImmunizationStoreDrug();
            immunizationStoreDrug.setExpiryDate(expiryDate);
            immunizationStoreDrug.setCurrentQuantity(quantity);
            immunizationStoreDrug.setCreatedBy(person);
            immunizationStoreDrug.setBatchNo(rcptBatchNo);
            immunizationStoreDrug.setCreatedOn(new Date());
            immunizationStoreDrug.setInventoryDrug(inventoryDrug);
            drug = immunizationService.saveImmunizationStoreDrug(immunizationStoreDrug);
            transactionDetail.setStoreDrug(drug);
        }
        //process the batch
        transactionDetail.setVvmStage(vvmStage);
        transactionDetail.setRemark(remarks);
        ImmunizationStoreTransactionType transactionType = immunizationService.getTransactionTypeById(TransactionType.RECEIPTS.getValue());
        transactionDetail.setTransactionType(transactionType);
        ImmunizationStoreDrugTransactionDetail storeDrugTransactionDetail = immunizationService.saveImmunizationStoreDrugTransactionDetail(transactionDetail);
        if (storeDrugTransactionDetail != null) {
            return SimpleObject.create("status", "success");
        } else {
            return SimpleObject.create("status", "error");
        }


    }

}
