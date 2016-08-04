package org.openmrs.module.mchapp;

import org.openmrs.Program;
import org.openmrs.module.metadatadeploy.bundle.AbstractMetadataBundle;
import org.springframework.stereotype.Component;

import static org.openmrs.module.metadatadeploy.bundle.CoreConstructors.*;

@Component
public class MchMetadata extends AbstractMetadataBundle {

    public static final class _AncConstantConceptQuestions {
        public static final String PARITY = "1053AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String GRAVIDA = "5624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String LAST_MENSTRUAL_PERIOD = "1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    }

    public static final class MchAppConstants {
        public static final String CWC_FOLLOW_UP = "6f7b4285-a04b-4f8b-be85-81c325289539";
        public static final String CWC_BREASTFEEDING_COUNCELLING = "42197783-8b24-49b0-b290-cbb368fa0113";
        public static final String CWC_BREASTFEEDING_EXCLUSSIVE = "42197783-8b24-49b0-b290-cbb368fa0113";
        public static final String CWC_BREASTFEEDING_FOR_INFECTED = "8a3c420e-b4ff-4710-81fd-90c7bfa6de72";

        public static final String CWC_EXAMINATION_CLASS = "8d491a9a-c2cc-11de-8d13-0010c6dffd0f";
        public static final String CWC_EXAMINATION_DATATYPE = "8d4a48b6-c2cc-11de-8d13-0010c6dffd0f";

        public static final String MCH_HIV_PRIOR_STATUS = "1406dbf3-05da-4264-9659-fb688cea5809";
        public static final String MCH_HIV_PARTNER_TESTED = "93366255-8903-44af-8370-3b68c0400930";
        public static final String MCH_HIV_PARTNER_STATUS = "df68a879-70c4-40d5-becc-a2679b174036";
        public static final String MCH_HIV_COUPLE_COUNCELLED = "27b96311-bc00-4839-b7c9-31401b44cd3a";

        public static final String PNC_EXCERCISE = "ba18b0c3-8208-465a-9c95-2f85047e2939";
        public static final String PNC_MULTIVITAMIN = "5712097d-a478-4ff4-a2aa-bd827a6833ed";
        public static final String PNC_VITAMIN_A = "c764e84f-cfb2-424a-acec-20e4fb8531b7";
        public static final String PNC_HAEMATINICS = "5d935a14-9c53-4171-bda7-51da05fbb9eb";
        public static final String PNC_FAMILY_PLANNING = "374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

        public static final String ANC_FEEDING_COUNCELLING = "fb5a5471-e912-4288-8c25-750f7f88281f";
        public static final String ANC_FEEDING_EXCLUSSIVE = "42197783-8b24-49b0-b290-cbb368fa0113";
        public static final String ANC_FEEDING_INFECTED = "8a3c420e-b4ff-4710-81fd-90c7bfa6de72";
        public static final String ANC_FEEDING_DECISION = "a0bf86bb-b50e-4be4-a54c-32518bfb843f";

        public static final String ANC_EXCERCISE = "0a92efcc-51b3-448d-b4e3-a743ea5aa18c";
        public static final String ANC_DEWORMING = "159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        public static final String ANC_LLITN = "160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        
        public static final String PNC_CERVICAL_SCREENING_METHOD = "50c026c3-f2bc-44b9-a9dd-e972ffcbb774";
        public static final String PNC_CERVICAL_SCREENING_RESULT = "1406dbf3-05da-4264-9659-fb688cea5809";
    }

