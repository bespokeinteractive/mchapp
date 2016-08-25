package org.openmrs.module.mchapp.api;

import org.openmrs.api.OpenmrsService;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * @author Stanslaus Odhiambo
 * Created on 8/25/2016.
 */
@Transactional
public interface ImmunizationService extends OpenmrsService {
    List<ImmunizationStoreTransactionType> getAllTransactionTypes();

}
