package org.openmrs.module.mchapp.fragment.controller;

import com.sun.org.apache.xpath.internal.operations.Bool;
import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.*;
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
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationReceipts(UiUtils uiUtils,
                                                       @RequestParam(value = "rcptNames", required = false) String rcptNames,
                                                       @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                       @RequestParam(value = "toDate", required = false) Date toDate) {

        List<ImmunizationStoreDrugTransactionDetail> transactionDetails = immunizationService.listImmunizationTransactions(TransactionType.RECEIPTS, rcptNames, fromDate, toDate);
        return SimpleObject.fromCollection(transactionDetails, uiUtils, "createdOn", "storeDrug.inventoryDrug.name", "storeDrug.inventoryDrug.id", "quantity", "vvmStage", "remark", "id");
    }

    public Integer checkForUnclosedStockouts(UiUtils ui,
                                             @RequestParam("drugId") Integer drugId){
        List<ImmunizationStockout> drugStockouts = immunizationService.listImmunizationStockouts(drugId, true);
        return drugStockouts.size();
    }

    public SimpleObject saveImmunizationReceipts(UiUtils ui, @RequestParam("storeDrugName") String storeDrugName,
                                                 @RequestParam("quantity") Integer quantity,
                                                 @RequestParam("vvmStage") Integer vvmStage,
                                                 @RequestParam("rcptBatchNo") String rcptBatchNo,
                                                 @RequestParam("expiryDate") Date expiryDate,
                                                 @RequestParam(value = "patient", required = false) Patient patient,
                                                 @RequestParam(value = "remarks", required = false) String remarks,
                                                 @RequestParam(value = "closeStockouts", required = false) int closeStockouts) {
        Person person = Context.getAuthenticatedUser().getPerson();
        ImmunizationStoreDrugTransactionDetail transactionDetail = new ImmunizationStoreDrugTransactionDetail();
        ImmunizationStoreDrug drugBatch = immunizationService.getImmunizationStoreDrugByBatchNo(rcptBatchNo, storeDrugName);
        InventoryDrug inventoryDrug = Context.getService(InventoryService.class).getDrugByName(storeDrugName);

        List<ImmunizationStoreDrug> drugs = immunizationService.getImmunizationStoreDrugByName(storeDrugName);
        int cummulativeQuantity = 0; //GET QUANTITY FROM THE LAST TRANSACTION IN THE immunization_store_drug_transaction_detail TABLE

        for(ImmunizationStoreDrug drug : drugs) {
            cummulativeQuantity += drug.getCurrentQuantity();
        }

        transactionDetail.setCreatedBy(person);
        transactionDetail.setCreatedOn(new Date());

        transactionDetail.setOpeningBalance(cummulativeQuantity);
        transactionDetail.setClosingBalance(cummulativeQuantity + quantity);

        ImmunizationStoreDrug immunizationStoreDrug = new ImmunizationStoreDrug();
        immunizationStoreDrug.setExpiryDate(expiryDate);
        immunizationStoreDrug.setCurrentQuantity(quantity);
        immunizationStoreDrug.setCreatedBy(person);
        immunizationStoreDrug.setBatchNo(rcptBatchNo);
        immunizationStoreDrug.setCreatedOn(new Date());
        immunizationStoreDrug.setInventoryDrug(inventoryDrug);

        if (patient != null) {
            transactionDetail.setPatient(patient);
        }
        transactionDetail.setQuantity(quantity);

        if (drugBatch != null) {
//          drugBatch exists with the given batch
            int currentQuantity = drugBatch.getCurrentQuantity();

            currentQuantity += quantity;
            drugBatch.setCurrentQuantity(currentQuantity);
            transactionDetail.setStoreDrug(drugBatch);
        } else {
//          no current drugBatch with this batch ae the drugBatch, then assign
            drugBatch = immunizationService.saveImmunizationStoreDrug(immunizationStoreDrug);
            transactionDetail.setStoreDrug(drugBatch);
        }

        //process the batch
        transactionDetail.setVvmStage(vvmStage);
        transactionDetail.setRemark(remarks);
        ImmunizationStoreTransactionType transactionType = immunizationService.getTransactionTypeById(TransactionType.RECEIPTS.getValue());
        transactionDetail.setTransactionType(transactionType);
        ImmunizationStoreDrugTransactionDetail storeDrugTransactionDetail = immunizationService.saveImmunizationStoreDrugTransactionDetail(transactionDetail);

        if (closeStockouts == 1){
            closeImmunizationStockouts(ui, inventoryDrug);
        }

        if (storeDrugTransactionDetail != null) {
            return SimpleObject.create("status", "success");
        } else {
            return SimpleObject.create("status", "error");
        }
    }

    public void closeImmunizationStockouts(UiUtils ui, InventoryDrug drug){
        List<ImmunizationStockout> stockouts = immunizationService.listImmunizationStockouts(drug.getId() ,true);

        for (ImmunizationStockout stockout : stockouts) {
            stockout.setDateRestocked(new Date());
            immunizationService.saveImmunizationStockout(stockout);
        }
    }
}
