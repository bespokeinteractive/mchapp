/**
 * 
 */
package org.openmrs.module.mchapp.api;

import java.util.Date;

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

}
