package org.openmrs.module.mchapp.api.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.impl.BaseOpenmrsService;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.db.ImmunizationCommoditiesDAO;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;

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
}
