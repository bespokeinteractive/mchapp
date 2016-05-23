<script>
    jq(function () {
        var patientProfile = JSON.parse('${patientProfile}');
        if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        } else {
            jq(".patient-profile-editor").prependTo(jq(".profile-editor"));
        }

        jq(".patient-profile").on("click", ".edit-profile", function(){
            jq(".patient-profile").empty();
            jq("<a href=\"#\" class=\"cancel\">Cancel</a>").appendTo(jq(".patient-profile"));
            jq(".patient-profile-editor").prependTo(jq(".profile-editor"));
            for (var i = 0; i < patientProfile.details.length; i++) {
                if (isValidDate(patientProfile.details[i].value)) {
                    jq("input[name\$='"+ patientProfile.details[i].uuid +"']").val(moment(patientProfile.details[i].value, 'D/M/YYYY').format('YYYY-MM-DD'));
                    jq("#"+ patientProfile.details[i].uuid + "-display").val(moment(patientProfile.details[i].value, 'D/M/YYYY').format('DD MMM YYYY'));
                } else {
                    jq("input[name\$='"+ patientProfile.details[i].uuid +"']").val(patientProfile.details[i].value);
                }
            }
        });

        jq(".patient-profile").on("click", ".cancel", function(e){
            e.preventDefault();
            jq('.patient-profile-editor').appendTo('.template-holder');
            jq(':input','.patient-profile-editor')
              .val('')
              .removeAttr('checked')
              .removeAttr('selected');
            if (patientProfile.details.length > 0) {
                var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
                jq(".patient-profile").append(patientProfileTemplate(patientProfile));
            }
            jq(this).remove();
        });

        jq("form").on("change", "#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", function(e){
            calculateExpectedDeliveryDate();
            calculateGestationInWeeks();
        });

        function calculateExpectedDeliveryDate() {
            var lastMenstrualPeriod = jq("#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field", document.forms[0]).val();
            var expectedDate = moment(lastMenstrualPeriod, "YYYY-MM-DD").add(9, "months")
            jq('#5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field', document.forms[0]).val(expectedDate.format('YYYY-MM-DD'));
            jq('#5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-display', document.forms[0]).val(expectedDate.format('DD MMM YYYY'));
        }

        function calculateGestationInWeeks(){
            var lastMenstrualPeriod = moment(jq("#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field", document.forms[0]).val(), "YYYY-MM-DD");
            var expectedDate = moment();
            var gestationInWeeks = Math.ceil(moment.duration(expectedDate.diff(lastMenstrualPeriod)).asWeeks());
            jq('#gestation', document.forms[0]).val(gestationInWeeks);
        }

        //submit data
        jq(".submit").on("click", function(event){
            event.preventDefault();
            var data = jq("form#antenatal-triage-form").serialize();

            jq.post(
                '${ui.actionLink("mchapp", "antenatalTriage", "saveAntenatalTriageInformation")}',
                data,
                function (data) {
                    if (data.status === "success") {
                        //show success message
                        window.location = "${ui.pageLink("patientqueueapp", "mchTriageQueue")}"
                    } else if (data.status === "fail") {
                        //show error message;
                        jq().toastmessage('showErrorToast', data.message);
                    }
                }, 
                "json");
        });
    });
</script>
<script id="patient-profile-template" type="text/template">
    {{ _.each(details, function(profileDetail) { }}
        <p>{{=profileDetail.name}}: {{=profileDetail.value}}</p>
    {{ }); }}
    <a href="#" class="edit-profile">Edit</a>
</script>
<div class="template-holder" style="display:none;">
<div class="patient-profile-editor">
    <div>
        <label for="parity">Parity</label>
        <input type="text" name="concept.1053AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="parity" />
    </div>
    <div>
        <label for="gravidae">Gravida</label>
        <input type="text" name="concept.5624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="gravidae" />
    </div>
    <div>
        <label>Last Menstrual Period (LMP)</label>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
    </div>
    <div>
        <label>Expected Date of Delivery (EDD)</label>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: '', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
    </div>
    <div>
        <label for="gestation">Gestation in weeks</label>
        <input type="text" id="gestation">
    </div>
</div>
</div>
<div class="patient-profile"></div>
<form id="antenatal-triage-form">
    <input type="hidden" name="patientId" value="${patientId}" >
    <div class="profile-editor"></div>
    <div>
        <label for="weight">Weight (Kgs)</label>
        <input type="text" id="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" name="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
    </div>
    <div>
        <label for="height">Height (Metres)</label>
        <input type="text" id="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" name="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" />
    </div>
    <div>
        <label for="bloodPressure">Blood Pressure</label>
        <input type="text" id="systolic" name="concept.5085AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" />
        <input type="text" id="diastolic" name="concept.5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" />
    </div>
    <div>
        <label for="referralOptions">Tick to Send to Examination Room</label>
        <input type="checkbox" name="send_for_examination" value="yes" >
    </div>
    <div>
        <input type="button" value="Submit" class="button submit confirm" id="antenatalTriageFormSubmitButton">
    </div>
</form>
