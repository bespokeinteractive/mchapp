package org.openmrs.module.mchapp.model;

import org.openmrs.module.hospitalcore.model.InventoryDrug;

import java.io.Serializable;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/26/2016.
 */

public class ImmunizationStockout implements Serializable {
    private static final long serialVersionUID = 1L;
    private Integer id;
    private InventoryDrug drug;
    private int noOfDays;
    private String remarks;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public InventoryDrug getDrug() {
        return drug;
    }

    public void setDrug(InventoryDrug drug) {
        this.drug = drug;
    }

    public int getNoOfDays() {
        return noOfDays;
    }

    public void setNoOfDays(int noOfDays) {
        this.noOfDays = noOfDays;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}
