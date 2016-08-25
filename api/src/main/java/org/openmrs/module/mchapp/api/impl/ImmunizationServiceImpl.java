package org.openmrs.module.mchapp.api.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.Patient;
import org.openmrs.api.db.DAOException;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.db.ImmunizationCommoditiesDAO;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;

import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/25/2016.
 */
public class ImmunizationServiceImpl extends BaseOpenmrsService implements ImmunizationService {
    private ImmunizationCommoditiesDAO dao;
    protected final Log log = LogFactory.getLog(this.getClass());

    public ImmunizationCommoditiesDAO getDao() {
        return dao;
    }

    public void setDao(ImmunizationCommoditiesDAO dao) {
        this.dao = dao;
    }

    @Override
    public List<ImmunizationStoreTransactionType> getAllTransactionTypes() {
        return dao.getAllTransactionTypes();
    }

    @Override
    public ImmunizationStoreTransactionType getTransactionTypeByName(String name) {
        return dao.getTransactionTypeByName(name);
    }

    @Override
    public ImmunizationStoreTransactionType getTransactionTypeById(int id) {
        return dao.getTransactionTypeById(id);
    }

    @Override
    public ImmunizationStoreTransactionType saveImmunizationStoreTransactionType(ImmunizationStoreTransactionType type) throws DAOException {
        return dao.saveImmunizationStoreTransactionType(type);
    }

    @Override
    public List<ImmunizationStoreDrug> getAllImmunizationStoreDrug() {
        return dao.getAllImmunizationStoreDrug();
    }

    @Override
    public ImmunizationStoreDrug getImmunizationStoreDrugById(int id) {
        return dao.getImmunizationStoreDrugById(id);
    }

    @Override
    public ImmunizationStoreDrug getImmunizationStoreDrugByBatchNo(String batchNo) {
        return dao.getImmunizationStoreDrugByBatchNo(batchNo);
    }

    @Override
    public ImmunizationStoreDrug saveImmunizationStoreDrug(ImmunizationStoreDrug storeDrug) {
        return dao.saveImmunizationStoreDrug(storeDrug);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByType(ImmunizationStoreTransactionType transactionType) {
        return dao.getImmunizationStoreDrugTransactionDetailByType(transactionType);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDrug(ImmunizationStoreDrug drug) {
        return dao.getImmunizationStoreDrugTransactionDetailByDrug(drug);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDate(Date date) {
        return dao.getImmunizationStoreDrugTransactionDetailByDate(date);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByPatient(Patient patient) {
        return dao.getImmunizationStoreDrugTransactionDetailByPatient(patient);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getAllImmunizationStoreDrugTransactionDetail() {
        return dao.getAllImmunizationStoreDrugTransactionDetail();
    }

    @Override
    public ImmunizationStoreDrugTransactionDetail getImmunizationStoreDrugTransactionDetailById(int id) {
        return dao.getImmunizationStoreDrugTransactionDetailById(id);
    }

    @Override
    public ImmunizationStoreDrugTransactionDetail saveImmunizationStoreDrugTransactionDetail(ImmunizationStoreDrugTransactionDetail transactionDetail) {
        return dao.saveImmunizationStoreDrugTransactionDetail(transactionDetail);
    }
}
