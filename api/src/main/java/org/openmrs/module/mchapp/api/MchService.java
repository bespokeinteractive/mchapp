/**
 * 
 */
package org.openmrs.module.mchapp.api;

import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
import org.openmrs.ui.framework.SimpleObject;

import java.util.Date;
import java.util.List;

/**
 * @author gwasilwa
 *
 */
public interface MchService {

	boolean enrolledInANC(Patient patient);

	SimpleObject enrollInANC(Patient patient, Date dateEnrolled);

	boolean enrolledInPNC(Patient patient);

	SimpleObject enrollInPNC(Patient patient, Date dateEnrolled);

	Encounter saveMchEncounter(Patient patient, List<Obs> encounterObservations, String program);

}
