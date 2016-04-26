/**
 * 
 */
package org.openmrs.module.mchapp.api;

import java.util.Date;
import java.util.List;

import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.Patient;
/**
 * @author gwasilwa
 *
 */
public interface MchService {

	boolean enrolledInANC(Patient patient);

	void enrollInANC(Patient patient, Date dateEnrolled);

	boolean enrolledInPNC(Patient patient);

	void enrollInPNC(Patient patient, Date dateEnrolled);

	Encounter saveMchEncounter(Patient patient, List<Obs> encounterObservations, String program);

}
