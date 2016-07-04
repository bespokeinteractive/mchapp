/**
 * 
 */
package org.openmrs.module.mchapp.api;

import org.openmrs.Encounter;
import org.openmrs.Location;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.api.APIException;
import org.openmrs.module.hospitalcore.model.OpdDrugOrder;
import org.openmrs.module.hospitalcore.model.OpdTestOrder;
import org.openmrs.ui.framework.SimpleObject;

import java.text.ParseException;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * @author gwasilwa
 *
 */
public interface MchService {

	boolean enrolledInANC(Patient patient);
	SimpleObject enrollInANC(Patient patient, Date dateEnrolled);

	boolean enrolledInPNC(Patient patient);
	SimpleObject enrollInPNC(Patient patient, Date dateEnrolled);

	boolean enrolledInCWC(Patient patient);
	SimpleObject enrollInCWC(Patient patient, Date dateEnrolled,Map<String,String> cwcInitialStates);
	Encounter saveMchEncounter(Patient patient, List<Obs> encounterObservations, List<OpdDrugOrder> drugOrders,
							   List<OpdTestOrder> testOrders, String program, Location location,Integer visitTypeId);
	Encounter saveMchEncounter(Patient patient, List<Obs> encounterObservations, List<OpdDrugOrder> drugOrders,
							   List<OpdTestOrder> testOrders, String program, Location location);
	
	List<Obs> getPatientProfile(Patient patient, String program);

	List<Obs> getHistoricalPatientProfile(Patient patient, String programUuid);

	List<ListItem> getPossibleOutcomes(Integer programId);
	public void updatePatientProgram(Integer patientProgramId, String enrollmentDateYmd, String completionDateYmd,
									 Integer locationId, Integer outcomeId) throws ParseException ;
	public List<Object> findVisitsByPatient(Patient patient, boolean includeInactive, boolean includeVoided, Date dateEnrolled)
			throws APIException;

}
