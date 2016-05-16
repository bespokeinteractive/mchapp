package org.openmrs.module.mchapp;

import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.*;

@Component
public class MchMetadata extends AbstractMetadataBundle{

	public static final class _MchEncounterType {
		public static final String ANC_ENCOUNTER_TYPE = "40629059-f621-42bd-a7c4-bd22e2636e47";
		public static final String PNC_ENCOUNTER_TYPE = "c87a3883-90f9-43a1-a972-7f615ed44e03";
		public static final String CWC_ENCOUNTER_TYPE = "3aa0a23d-6f0e-43b3-ae8a-912ac0bbf129";
	}
	
	public static final class _MchProgram {
		public static final String ANC_PROGRAM = "d83b74b7-f5ea-46fc-acc5-71e892ee1e68";
		public static final String ANC_PROGRAM_CONCEPT = "ae6a8bba-b7cd-4e2f-8c87-720c86966666";
		public static final String PNC_PROGRAM = "a15f2617-9f5d-4022-8de3-181b2e286a28";
		public static final String PNC_PROGRAM_CONCEPT = "f5d0b8a9-aacc-4d78-9c9e-792197debc77";

		/*CWC PROGRAM, WORKFLOW AND STATE CONCEPTS*/
		public static final String CWC_PROGRAM = "34680469-1b6b-4ca3-b3f7-347463013dbd";
		public static final String CWC_PROGRAM_CONCEPT = "db98069c-521d-4680-98a0-ee52bed4b815";

		public static final String CWC_BCG_WORKFLOW = "PENDING";
		public static final String CWC_POLIO_WORKFLOW = "PENDING";
		public static final String CWC_MEASLES_WORKFLOW = "PENDING";
		public static final String CWC_DTP_WORKFLOW = "PENDING";
		public static final String CWC_PNEUMOCOCCAL_WORKFLOW = "PENDING";
		public static final String CWC_ROTARIX_WORKFLOW = "PENDING";
		public static final String CWC_YELLOW_FEVER_WORKFLOW = "PENDING";

		public static final String CWC_BCG_WORKFLOW_STATE = "PENDING";
		public static final String CWC_POLIO_WORKFLOW_STATE  = "PENDING";
		public static final String CWC_MEASLES_WORKFLOW_STATE  = "PENDING";




	}

	@Override
	public void install() throws Exception {
		// TODO Auto-generated method stub
		install(encounterType("ANCENCOUNTER", "ANC encounter type", _MchEncounterType.ANC_ENCOUNTER_TYPE));
		install(encounterType("PNCENCOUNTER", "PNC encounter type", _MchEncounterType.PNC_ENCOUNTER_TYPE));
		install(encounterType("CWCENCOUNTER", "CWC encounter type", _MchEncounterType.CWC_ENCOUNTER_TYPE));
		
		install(program("Antenatal Care Program", "ANC Program", _MchProgram.ANC_PROGRAM_CONCEPT, _MchProgram.ANC_PROGRAM));
		install(program("Postnatal Care Program", "PNC Program", _MchProgram.PNC_PROGRAM_CONCEPT, _MchProgram.PNC_PROGRAM));
		install(program("Child Welfare Program", "CW Program", _MchProgram.CWC_PROGRAM_CONCEPT, _MchProgram.CWC_PROGRAM));
	}

}
