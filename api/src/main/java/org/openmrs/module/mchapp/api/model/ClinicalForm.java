/**
 * 
 */
package org.openmrs.module.mchapp.api.model;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.context.Context;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.module.mchapp.api.parsers.DrugOrdersParser;
import org.openmrs.module.mchapp.api.parsers.InvestigationParser;
import org.openmrs.module.mchapp.api.parsers.ObsDatetimeUpdater;
import org.openmrs.module.mchapp.api.parsers.ObsParser;

/**
 * Contains observations, drug orders and test orders made by user
 *
 */
public class ClinicalForm {
	private Patient patient;
	private List<Obs> observations = new ArrayList<Obs>();
	private List<OpdDrugOrder> drugOrders = new ArrayList<OpdDrugOrder>();
	private List<OpdTestOrder> testOrders = new ArrayList<OpdTestOrder>();
	
	private ClinicalForm() {
	}

	public Patient getPatient() {
		return patient;
	}

	public List<Obs> getObservations() {
		return observations;
	}

	public List<OpdDrugOrder> getDrugOrders() {
		return drugOrders;
	}

	public List<OpdTestOrder> getTestOrders() {
		return testOrders;
	}

	@SuppressWarnings("unchecked")
	public static ClinicalForm generateForm(HttpServletRequest request, Patient patient, String location) throws ParseException {
		ClinicalForm form = new ClinicalForm();
		form.patient = patient;
		ObsParser obsParser = new ObsParser();
		for (Map.Entry<String, String[]> postedParams : ((Map<String, String[]>) 
				request.getParameterMap()).entrySet()) {
			form.observations = obsParser.parse(
					form.observations, patient, 
					postedParams.getKey(),
					postedParams.getValue());
			form.drugOrders = 
					DrugOrdersParser.parseDrugOrders(patient,
							form.drugOrders, 
							postedParams.getKey(),
							postedParams.getValue(), 
							location);
			InvestigationParser.parse(patient, 
					postedParams.getKey(), 
					postedParams.getValue(), 
					location, 
					Context.getAuthenticatedUser(), 
					new Date(), 
					form.testOrders);
		}
		if (request.getParameter("obsDatetime") != null) {
			SimpleDateFormat dateFormatter = new SimpleDateFormat("yyyy-MM-dd");
			dateFormatter.setLenient(false);
			Date obsDatetime = dateFormatter.parse(request.getParameter("obsDatetime"));
			form.observations = ObsDatetimeUpdater.updateDatetime(form.observations, obsDatetime);
		}
		return form;
	}

}
