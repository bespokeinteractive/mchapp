package org.openmrs.module.mchapp.model;

import org.openmrs.Patient;
import org.openmrs.Person;

import java.io.Serializable;
import java.util.Date;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/24/2016.
 */
public class ImmunizationStoreDrugTransactionDetail implements Serializable {
    private static final long serialVersionUID = 1L;
    private Integer id;
    private Patient patient;
    private ImmunizationStoreTransactionType transactionType;
    private ImmunizationStoreDrug storeDrug;
    private String remark;
    private int quantity;
    private int openingBalance;
    private int closingBalance;
    private Date createdOn;
    private Person createdBy;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Patient getPatient() {
        return patient;
    }

    public void setPatient(Patient patient) {
        this.patient = patient;
    }

    public ImmunizationStoreTransactionType getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(ImmunizationStoreTransactionType transactionType) {
        this.transactionType = transactionType;
    }

    public ImmunizationStoreDrug getStoreDrug() {
        return storeDrug;
    }

    public void setStoreDrug(ImmunizationStoreDrug storeDrug) {
        this.storeDrug = storeDrug;
    }

    public String getRemark() {
        return remark;
    }

    public void setRemark(String remark) {
        this.remark = remark;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public int getOpeningBalance() {
        return openingBalance;
    }

    public void setOpeningBalance(int openingBalance) {
        this.openingBalance = openingBalance;
    }

    public int getClosingBalance() {
        return closingBalance;
    }

    public void setClosingBalance(int closingBalance) {
        this.closingBalance = closingBalance;
    }

    public Date getCreatedOn() {
        return createdOn;
    }

    public void setCreatedOn(Date createdOn) {
        this.createdOn = createdOn;
    }

    public Person getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Person createdBy) {
        this.createdBy = createdBy;
    }
}
