package org.openmrs.module.mchapp.model;

import org.openmrs.Concept;
import org.openmrs.Encounter;
import org.openmrs.Obs;
import org.openmrs.api.context.Context;
import org.openmrs.module.mchapp.MchMetadata;

public class TriageDetail   {
	private String weight="Not Specified";
	private String height="Not Specified";
	private String muac="Not Specified";
	private String pulseRate="Not Specified";
	private String temperature="Not Specified";
	private String systolic="Not Specified";
	private String daistolic="Not Specified";
	private String growthStatus="Not Specified";
	private String weightCategory="Not Specified";
	public String getWeightcategory() {
		return weightCategory;
	}

	public void setWeightCategory(String weightcategory) {
		this.weightCategory = weightcategory;
	}
	public String getGrowthStatus() {
		return growthStatus;
	}

	public void setGrowthStatus(String growthstatus) {
		this.growthStatus = growthstatus;
	}
	public String getMuac() {
		return muac;
	}

	public void setMua(String muac) {
		this.muac = muac;
	}
	public String getWeight() {
		return weight;
	}

	public void setWeight(String weight) {
		this.weight = weight;
	}
	public String getHeight() {
		return height;
	}

	public void setHeight(String height) {
		this.height = height;
	}
	public String getTemperature() {
		return temperature;
	}

	public void setTemperature(String temperature) {
		this.temperature = temperature;
	}

	public String getSystolic() {
		return systolic;
	}

	public void setSystolic(String systolic) {
		this.systolic = systolic;
	}

	public String getDaistolic() {
		return daistolic;
	}

	public void setDaistolic(String daistolic) {
		this.daistolic = daistolic;
	}
	public String getPulseRate() {
		return pulseRate;
	}

	public void setPulseRate(String pulseRate) {
		this.pulseRate = pulseRate;
	}

	public static TriageDetail create(Encounter encounter) {
        Concept pulseRateConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.PULSE_RATE);
		Concept systolicConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.SYSTOLIC);
		Concept daistolicConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.DAISTOLIC);
		Concept temperatureConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.TEMPERATURE);
		Concept weightConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.WEIGHT);
		Concept heightConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.HEIGHT);
		Concept muacConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.MUAC);
		Concept growthStatusConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.GROWTH_STATUS);
		Concept weightCategoryConcept= Context.getConceptService().getConceptByUuid(MchMetadata.MchAppTriageConstants.WEIGHT_CATEGORY);
		
		
		StringBuffer pulseRate = new StringBuffer();
		StringBuffer systolic = new StringBuffer();
		StringBuffer daistolic = new StringBuffer();
		StringBuffer temperature = new StringBuffer();
		StringBuffer weight = new StringBuffer();
		StringBuffer height = new StringBuffer();
		StringBuffer growthStatus = new StringBuffer();
		StringBuffer weightCategory = new StringBuffer();
		StringBuffer muac = new StringBuffer();
		
		for (Obs obs : encounter.getAllObs()){
			if(obs.getConcept().equals(pulseRateConcept)){
				pulseRate.append(obs.getValueNumeric()).append("");
			}
			if(obs.getConcept().equals(systolicConcept)){
				systolic.append(obs.getValueText()).append("");
			}
			if(obs.getConcept().equals(daistolicConcept)){
				daistolic.append(obs.getValueNumeric()).append("");
			}
			if(obs.getConcept().equals(temperatureConcept)){
				temperature.append(obs.getValueNumeric()).append("");
			}
			if(obs.getConcept().equals(weightConcept)){
				weight.append(obs.getValueNumeric()).append("");
			}
			if(obs.getConcept().equals(heightConcept)){
				height.append(obs.getValueNumeric()).append("");
			}
			if(obs.getConcept().equals(muacConcept)){
				muac.append(obs.getValueNumeric()).append("");
			}
			if(obs.getConcept().equals(growthStatusConcept)){
				growthStatus.append(obs.getValueCoded().getDisplayString()).append("");
			}
			if(obs.getConcept().equals(weightCategoryConcept)){
				weightCategory.append(obs.getValueCoded().getDisplayString()).append("");
			}
		}
		TriageDetail triageDetail = new TriageDetail();
		
		if (pulseRate.length() > 0){
			triageDetail.setPulseRate(pulseRate.toString());
		}
		if (systolic.length() > 0){
			triageDetail.setSystolic(systolic.toString());
		}
		if (daistolic.length() > 0){
			triageDetail.setDaistolic(daistolic.toString());
		}
		if (temperature.length() > 0){
			triageDetail.setTemperature(temperature.toString());
		}
		if (weight.length() > 0){
			triageDetail.setWeight(weight.toString());
		}
		if (height.length() > 0){
			triageDetail.setHeight(height.toString());
		}
		if (growthStatus.length() > 0){
			triageDetail.setGrowthStatus(growthStatus.toString());
		}
		if (weightCategory.length() > 0){
			triageDetail.setWeightCategory(weightCategory.toString());
		}
		if (muac.length() > 0){
			triageDetail.setMua(muac.toString());
		}
		
		return triageDetail ;
	}

}
