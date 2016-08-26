package org.openmrs.module.mchapp;

import org.junit.Assert;
import org.junit.Test;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationStoreTransactionType;
import org.openmrs.test.BaseModuleContextSensitiveTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * @author Stanslaus Odhiambo
 * Created on 8/25/2016.
 */

public class TestImmunizationCommoditiesDAO extends BaseModuleContextSensitiveTest {


    @Test
    @Transactional
    @Rollback(true)
    public void testAddImmunizationStoreTransactionType()
    {
        ImmunizationService service = Context.getService(ImmunizationService.class);
        List<ImmunizationStoreTransactionType> allTransactionTypes = service.getAllTransactionTypes();
        Assert.assertEquals(allTransactionTypes.size(),0);
        ImmunizationStoreTransactionType type=new ImmunizationStoreTransactionType();
        type.setTransactionType("Trial Test");
        ImmunizationStoreTransactionType transactionType = service.saveImmunizationStoreTransactionType(type);
        allTransactionTypes = service.getAllTransactionTypes();
        Assert.assertEquals(allTransactionTypes.size(), 1);

    }

}
