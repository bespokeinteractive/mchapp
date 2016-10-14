package org.openmrs.module.mchapp.model;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/29/2016.
 */
public enum TransactionType {
    RECEIPTS(1),
    ISSUES(2),
    RETURNS(3);
    private int value;

    private TransactionType(int value) {
        this.value = value;
    }

    public int getValue() {
        return this.value;
    }

}