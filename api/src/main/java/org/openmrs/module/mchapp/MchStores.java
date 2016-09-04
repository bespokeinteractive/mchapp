package org.openmrs.module.mchapp;

import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;

import java.util.List;

/**
 * Created by Dennys Henry on 9/4/2016.
 */
public class MchStores {
    public static ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    public static SimpleObject getBatchesForSelectedDrug(UiUtils uiUtils,
                                                  Integer drugId) {
        List<ImmunizationStoreDrug> storeDrugs = immunizationService.getAvailableDrugBatches(drugId);
        if (storeDrugs.size() > 0) {
            List<SimpleObject> simpleObjects = SimpleObject.fromCollection(storeDrugs, uiUtils, "batchNo", "currentQuantity", "expiryDate");
            return SimpleObject.create("status","success","message","Found Drugs","drugs",simpleObjects);
        }else{
            return SimpleObject.create("status","fail","message","No Batch for this Drug");
        }
    }
}
