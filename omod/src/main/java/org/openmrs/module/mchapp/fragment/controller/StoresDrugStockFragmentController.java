package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;

import java.util.Collections;
import java.util.List;

/**
 * Created by daugm on 10/5/2016.
 */
public class StoresDrugStockFragmentController {
    public void controller() {
    }

    public List<SimpleObject> listCurrentDrugStock(UiUtils ui){
        ImmunizationService immunizationService = Context.getService(ImmunizationService.class);
        List<ImmunizationStoreDrug> stockBalances = immunizationService.getAvailableDrugBatches(null);

        if (stockBalances!=null){
            return SimpleObject.fromCollection(stockBalances, ui, "batchNo");
        }
        return SimpleObject.fromCollection(Collections.EMPTY_LIST, ui);
    }


}
