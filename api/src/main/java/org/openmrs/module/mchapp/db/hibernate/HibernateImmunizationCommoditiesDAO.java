package org.openmrs.module.mchapp.db.hibernate;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.NotYetImplementedException;
import org.hibernate.criterion.Restrictions;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.api.db.DAOException;
import org.openmrs.module.hospitalcore.model.InventoryDrug;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.mchapp.db.ImmunizationCommoditiesDAO;
import org.openmrs.module.mchapp.model.*;

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
        Criteria criteria = sessionFactory.getCurrentSession().createCriteria(ImmunizationStoreTransactionType.class);
        List l = criteria.list();
        return l;
    }

    @Override
    public ImmunizationStoreTransactionType getTransactionTypeByName(String name) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreTransactionType.class);
        criteria.add(Restrictions.eq("transactionType", name));
        ImmunizationStoreTransactionType transactionType = (ImmunizationStoreTransactionType) criteria.uniqueResult();
        return transactionType;
    }

    @Override
    public ImmunizationStoreTransactionType getTransactionTypeById(int id) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreTransactionType.class);
        criteria.add(Restrictions.eq("id", id));
        ImmunizationStoreTransactionType transactionType = (ImmunizationStoreTransactionType) criteria.uniqueResult();
        return transactionType;
    }

    @Override
    public ImmunizationStoreTransactionType saveImmunizationStoreTransactionType(ImmunizationStoreTransactionType type) throws DAOException {
        return (ImmunizationStoreTransactionType) getSession().merge(type);
    }

    @Override
    public List<ImmunizationStoreDrug> getAllImmunizationStoreDrug() {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrug.class);
        List l = criteria.list();
        return l;
    }

    @Override
    public ImmunizationStoreDrug getImmunizationStoreDrugById(int id) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrug.class);
        criteria.add(Restrictions.eq("id", id));
        ImmunizationStoreDrug storeDrug = (ImmunizationStoreDrug) criteria.uniqueResult();
        return storeDrug;
    }

    @Override
    public ImmunizationStoreDrug getImmunizationStoreDrugByBatchNo(String batchNo) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrug.class);
        criteria.add(Restrictions.eq("batchNo", batchNo));
        ImmunizationStoreDrug storeDrug = (ImmunizationStoreDrug) criteria.uniqueResult();
        return storeDrug;
    }

    @Override
    public ImmunizationStoreDrug saveImmunizationStoreDrug(ImmunizationStoreDrug storeDrug) {
        return (ImmunizationStoreDrug) getSession().merge(storeDrug);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByType(ImmunizationStoreTransactionType transactionType) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        criteria.add(Restrictions.eq("transactionType", transactionType));
        List l = criteria.list();
        return l;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDrug(ImmunizationStoreDrug storeDrug) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        criteria.add(Restrictions.eq("storeDrug", storeDrug));
        List l = criteria.list();
        return l;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDate(Date createdOn) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        criteria.add(Restrictions.eq("createdOn", createdOn));
        List l = criteria.list();
        return l;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByPatient(Patient patient) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        criteria.add(Restrictions.eq("patient", patient));
        List l = criteria.list();
        return l;
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> getAllImmunizationStoreDrugTransactionDetail() {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        return criteria.list();

    }

    @Override
    public ImmunizationStoreDrugTransactionDetail getImmunizationStoreDrugTransactionDetailById(int id) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        criteria.add(Restrictions.eq("id", id));
        return (ImmunizationStoreDrugTransactionDetail) criteria.uniqueResult();
    }

    @Override
    public ImmunizationStoreDrugTransactionDetail saveImmunizationStoreDrugTransactionDetail(ImmunizationStoreDrugTransactionDetail transactionDetail) {
        return (ImmunizationStoreDrugTransactionDetail) getSession().merge(transactionDetail);
    }


    /*        ImmunizationEquipment     */
    @Override
    public List<ImmunizationEquipment> getAllImmunizationEquipments() {
        Criteria criteria = getSession().createCriteria(ImmunizationEquipment.class);
        return criteria.list();
    }

    @Override
    public ImmunizationEquipment getImmunizationEquipmentById(int id) {
        Criteria criteria = getSession().createCriteria(ImmunizationEquipment.class);
        criteria.add(Restrictions.eq("id", id));
        return (ImmunizationEquipment) criteria.uniqueResult();
    }

    @Override
    public ImmunizationEquipment getImmunizationEquipmentByType(String type) {
        Criteria criteria = getSession().createCriteria(ImmunizationEquipment.class);
        criteria.add(Restrictions.eq("equipmentType", type));
        return (ImmunizationEquipment) criteria.uniqueResult();
    }

    @Override
    public ImmunizationEquipment saveImmunizationEquipment(ImmunizationEquipment immunizationEquipment) {
        return (ImmunizationEquipment) getSession().merge(immunizationEquipment);
    }

    /*             ImmunizationStockout                  */

    @Override
    public List<ImmunizationStockout> getImmunizationStockoutByDrug(InventoryDrug drug) {
        Criteria criteria = getSession().createCriteria(ImmunizationStockout.class);
        criteria.add(Restrictions.eq("drug", drug));
        List l = criteria.list();
        return l;
    }

    @Override
    public ImmunizationStockout getImmunizationStockoutById(int id) {
        Criteria criteria = getSession().createCriteria(ImmunizationStockout.class);
        criteria.add(Restrictions.eq("id", id));
        return (ImmunizationStockout) criteria.uniqueResult();
    }

    @Override
    public ImmunizationStockout saveImmunizationStockout(ImmunizationStockout immunizationStockout) {
        return (ImmunizationStockout) getSession().merge(immunizationStockout);
    }

    @Override
    public List<ImmunizationStoreDrugTransactionDetail> listImmunizationReceipts(TransactionType type, String rcptNames, Date fromDate, Date toDate) {

        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrugTransactionDetail.class);
        criteria.add(Restrictions.eq("transactionType", getImmunizationStoreTransactionTypeById(type.getValue())));
        if (StringUtils.isNotEmpty(rcptNames)) {
            InventoryService service = Context.getService(InventoryService.class);
            List<InventoryDrug> drugs = service.findDrug(null, rcptNames);
            criteria.add(Restrictions.in("storeDrug.inventoryDrug",drugs));
        }
        if (fromDate != null && toDate != null) {
            //TODO check that the to date is not earlier than the from date - this should probably be handle from the interface!!
            criteria.add(Restrictions.between("createdOn", fromDate, toDate));
        } else if (fromDate != null && toDate == null) {
            criteria.add(Restrictions.ge("createdOn", fromDate));
        } else if (fromDate == null && toDate != null) {
            criteria.add(Restrictions.le("createdOn", toDate));
        }

        return criteria.list();
    }

    @Override
    public ImmunizationStoreTransactionType getImmunizationStoreTransactionTypeById(int id) {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreTransactionType.class);
        criteria.add(Restrictions.eq("id", id));
        return (ImmunizationStoreTransactionType) criteria.uniqueResult();
    }

    @Override
    public List<ImmunizationStoreTransactionType> getAllImmunizationStoreTransactionType() {
        Criteria criteria = getSession().createCriteria(ImmunizationStoreTransactionType.class);
        return criteria.list();
    }

    @Override
    public List<ImmunizationStoreDrug> getImmunizationStoreDrugByName(String drugName) {
        InventoryDrug inventoryDrug = Context.getService(InventoryService.class).getDrugByName(drugName);
        Criteria criteria = getSession().createCriteria(ImmunizationStoreDrug.class)
                .add(Restrictions.eq("inventoryDrug",inventoryDrug));
        return criteria.list();
    }

    private Session getSession() {
        return sessionFactory.getCurrentSession();
    }
}