    public static final class MchAppTriageConstants {
    	public static final String PULSE_RATE = "5087AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    	public static final String HEIGHT = "5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    	public static final String WEIGHT = "5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    	public static final String SYSTOLIC = "6aa7eab2-138a-4041-a87f-00d9421492bc";
    	public static final String DAISTOLIC = "5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    	public static final String TEMPERATURE = "5088AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    	public static final String MUAC = "b7112b6c-de10-42ee-b54d-2e1be98cd2d6";
    	public static final String GROWTH_STATUS = "562a6c3e-519b-4a50-81be-76ca67b5d5ec";
    	public static final String WEIGHT_CATEGORY = "1854AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
    	
    }
    public static final class _MchEncounterType {
        public static final String ANC_ENCOUNTER_TYPE = "40629059-f621-42bd-a7c4-bd22e2636e47";
        public static final String ANC_TRIAGE_ENCOUNTER_TYPE = "2540f75d-7af5-472e-92d7-546d1add0759";
        public static final String PNC_ENCOUNTER_TYPE = "c87a3883-90f9-43a1-a972-7f615ed44e03";
        public static final String PNC_TRIAGE_ENCOUNTER_TYPE = "91a5f5c0-858d-496e-a83e-e826af5205eb";
        public static final String CWC_ENCOUNTER_TYPE = "3aa0a23d-6f0e-43b3-ae8a-912ac0bbf129";
        public static final String CWC_TRIAGE_ENCOUNTER_TYPE = "e341b3ba-186c-4638-a5d1-32a7a373b62a";
    }

    public static final class _MchProgram {
        public static final String ANC_PROGRAM = "d83b74b7-f5ea-46fc-acc5-71e892ee1e68";
        public static final String ANC_PROGRAM_CONCEPT = "ae6a8bba-b7cd-4e2f-8c87-720c86966666";
        public static final String PNC_PROGRAM = "a15f2617-9f5d-4022-8de3-181b2e286a28";
        public static final String PNC_PROGRAM_CONCEPT = "f5d0b8a9-aacc-4d78-9c9e-792197debc77";
        public static final Integer INITIAL_MCH_CLINIC_VISIT = 2;
        public static final Integer RETURN_ANC_CLINIC_VISIT = 3;
        public static final Integer RETURN_PNC_CLINIC_VISIT = 4;
        public static final Integer RETURN_CWC_CLINIC_VISIT = 5;

        /*CWC PROGRAM, WORKFLOW AND STATE CONCEPTS*/
        public static final String CWC_PROGRAM = "34680469-1b6b-4ca3-b3f7-347463013dbd";
        public static final String CWC_PROGRAM_CONCEPT = "db98069c-521d-4680-98a0-ee52bed4b815";


        public static final String PNC_DELIVERY_MODES = "a875ae0b-893c-47f8-9ebe-f721c8d0b130";
        public static final String MCH_WEIGHT_CATEGORIES = "1854AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";

        //temporary
        public static final String MCH_GROWTH_MONITOR = "562a6c3e-519b-4a50-81be-76ca67b5d5ec";
    }

    @Override
    public void install() throws Exception {
        install(encounterType("ANCENCOUNTER", "ANC encounter type", _MchEncounterType.ANC_ENCOUNTER_TYPE));
        install(encounterType("ANCTRIAGEENCOUNTER", "ANC triage encounter type", _MchEncounterType.ANC_TRIAGE_ENCOUNTER_TYPE));
        install(encounterType("PNCENCOUNTER", "PNC encounter type", _MchEncounterType.PNC_ENCOUNTER_TYPE));
        install(encounterType("PNCTRIAGEENCOUNTER", "PNC triage encounter type", _MchEncounterType.PNC_TRIAGE_ENCOUNTER_TYPE));
        install(encounterType("CWCENCOUNTER", "CWC encounter type", _MchEncounterType.CWC_ENCOUNTER_TYPE));
        install(encounterType("CWCTRIAGEENCOUNTER", "CWC triage encounter type", _MchEncounterType.CWC_TRIAGE_ENCOUNTER_TYPE));

        if (possible(Program.class, _MchProgram.ANC_PROGRAM) == null) {
            install(program("Antenatal Care Program", "ANC Program", _MchProgram.ANC_PROGRAM_CONCEPT, _MchProgram.ANC_PROGRAM));
        }
        if (possible(Program.class, _MchProgram.PNC_PROGRAM) == null) {
            install(program("Postnatal Care Program", "PNC Program", _MchProgram.PNC_PROGRAM_CONCEPT, _MchProgram.PNC_PROGRAM));
        }
        if (possible(Program.class, _MchProgram.CWC_PROGRAM) == null) {
            install(program("Child Welfare Program", "CW Program", _MchProgram.CWC_PROGRAM_CONCEPT, _MchProgram.CWC_PROGRAM));
        }
    }

}
