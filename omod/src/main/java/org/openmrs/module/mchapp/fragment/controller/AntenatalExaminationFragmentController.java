package org.openmrs.module.mchapp.fragment.controller;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;

import org.openmrs.*;
import org.openmrs.api.context.Context;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.hospitalcore.PatientQueueService;
import org.openmrs.module.hospitalcore.model.*;
import org.openmrs.module.hospitalcore.util.ActionValue;
import org.openmrs.module.hospitalcore.util.FlagStates;
import org.openmrs.module.inventory.InventoryService;
import org.openmrs.module.inventory.model.ToxoidModel;
import org.openmrs.module.inventory.util.DateUtils;
import org.openmrs.module.mchapp.InternalReferral;
import org.openmrs.module.mchapp.MchMetadata;
import org.openmrs.module.mchapp.MchStores;
import org.openmrs.module.mchapp.api.MchEncounterService;
import org.openmrs.module.mchapp.api.MchService;
import org.openmrs.module.mchapp.api.model.ClinicalForm;
import org.openmrs.module.mchapp.api.parsers.QueueLogs;
import org.openmrs.module.patientdashboardapp.model.Referral;
import org.openmrs.module.patientdashboardapp.model.ReferralReasons;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.fragment.FragmentConfiguration;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestParam;

import java.math.BigDecimal;
import java.util.Date;


/**
 * Created by qqnarf on 5/18/16.
 */
public class AntenatalExaminationFragmentController {
    protected Logger log = LoggerFactory.getLogger(getClass());

