package org.openmrs.module.mchapp;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.PersonName;
import org.openmrs.Visit;
import org.openmrs.util.Format;

import java.util.Date;

/**
 * @author Stanslaus Odhiambo
 *         Created on 6/14/2016.
 */
public class VisitListItem {
    protected static final Log log = LogFactory.getLog(VisitListItem.class);
    private Integer visitId;
    private String visitType;
    private String personName;
    private String location;
    private String indicationConcept;
    private Date startDatetime;
    private Date stopDatetime;
    private String startDatetimeString;
    private String stopDatetimeString;
    private boolean voided = false;

    public VisitListItem() {
    }

    public VisitListItem(Visit visit) {
        if (visit != null) {
            this.visitId = visit.getVisitId();
            this.visitType = visit.getVisitType().getName();
            this.startDatetime = visit.getStartDatetime();
            this.startDatetimeString = Format.format(visit.getStartDatetime());
            if (visit.getStopDatetime() != null) {
                this.stopDatetime = visit.getStopDatetime();
                this.stopDatetimeString = Format.format(visit.getStopDatetime());
            }

            PersonName pn = visit.getPatient().getPersonName();
            if (pn != null) {
                this.personName = "";
                if (pn.getGivenName() != null) {
                    this.personName = this.personName + pn.getGivenName();
                }

                if (pn.getMiddleName() != null) {
                    this.personName = this.personName + " " + pn.getMiddleName();
                }

                if (pn.getFamilyName() != null) {
                    this.personName = this.personName + " " + pn.getFamilyName();
                }
            }

            if (visit.getLocation() != null) {
                this.location = visit.getLocation().getName();
            }

            if (visit.getIndication() != null && visit.getIndication().getName() != null) {
                this.indicationConcept = visit.getIndication().getName().getName();
            }

            this.voided = visit.isVoided().booleanValue();
        }

    }

    public Integer getVisitId() {
        return this.visitId;
    }

    public void setVisitId(Integer visitId) {
        this.visitId = visitId;
    }

    public String getVisitType() {
        return this.visitType;
    }

    public void setVisitType(String visitType) {
        this.visitType = visitType;
    }

    public String getPersonName() {
        return this.personName;
    }

    public void setPersonName(String personName) {
        this.personName = personName;
    }

    public String getLocation() {
        return this.location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getIndicationConcept() {
        return this.indicationConcept;
    }

    public void setIndicationConcept(String indicationConcept) {
        this.indicationConcept = indicationConcept;
    }

    public Date getStartDatetime() {
        return this.startDatetime;
    }

    public void setStartDatetime(Date startDatetime) {
        this.startDatetime = startDatetime;
    }

    public Date getStopDatetime() {
        return this.stopDatetime;
    }

    public void setStopDatetime(Date stopDatetime) {
        this.stopDatetime = stopDatetime;
    }

    public String getStartDatetimeString() {
        return this.startDatetimeString;
    }

    public void setStartDatetimeString(String startDatetimeString) {
        this.startDatetimeString = startDatetimeString;
    }

    public String getStopDatetimeString() {
        return this.stopDatetimeString;
    }

    public void setStopDatetimeString(String stopDatetimeString) {
        this.stopDatetimeString = stopDatetimeString;
    }

    public boolean isVoided() {
        return this.voided;
    }

    public void setVoided(boolean voided) {
        this.voided = voided;
    }

    public boolean equals(Object obj) {
        if (!(obj instanceof VisitListItem)) {
            return false;
        } else {
            VisitListItem rhs = (VisitListItem) obj;
            return this.visitId != null && rhs.visitId != null ? this.visitId.equals(rhs.visitId) : this == obj;
        }
    }

    public int hashCode() {
        if (this.visitId == null) {
            return super.hashCode();
        } else {
            byte hash = 5;
            int hash1 = hash + 51 * this.visitId.intValue();
            return hash1;
        }
    }
}
