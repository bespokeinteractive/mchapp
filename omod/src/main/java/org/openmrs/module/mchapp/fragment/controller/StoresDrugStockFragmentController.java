package org.openmrs.module.mchapp.fragment.controller;

import org.hibernate.hql.ast.InvalidWithClauseException;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.ImmunizationDrugStock;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;

import java.lang.reflect.Array;
import java.util.*;

/**
 * Created by daugm on 10/5/2016.
 */
public class StoresDrugStockFragmentController {
    public void controller() {
    }

    public List<SimpleObject> listCurrentDrugStock(UiUtils ui){
        ImmunizationService immunizationService = Context.getService(ImmunizationService.class);
        List<ImmunizationStoreDrug> stockDrugs = immunizationService.getAvailableDrugBatches(null);
        List<ImmunizationDrugStock> drugStockBalances = new ArrayList<ImmunizationDrugStock>();

        List<Integer> drugs = new ArrayList<Integer>();

        for (ImmunizationStoreDrug immunizationStoreDrug : stockDrugs) {
            int drug = immunizationStoreDrug.getInventoryDrug().getId();
            if (!drugs.contains(drug)){
                drugs.add(drug);

                List<ImmunizationStoreDrug> currentDrugs = immunizationService.getImmunizationStoreDrugByName(immunizationStoreDrug.getInventoryDrug().getName());
                int drugQuantity = 0;

                for(ImmunizationStoreDrug currentDrug : currentDrugs) {
                    drugQuantity += currentDrug.getCurrentQuantity();
                }

                ImmunizationDrugStock immunizationDrugStock = new ImmunizationDrugStock(drugQuantity, immunizationStoreDrug);
                drugStockBalances.add(immunizationDrugStock);
            }
        }

        if (stockDrugs!=null){
            return SimpleObject.fromCollection(drugStockBalances, ui, "immunizationStoreDrug.id", "immunizationStoreDrug.batchNo", "immunizationStoreDrug.inventoryDrug.id", "immunizationStoreDrug.inventoryDrug.name", "immunizationStoreDrug.inventoryDrug.category.name", "immunizationStoreDrug.inventoryDrug.reorderQty", "drugQuantity");
        }

        return SimpleObject.fromCollection(Collections.EMPTY_LIST, ui);
    }
}