    public void controller(FragmentModel model, FragmentConfiguration config, UiUtils ui) {
        config.require("patientId");
        config.require("queueId");
        Patient patient = Context.getPatientService().getPatient(Integer.parseInt(config.get("patientId").toString()));
        model.addAttribute("patient", patient);
        model.addAttribute("patientProfile", PatientProfileGenerator.generatePatientProfile(patient, MchMetadata._MchProgram.ANC_PROGRAM));
        model.addAttribute("internalReferrals", SimpleObject.fromCollection(Referral.getInternalReferralOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("externalReferrals", SimpleObject.fromCollection(Referral.getExternalReferralOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("referralReasons", SimpleObject.fromCollection(ReferralReasons.getReferralReasonsOptions(), ui, "label", "id", "uuid"));
        model.addAttribute("queueId", config.get("queueId"));
        model.addAttribute("tetanusVaccines", getTetanusToxoid(patient, ui));
        model.addAttribute("tetanusBatchNo", MchStores.getBatchesForSelectedDrug(ui, 188));
        model.addAttribute("preExisitingConditions", Context.getService(MchEncounterService.class).getConditions(patient));
    }

    public SimpleObject saveAntenatalExaminationInformation(
            @RequestParam("patientId") Patient patient,
            @RequestParam("queueId") Integer queueId,
            UiSessionContext session,
            HttpServletRequest request) {
        OpdPatientQueue patientQueue = Context.getService(
                PatientQueueService.class).getOpdPatientQueueById(queueId);
        String location = "ANC Exam Room";
        if (patientQueue != null) {
            location = patientQueue.getOpdConceptName();
        }
        try {
            ClinicalForm form = ClinicalForm.generateForm(request, patient, location);
            InternalReferral internalReferral = new InternalReferral();
            Encounter encounter = Context.getService(MchService.class).saveMchEncounter(form,
                    MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE, session.getSessionLocation());
            String refferedRoomUuid = request.getParameter("internalRefferal");
            if (refferedRoomUuid != "" && refferedRoomUuid != null && !refferedRoomUuid.equals(0) && !refferedRoomUuid.equals("0")) {
                internalReferral.sendToRefferedRoom(patient, refferedRoomUuid);
            }
            QueueLogs.logOpdPatient(patientQueue, encounter);

            return SimpleObject.create("status", "success", "message",
                    "Triage information has been saved.");
        } catch (NullPointerException e) {
            log.error(e.getMessage());
            return SimpleObject.create("status", "error", "message",
                    e.getMessage());
        } catch (ParseException e) {
            log.error(e.getMessage());
            return SimpleObject.create("status", "error", "message",
                    e.getMessage());
        }
    }

    public List<SimpleObject> getTetanusToxoid(Patient patient, UiUtils ui) {
        InventoryService service = Context.getService(InventoryService.class);
        List<ToxoidModel> list = new ArrayList<ToxoidModel>();
        try {
            list = service.getTetanusToxoidTransactions(patient.getPatientId());
        } catch (Exception e) {
            log.error("Error Pulling Toxoid Details", e);
        }
        return SimpleObject.fromCollection(list, ui, "vaccineName", "dateGiven", "dateRecorded", "provider");
    }

    public String saveTetanusToxoid(@RequestParam(value = "patientId", required = false) Patient patient,
                                   @RequestParam(value = "drugId", required = false) Integer drugId,
                                   @RequestParam(value = "formulation", required = false) Integer formulation,
                                   @RequestParam(value = "frequency", required = false) String frequency,
                                   @RequestParam(value = "injDate", required = false) Date injDate,
                                   @RequestParam(value = "batchNo", required = false) String batchNo,
                                    UiSessionContext session) {
        InventoryService inventoryService = (InventoryService) Context
                .getService(InventoryService.class);
        InventoryStore store = inventoryService.getStoreById(4);

        Encounter encounter = new Encounter();
        EncounterType mchEncounterType = Context.getEncounterService().getEncounterTypeByUuid(MchMetadata._MchEncounterType.ANC_ENCOUNTER_TYPE);

        encounter.setPatient(patient);
        encounter.setLocation(session.getSessionLocation());
        encounter.setEncounterDatetime(new Date());
        encounter.setEncounterType(mchEncounterType);
        encounter = Context.getEncounterService().saveEncounter(encounter);

        InventoryStoreDrugPatient inventoryStoreDrugPatient = new InventoryStoreDrugPatient();
        InventoryStoreDrugPatientDetail inventoryStoreDrugPatientDetail = new InventoryStoreDrugPatientDetail();

        InventoryStoreDrugTransaction transaction = new InventoryStoreDrugTransaction();
        transaction.setDescription("DISPENSE TETANUS TOXOID " + DateUtils.getDDMMYYYY());
        transaction.setStore(store);
        transaction.setTypeTransaction(ActionValue.TRANSACTION[1]);
        transaction.setCreatedOn(new Date());
        transaction.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
        transaction = inventoryService.saveStoreDrugTransaction(transaction);

        //for (InventoryStoreDrugPatientDetail pDetail : listDrugIssue) {
        Date date1 = new Date();
        try {
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        Integer totalQuantity = inventoryService.sumCurrentQuantityDrugOfStore(store.getId(), drugId, formulation);

        InventoryStoreDrugTransactionDetail transDetail = new InventoryStoreDrugTransactionDetail();
        transDetail.setTransaction(transaction);
        transDetail.setCurrentQuantity(0);
        transDetail.setIssueQuantity(1);
        transDetail.setOpeningBalance(totalQuantity);
        transDetail.setClosingBalance(totalQuantity -1);
        transDetail.setQuantity(0);
        transDetail.setVAT(BigDecimal.ZERO);
        transDetail.setCostToPatient(BigDecimal.ZERO);
        transDetail.setUnitPrice(BigDecimal.ZERO);
        transDetail.setDrug(inventoryService.getDrugById(drugId));
        transDetail.setFormulation(inventoryService.getDrugFormulationById(formulation));
        transDetail.setBatchNo(batchNo);
        transDetail.setEncounter(encounter);
        transDetail.setPatientType("mchClinic");

//            transDetail.setCompanyName(pDetail.getTransactionDetail()
//                    .getCompanyName());
//            transDetail.setDateManufacture(pDetail.getTransactionDetail()
//                    .getDateManufacture());
//            transDetail.setDateExpiry(pDetail.getTransactionDetail()
//                    .getDateExpiry());
//            transDetail.setReceiptDate(pDetail.getTransactionDetail()
//                    .getReceiptDate());

        transDetail.setCreatedOn(injDate);
        transDetail.setReorderPoint(0);
        transDetail.setAttribute("B");
        transDetail.setFrequency(Context.getConceptService().getConceptByName(frequency));
        transDetail.setNoOfDays(1);
        transDetail.setFlag(FlagStates.FULLY_PROCESSED);
        transDetail.setTotalPrice(BigDecimal.ZERO);
        transDetail = inventoryService.saveStoreDrugTransactionDetail(transDetail);

        inventoryStoreDrugPatient.setStore(store);
        inventoryStoreDrugPatient.setPatient(patient);
        inventoryStoreDrugPatient.setName(patient.getPersonName().toString());
        inventoryStoreDrugPatient.setIdentifier(patient.getIdentifiers().toString());
        inventoryStoreDrugPatient.setCreatedBy(Context.getAuthenticatedUser().getGivenName());
        inventoryStoreDrugPatient.setCreatedOn(date1);
        inventoryStoreDrugPatient.setValues(0);
        inventoryStoreDrugPatient.setStatuss(0);
        inventoryStoreDrugPatient.setComment("");
        inventoryStoreDrugPatient.setWaiverAmount(BigDecimal.ZERO);
        inventoryStoreDrugPatient.setPrescriber(Context.getAuthenticatedUser());
        inventoryStoreDrugPatient = inventoryService.saveStoreDrugPatient(inventoryStoreDrugPatient);

        inventoryStoreDrugPatientDetail.setStoreDrugPatient(inventoryStoreDrugPatient);
        inventoryStoreDrugPatientDetail.setTransactionDetail(transDetail);
        inventoryStoreDrugPatientDetail.setQuantity(1);
        inventoryStoreDrugPatientDetail = inventoryService.saveStoreDrugPatientDetail(inventoryStoreDrugPatientDetail);

        return "success";
    }
}