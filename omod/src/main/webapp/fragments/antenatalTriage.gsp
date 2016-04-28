<form id="antenatalTriageForm">
    <div>
        <label for="parity">Parity</label>
        <input type="text" id="parity" />
    </div>
    <div>
        <label for="gravidae">Gravidae</label>
        <input type="text" id="gravidae" />
    </div>
    <div>
        <label>Date of Last Menstrual Period (LMP)</label>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'lastMenstrualPeriodDate', id: 'lastMenstrualPeriodDate', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
    </div>
    <div>
        <label>Expected Date of Delivery (EDD)</label>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'expectedDeliveryDate', id: 'expectedDeliveryDate', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
    </div>
    <div>
        <label for="gestation">Gestation in weeks</label>
        <input type="text" id="gestation" />
    </div>
    <div>
        <label for="weight">Weight (Kgs)</label>
        <input type="text" id="weight" />
    </div>
    <div>
        <label for="height">Height (Metres)</label>
        <input type="text" id="height" />
    </div>
    <div>
        <label for="bloodPressure">Blood Pressure</label>
        <input type="text" id="bloodPressure" />
    </div>
    <div>
        <label for="investigations">Investigations</label>
        <input type="text" id="investigations" />
    </div>
    <div>
        <label for="listOfDrugs">List of drugs</label>
        <input type="text" id="listOfDrugs" />
    </div>
    <div>
        <label for="referralOptions">Referral options:</label>
        <input type="text" id="referralOptions" />
    </div>
    <div>
        <input type="button" value="Submit" class="button confirm" id="antenatalTriageFormSubmitButton">
    </div>
</form>