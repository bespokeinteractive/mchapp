package org.openmrs.module.mchapp.model;

import org.openmrs.module.hospitalcore.model.InventoryDrug;

import java.io.Serializable;
import java.util.Date;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/26/2016.
 */

public class ImmunizationStockout implements Serializable {
    private static final long serialVersionUID = 1L;
    private Integer id;
    private InventoryDrug drug;
    private Date createdOn, dateDepleted, dateRestocked, dateModified;
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

    public Date getCreatedOn() {
        return createdOn;
    }

    public void setCreatedOn(Date createdOn) {
        this.createdOn = createdOn;
    }

    public Date getDateDepleted() {
        return dateDepleted;
    }

    public void setDateDepleted(Date dateDepleted) {
        this.dateDepleted = dateDepleted;
    }

    public Date getDateRestocked() {
        return dateRestocked;
    }

    public void setDateRestocked(Date dateRestocked) {
        this.dateRestocked = dateRestocked;
    }

    public Date getDateModified() {
        return dateModified;
    }

    public void setDateModified(Date dateModified) {
        this.dateModified = dateModified;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }
}
