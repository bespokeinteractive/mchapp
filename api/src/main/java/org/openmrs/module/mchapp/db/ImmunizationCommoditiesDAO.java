package org.openmrs.module.mchapp.db;

import org.openmrs.Patient;
import org.openmrs.api.db.DAOException;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;

import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 *         Create on 8/24/2016.
 *         Interface that declares the functionalities to be implemented by the implementing class that enters into a contract with it
 */
public interface ImmunizationCommoditiesDAO {

    //    TODO Behaviours for implementing the Immunization functionalities
    List<ImmunizationStoreDrug> listImmunizationStoreDrug(String name, int min, int max) throws DAOException;

    /*    ImmunizationStoreTransactionType     */

    /**
     * Gets the list of all @see ImmunizationStoreTransactionType stored in the database
     *
     * @return list of all ImmunizationStoreTransactionType
     */
    List<ImmunizationStoreTransactionType> getAllTransactionTypes();

    ImmunizationStoreTransactionType getTransactionTypeByName(String name);

    ImmunizationStoreTransactionType getTransactionTypeById(int id);

    ImmunizationStoreTransactionType saveImmunizationStoreTransactionType(ImmunizationStoreTransactionType type);


    /*        ImmunizationStoreDrug     */
    List<ImmunizationStoreDrug> getAllImmunizationStoreDrug();

    ImmunizationStoreDrug getImmunizationStoreDrugById(int id);

    ImmunizationStoreDrug getImmunizationStoreDrugByBatchNo(String batchNo);

    ImmunizationStoreDrug saveImmunizationStoreDrug(ImmunizationStoreDrug storeDrug);


    /*  ImmunizationStoreDrugTransactionDetail    */
    List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByType(ImmunizationStoreTransactionType transactionType);

    List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDrug(ImmunizationStoreDrug drug);

    List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByDate(Date date);

    List<ImmunizationStoreDrugTransactionDetail> getImmunizationStoreDrugTransactionDetailByPatient(Patient patient);

    List<ImmunizationStoreDrugTransactionDetail> getAllImmunizationStoreDrugTransactionDetail();

    ImmunizationStoreDrugTransactionDetail getImmunizationStoreDrugTransactionDetailById(int id);


}
