package org.openmrs.module.mchapp.db.hibernate;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.NotYetImplementedException;
import org.openmrs.Patient;
import org.openmrs.api.db.DAOException;
import org.openmrs.module.mchapp.db.ImmunizationCommoditiesDAO;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Created on 8/24/2016.
 */

public class HibernateImmunizationCommoditiesDAO implements ImmunizationCommoditiesDAO {
    SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
    SimpleDateFormat formatterExt = new SimpleDateFormat("dd/MM/yyyy");
    protected final Log log = LogFactory.getLog(getClass());

    /**
     * Hibernate session factory
     */
    private SessionFactory sessionFactory;

    public void setSessionFactory(SessionFactory sessionFactory) throws DAOException {
        this.sessionFactory = sessionFactory;
    }

    /**
     * @return the sessionFactory
     */
    public SessionFactory getSessionFactory() {
        return sessionFactory;
    }


    @Override
    public List<ImmunizationStoreDrug> listImmunizationStoreDrug(String name, int min, int max) throws DAOException {
//        TODO Implement functionality
        throw new NotYetImplementedException("Yet to be Implemented");
    }

    @Override
    public List<ImmunizationStoreTransactionType> getAllTransactionTypes() {
        System.out.println(sessionFactory);
        Criteria criteria = sessionFactory.getCurrentSession().createCriteria(ImmunizationStoreTransactionType.class);
        List l = criteria.list();
        return l;
    }

    @Override
    public ImmunizationStoreTransactionType getTransactionTypeByName(String name) {
        return null;
    }

    @Override
    public ImmunizationStoreTransactionType getTransactionTypeById(int id) {
        return null;
    }

    @Override
    public ImmunizationStoreTransactionType saveImmunizationStoreTransactionType(ImmunizationStoreTransactionType type) {
        return null;
    }

    @Override
    public List<ImmunizationStoreDrug> getAllImmunizationStoreDrug() {
        return null;
    }

    @Override
    public ImmunizationStoreDrug getImmunizationStoreDrugById(int id) {
        return null;
    }

    @Override
    public ImmunizationStoreDrug getImmunizationStoreDrugByBatchNo(String batchNo) {
        return null;
    }

    @Override
    public ImmunizationStoreDrug saveImmunizationStoreDrug(ImmunizationStoreDrug storeDrug) {
        return null;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByType(ImmunizationStoreTransactionType transactionType) {
        return null;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDrug(ImmunizationStoreDrug drug) {
        return null;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDate(Date date) {
        return null;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByPatient(Patient patient) {
        return null;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getAllImmunizationStoreDrugTransactionDetail() {
        return null;
    }

    @Override
    public ImmunizationStoreDrugTransactionDetail getImmunizationStoreDrugTransactionDetailById(int id) {
        return null;
    }
}
