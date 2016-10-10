package org.openmrs.module.mchapp;

import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;

/**
 * Created by daugm on 10/10/2016.
 */
public class ImmunizationDrugStock {
    private ImmunizationStoreDrug immunizationStoreDrug;
    private int drugQuantity;

    public ImmunizationDrugStock(int drugQuantity, ImmunizationStoreDrug immunizationStoreDrug) {
        this.drugQuantity = drugQuantity;
        this.immunizationStoreDrug = immunizationStoreDrug;
    }

    public ImmunizationStoreDrug getImmunizationStoreDrug() {
        return immunizationStoreDrug;
    }

    public void setImmunizationStoreDrug(ImmunizationStoreDrug immunizationStoreDrug) {
        this.immunizationStoreDrug = immunizationStoreDrug;
    }

    public int getDrugQuantity() {
        return drugQuantity;
    }

    public void setDrugQuantity(int drugQuantity) {
        this.drugQuantity = drugQuantity;
    }

}
