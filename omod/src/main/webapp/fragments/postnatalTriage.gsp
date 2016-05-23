<script>
    jq(function(){
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
            var patientProfileEditorTemplate = _.template(jq("#patient-profile-editor-template").html());
            jq("form").prepend(patientProfileEditorTemplate());
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
        });
    });
</script>
<script id="patient-profile-template" type="text/template">
    {{ _.each(details, function(detail) { }}
        <p>{{=detail.name}}: {{=detail.value}}</p>
    {{ }); }}
    <a href="#" class="edit-profile">Edit</a>
</script>
<div class="template-holder" style="display:none;">
<div class="patient-profile-editor">
  <p>
    <label for="deliveryDate">Date of Delivery</label>
    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.5599AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '5599AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: '', useTime: false, defaultToday: false, endDate: new Date()])}
  </p>
  <p>
    <label for="deliveryPlace">Place of Delivery</label>
    <input type="text" name="deliveryPlace" >
  </p>
  <p>
    <label for="deliveryMode">Mode of Delivery</label>
    <input type="text" name="modeOfDeliver" >
  </p>
  <p>
    <label for="babyState">State of Baby</label>
    <input type="text" name="babyState" >
  </p>
</div>
</div>
<div class="patient-profile"></div>
<form class="pnc-triage-form">
	<input type="hidden" name="patientId" value="${patientId}" >
	<div class="profile-editor"></div>
	<p>
		<label for="temperature">Temperature</label>
		<input type="text" name="concept.5088AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
	</p>
	<p>
		<label for="pulse">Pulse</label>
		<input type="text" name="concept.5087AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
	</p>
	<p>
		<label for="bloodPressure">Blood Pressure</label>
		<input type="text" id="systolic" name="concept.6aa7eab2-138a-4041-a87f-00d9421492bc" >
		<input type="text" id="diastolic" name="concept.5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" >
	</p>
	<div>
		<label for="referralOptions">Tick to Send to Examination Room</label>
		<input type="checkbox" name="send_for_examination" value="yes" >
	</div>
	<p>
		<button class="button submit">Submit</button>
		<button class="button">Cancel</button>
	</p>
</form>

<script>
jq(function(){
	jq(".submit").on("click", function(event){
		event.preventDefault();
		var data = jq("form.pnc-triage-form").serialize();

		jq.post(
			'${ui.actionLink("mchapp", "postnatalTriage", "savePostnatalTriageInformation")}',
			data,
			function (data) {
				if (data.status === "success") {
					//show success message
					window.location = "${ui.pageLink("patientqueueapp", "mchClinicQueue")}"
				} else if (data.status === "fail") {
					//show error message;
					jq().toastmessage('showErrorToast', data.message);
				}
			}, 
			"json");
	});
});
</script>