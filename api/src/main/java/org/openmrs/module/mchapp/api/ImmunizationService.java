package org.openmrs.module.mchapp.api;

import org.openmrs.Patient;
import org.openmrs.api.OpenmrsService;
import org.openmrs.api.db.DAOException;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrug;
import org.openmrs.module.mchapp.model.ImmunizationStoreDrugTransactionDetail;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

/**
 * @author Stanslaus Odhiambo
 * Created on 8/25/2016.
 */
@Transactional
public interface ImmunizationService extends OpenmrsService {
    List<ImmunizationStoreTransactionType> getAllTransactionTypes();
    ImmunizationStoreTransactionType getTransactionTypeByName(String name);

    ImmunizationStoreTransactionType getTransactionTypeById(int id);

    ImmunizationStoreTransactionType saveImmunizationStoreTransactionType(ImmunizationStoreTransactionType type) throws DAOException;


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

    ImmunizationStoreDrugTransactionDetail saveImmunizationStoreDrugTransactionDetail(ImmunizationStoreDrugTransactionDetail transactionDetail);
}
