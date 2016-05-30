package org.openmrs.module.mchapp;

import java.util.Arrays;
import java.util.List;

public class MchProfileConcepts {
	public static final List<String> ANC_PROFILE_CONCEPTS = Arrays.asList(
			"1053AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" //parity
			,"5624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" //gravida
			,"1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" //lmp
			,"5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" //edd
			,"5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" //edd
			,"35c40649-86ae-4870-bc51-1de61cfb8bd6" //vdrl
			,"323d4f37-593b-4bd4-82d2-4c5ca2228a1f" //hb
			,"0a24f03e-9133-4401-b683-76c45e166912" //HIV Test
			,"81a00b02-0e75-4cfc-acd3-fd024f9c21a6" //HIV Re-test
			);
	public static final List<String> PNC_PROFILE_CONCEPTS = Arrays.asList(
			"5599AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", //date of delivery
			"f131507e-6acd-4bbe-afb5-4e39503e5a00", // place of delivery
			"a875ae0b-893c-47f8-9ebe-f721c8d0b130", //mode of delivery
			"5ddb1a3e-0e88-426c-939a-abf4776b024a" //state of bay
			);

}
