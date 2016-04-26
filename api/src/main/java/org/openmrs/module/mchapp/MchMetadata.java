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
		public static final String ANC_PROGRAM_CONCEPT = "97d26859-c7e8-4c5a-a537-af8206536b3b";
		public static final String PNC_PROGRAM = "a15f2617-9f5d-4022-8de3-181b2e286a28";
		public static final String PNC_PROGRAM_CONCEPT = "451d7367-be84-468d-9703-e23410ae521f";
		public static final String CWC_PROGRAM = "34680469-1b6b-4ca3-b3f7-347463013dbd";
		public static final String CWC_PROGRAM_CONCEPT = "32255e8e-1ca8-43e3-a0e1-45f436f3bd44";
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
