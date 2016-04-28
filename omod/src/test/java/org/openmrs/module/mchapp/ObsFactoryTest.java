package org.openmrs.module.mchapp;

import org.hamcrest.Matchers;
import org.junit.Assert;
import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.test.BaseModuleContextSensitiveTest;

public class ObsFactoryTest extends BaseModuleContextSensitiveTest {

	@Test
	public void getObsProcessor_shouldReturnCodedObsProcessorWhenConceptDataTypeIsCoded() {
		Concept codedConcept = Context.getConceptService().getConcept(4);
		
		ObsProcessor codedObsProcessor = ObsFactory.getObsProcessor(codedConcept);
		
		Assert.assertThat(codedObsProcessor, Matchers.instanceOf(CodedObsProcessor.class));
	}
	
	@Test public void getObsProcessor_shouldReturnNumericObsProcessorWhenConceptDataTypeIsNumeric() {
		Concept numericConcept = Context.getConceptService().getConcept(5089);
		
		ObsProcessor numericObsProcessor = ObsFactory.getObsProcessor(numericConcept);
		
		Assert.assertThat(numericObsProcessor, Matchers.instanceOf(NumericObsProcessor.class));
	}
	
	@Test public void getObsProcessor_shouldReturnDateTimeObsProcessorWhenConceptDataTypeIsDateTime() {
		Concept dateTimeConcept = Context.getConceptService().getConcept(20);
		
		ObsProcessor dateTimeObsProcessor = ObsFactory.getObsProcessor(dateTimeConcept);
		
		Assert.assertThat(dateTimeObsProcessor, Matchers.instanceOf(DateTimeObsProcessor.class));
	}
	
	@Test public void getObsProcessor_shouldReturnTextObsProcessorWhenDataTypeIsText() {
		Concept textConcept = Context.getConceptService().getConcept(19);
		
		ObsProcessor textObsProcessor = ObsFactory.getObsProcessor(textConcept);
		
		Assert.assertThat(textObsProcessor, Matchers.instanceOf(TextObsProcessor.class));
	}
	
	@Test public void getObsProcessor_shouldReturnTextObsProcessorAsDefaultObsProcessor() {
		Concept textConcept = Context.getConceptService().getConcept(13);
		
		ObsProcessor textObsProcessor = ObsFactory.getObsProcessor(textConcept);
		
		Assert.assertThat(textObsProcessor, Matchers.instanceOf(TextObsProcessor.class));
	}

}
