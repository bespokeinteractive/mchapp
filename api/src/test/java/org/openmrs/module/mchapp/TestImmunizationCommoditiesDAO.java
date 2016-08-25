package org.openmrs.module.mchapp;

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
       
//        ImmunizationStoreTransactionType transactionType=new ImmunizationStoreTransactionType();
//        transactionType.setId(1);
//        transactionType.setTransactionType("Test Type");
//        List<ImmunizationStoreTransactionType> allTransactionTypes= commoditiesDAO.getAllTransactionTypes();
//        Assert.assertEquals(0, allTransactionTypes.size());
    }

}
