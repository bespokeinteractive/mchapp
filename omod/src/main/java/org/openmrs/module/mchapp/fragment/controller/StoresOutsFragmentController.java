package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStockout;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.text.SimpleDateFormat;
import java.util.Calendar;
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

    public List<SimpleObject> listImmunizationStockouts(UiUtils ui,
                                                     @RequestParam(value = "outsNames", required = false) String outsNames,
                                                     @RequestParam(value = "fromDate", required = false) Date fromDate,
                                                     @RequestParam(value = "toDate", required = false) Date toDate) {

        List<ImmunizationStockout> stockouts = immunizationService.listImmunizationStockouts(outsNames,fromDate,toDate);
        return SimpleObject.fromCollection(stockouts, ui, "id", "drug.name", "drug.id", "createdOn", "dateDepleted", "dateRestocked", "dateModified","remarks");
    }

    public SimpleObject getImmunizationStockoutTransaction(UiUtils ui, @RequestParam("transactionId") int transactionId){
        ImmunizationStockout immunizationStockout = immunizationService.getImmunizationStockoutById(transactionId);
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        return SimpleObject.create("name", immunizationStockout.getDrug().getName(), "depletedOn", sdf.format(immunizationStockout.getDateDepleted()), "remarks", immunizationStockout.getRemarks());
    }

    public SimpleObject saveImmunizationStockout(UiUtils uiUtils, @RequestParam("outsName") String outsName,
                                              @RequestParam("depletionDate") Date depletionDate,
                                              @RequestParam(value = "dateModified",required = false) Date dateModified,
                                              @RequestParam(value = "dateRestocked",required = false) Date dateRestocked,
                                              @RequestParam(value = "outsRemarks",required = false) String outsRemarks) {
        InventoryDrug drug = Context.getService(InventoryService.class).getDrugByName(outsName);
        Person person = Context.getAuthenticatedUser().getPerson();
        ImmunizationStockout stockout = new ImmunizationStockout();
        stockout.setCreatedOn(new Date());
        stockout.setDateDepleted(depletionDate);//set depletion date
        stockout.setDateModified(dateModified);
        stockout.setDateRestocked(dateRestocked);
        stockout.setDrug(drug);
        stockout.setRemarks(outsRemarks);
        ImmunizationStockout sOut = immunizationService.saveImmunizationStockout(stockout);
        if (sOut != null) {
            return SimpleObject.create("status", "success","message","Drug Stock Out Saved Successfully");
        } else {
            return SimpleObject.create("status", "error","message","Error occurred while saving stockout");
        }
    }

    public SimpleObject updateImmunizationStockout(UiUtils uiUtils, @RequestParam("outsIdnt") int outsIdnt,
                                                 @RequestParam("depletionDate") Date depletionDate,
                                                 @RequestParam(value = "dateRestocked",required = false) Date dateRestocked,
                                                 @RequestParam(value = "outsRemarks",required = false) String outsRemarks) {
        ImmunizationStockout stockout = immunizationService.getImmunizationStockoutById(outsIdnt);
        stockout.setDateModified(new Date());
        stockout.setDateDepleted(depletionDate);//set depletion date
        stockout.setDateRestocked(dateRestocked);
        stockout.setRemarks(outsRemarks);

        ImmunizationStockout stocksouts = immunizationService.saveImmunizationStockout(stockout);
        if (stocksouts != null) {
            return SimpleObject.create("status", "success","message","Drug Stock Out Updated Successfully");
        } else {
            return SimpleObject.create("status", "error","message","Error occurred while Updating stockout");
        }
    }


}
