<script>
    jq(function () {
    	var patientProfile = JSON.parse('"details":${patientProfile.toJSON()}');
        if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        } else {
            var patientProfileEditorTemplate = _.template(jq("#patient-profile-editor-template").html());
            jq("form").prepend(patientProfileEditorTemplate());
        }

        jq(".patient-profile").on("click", ".edit-profile", function(){
            jq(".patient-profile").empty();
            jq("<a href=\"#\" class=\"cancel\">Cancel</a>").on("click", removeProfileEditor).appendTo(jq(".patient-profile"));
            var patientProfileEditorTemplate = _.template(jq("#patient-profile-editor-template").html());
            jq("form").prepend(patientProfileEditorTemplate());
            for (var i = 0; i < patientProfile.details.length; i++) {
                jq("input[name$='"+ patientProfile.details[i].uuid +"']").val(patientProfile.details[i].value);
            }
        });

        function removeProfileEditor() {
            jq(".profile-editor", document.forms[ 0 ]).remove();
        }

        jq("#lastMenstrualPeriodDate").on("change",function(e){
            calculateExpectedDeliveryDate();
            calculateGestationInWeeks();
        });

        function calculateExpectedDeliveryDate() {
            var lastMenstrualPeriodDate = jq("#lastMenstrualPeriodDate-field").val();
            lastMenstrualPeriodDate = new Date(lastMenstrualPeriodDate);
            lastMenstrualPeriodDate.setMonth(lastMenstrualPeriodDate.getMonth() + 9);
            jq('#expectedDeliveryDate-field').val(moment(lastMenstrualPeriodDate).format('YYYY-MM-DD'));
            jq('#expectedDeliveryDate-display').val(moment(lastMenstrualPeriodDate).format('DD MMM YYYY'));
        }

        function calculateGestationInWeeks(){
            var lastMenstrualPeriodDate = jq("#lastMenstrualPeriodDate-field").val();
            lastMenstrualPeriodDate = new Date(lastMenstrualPeriodDate);
            var todaysDate = new Date();
            var gestation = todaysDate-lastMenstrualPeriodDate;
            var gestationInWeeks = Math.floor(gestation/(1000 * 3600 * 24 * 7));
            jq('#gestation').val(gestationInWeeks);
        }
    });
</script>
<script id="patient-profile-template" type="text/template">
    {{ _.each(profileDetails, function(profileDetail) { }}
        <p>{{=profileDetail.name}}: {{=profileDetail.value}}</p>
    {{ }); }}
</script>
<script id="patient-profile-editor-template" type="text/template">
<div class="profile-editor">
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
</div>
</script>
<div class="patient-profile"></div>
<form id="antenatalTriageForm">
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