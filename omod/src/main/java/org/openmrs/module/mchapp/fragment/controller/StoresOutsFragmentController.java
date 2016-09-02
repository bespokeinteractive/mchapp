package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Patient;
import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.*;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 9/2/2016.
 */
public class StoresOutsFragmentController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationStockouts(UiUtils uiUtils,
                                                     @RequestParam(value = "outsNames", required = false) String outsNames,
                                                     @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                     @RequestParam(value = "toDate", required = false) Date toDate) {

        List<ImmunizationStockout> stockouts = immunizationService.listImmunizationStockouts(outsNames,fromDate,toDate);
        return SimpleObject.fromCollection(stockouts, uiUtils, "id", "drug.name", "createdOn", "dateDepleted", "dateRestocked", "dateModified","remarks");
    }

    public SimpleObject saveImmunizationStockout(UiUtils uiUtils, @RequestParam("rtnsName") String rtnsName,
                                              @RequestParam("rtnsQuantity") Integer rtnsQuantity,
                                              @RequestParam("rtnsStage") Integer rtnsStage,
                                              @RequestParam("rtnsBatchNo") String rtnsBatchNo,
                                              @RequestParam(value = "patientId", required = false) Patient patient,
                                              @RequestParam("rtnsRemarks") String rtnsRemarks) {
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
