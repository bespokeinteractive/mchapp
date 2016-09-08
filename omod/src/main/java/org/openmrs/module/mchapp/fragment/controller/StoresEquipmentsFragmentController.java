package org.openmrs.module.mchapp.fragment.controller;

import org.openmrs.Person;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.api.ImmunizationService;
import org.openmrs.module.mchapp.model.ImmunizationEquipment;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Date;
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

        List<ImmunizationEquipment>  immunizationEquipments= immunizationService.listImmunizationEquipment(equipmentName, equipmentType);
        return SimpleObject.fromCollection(immunizationEquipments, uiUtils, "id", "equipmentType", "model", "workingStatus", "energySource", "dateOfManufacture");
    }

    public SimpleObject getImmunizationEquipmentDetails(UiUtils uiUtils,
                                                        @RequestParam("equipmentId") Integer equipmentId) {

        ImmunizationEquipment immunizationEquipments = immunizationService.getImmunizationEquipmentById(equipmentId);
        return SimpleObject.fromObject(immunizationEquipments, uiUtils, "id", "equipmentType", "model", "workingStatus", "energySource", "dateOfManufacture", "remarks");
    }

    public SimpleObject saveImmunizationEquipment(UiUtils uiUtils, @RequestParam("equipementTypeName") String equipementTypeName,
                                                 @RequestParam("equipementModel") String equipementModel,
                                                 @RequestParam("dateManufactured") Date dateManufactured,
                                                 @RequestParam( "equipementEnergySource") String equipementEnergySource,
                                                 @RequestParam( "equipementStatus") boolean equipementStatus,
                                                 @RequestParam(value = "equipementRemarks", required = false) String equipementRemarks) {
        Person person = Context.getAuthenticatedUser().getPerson();
        ImmunizationEquipment equipment=new ImmunizationEquipment();
        equipment.setCreatedOn(new Date());
        equipment.setCreatedBy(person.getGivenName());
        equipment.setEnergySource(equipementEnergySource);
        equipment.setEquipmentType(equipementTypeName);
        equipment.setModel(equipementModel);
        equipment.setRemarks(equipementRemarks);
        equipment.setWorkingStatus(equipementStatus);
        equipment.setDateOfManufacture(dateManufactured);
        equipment = immunizationService.saveImmunizationEquipment(equipment);
        if (equipment != null) {
            return SimpleObject.create("status", "success","message","Equipment Saved Successfully");
        } else {
            return SimpleObject.create("status", "error","message","Error occurred while saving Equipment");
        }
    }

    public SimpleObject updateImmunizationEquipment(UiUtils uiUtils, @RequestParam("equipementId") Integer equipementId,
                                                  @RequestParam( "equipementStatus") boolean equipementStatus,
                                                  @RequestParam(value = "equipementRemarks", required = false) String equipementRemarks) {
        ImmunizationEquipment equipment = immunizationService.getImmunizationEquipmentById(equipementId);
        equipment.setRemarks(equipementRemarks);
        equipment.setWorkingStatus(equipementStatus);
        equipment = immunizationService.saveImmunizationEquipment(equipment);

        if (equipment != null) {
            return SimpleObject.create("status", "success","message","Equipment status updated Successfully");
        } else {
            return SimpleObject.create("status", "error","message","Error occurred while updating Equipment");
        }
    }
}
