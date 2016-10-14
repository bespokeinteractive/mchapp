package org.openmrs.module.mchapp.model;

import org.openmrs.Patient;
import org.openmrs.PatientState;
import org.openmrs.Person;

import java.io.Serializable;
import java.util.Date;

/**
 * @author Dennis Henry
 *         Created on 10/13/2016.
 */

public class ImmunizationStorePatientTransaction implements Serializable {
    private static final long serialVersionUID = 1L;
    private Integer id;
    private Patient patient;
    private ImmunizationStoreDrug storeDrug;
    private PatientState state;
    private int vvmStage;
    private String remark;
    private int quantity;
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

    public PatientState getState() {
        return state;
    }

    public void setState(PatientState state) {
        this.state = state;
    }

    public ImmunizationStoreDrug getStoreDrug() {
        return storeDrug;
    }

    public void setStoreDrug(ImmunizationStoreDrug storeDrug) {
        this.storeDrug = storeDrug;
    }

    public int getVvmStage() {
        return vvmStage;
    }

    public void setVvmStage(int vvmStage) { this.vvmStage = vvmStage; }

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
