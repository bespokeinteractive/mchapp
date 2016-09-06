package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationEquipment;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

/**
 * @author Stanslaus Odhiambo
 * Created on 9/4/2016.
 */
public class StoresEquipmentsFragmentController {
    private ImmunizationService immunizationService = Context.getService(ImmunizationService.class);

    //    Default handler for GET and POST requests if none exist
    public void controller() {
    }

    public List<SimpleObject> listImmunizationEquipment(UiUtils uiUtils,
                                                     @RequestParam(value = "equipmentName", required = false) String equipmentName,
                                                     @RequestParam(value = "equipmentType", required = false) String equipmentType) {

        List<ImmunizationEquipment>  immunizationEquipments= immunizationService.listImmunizationEquipment(equipmentName,equipmentType);
        return SimpleObject.fromCollection(immunizationEquipments, uiUtils, "equipmentType", "model", "workingStatus", "energySource", "ageInYears");
    }
}
