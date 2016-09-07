package org.openmrs.module.mchapp.model;

import org.openmrs.Person;
import org.openmrs.module.hospitalcore.model.InventoryDrug;

import java.io.Serializable;
import java.util.Date;
import java.util.Set;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/24/2016.
 */

public class ImmunizationStoreDrug implements Serializable {
    private static final long serialVersionUID = 1L;
    private Integer id;
    private InventoryDrug inventoryDrug;
    private String batchNo;
    private int currentQuantity;
    private Date createdOn;
    private Date expiryDate;
    private Person createdBy;
    private Set<ImmunizationStoreDrugTransactionDetail> transactionDetails;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public InventoryDrug getInventoryDrug() {
        return inventoryDrug;
    }

    public void setInventoryDrug(InventoryDrug inventoryDrug) {
        this.inventoryDrug = inventoryDrug;
    }

    public String getBatchNo() {
        return batchNo;
    }

    public void setBatchNo(String batchNo) {
        this.batchNo = batchNo;
    }

    public int getCurrentQuantity() {
        return currentQuantity;
    }

    public void setCurrentQuantity(int currentQuantity) {
        this.currentQuantity = currentQuantity;
    }

    public Date getCreatedOn() {
        return createdOn;
    }

    public void setCreatedOn(Date createdOn) {
        this.createdOn = createdOn;
    }

    public Date getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }

    public Person getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Person createdBy) {
        this.createdBy = createdBy;
    }

    public Set<ImmunizationStoreDrugTransactionDetail> getTransactionDetails() {
        return transactionDetails;
    }
    public void setTransactionDetails(Set<ImmunizationStoreDrugTransactionDetail> transactionDetails) {
        this.transactionDetails = transactionDetails;
    }
}
