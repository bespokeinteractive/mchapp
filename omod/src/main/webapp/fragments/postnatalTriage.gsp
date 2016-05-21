<script>
    jq(function(){
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
    });
</script>
<script id="patient-profile-template" type="text/template">
    {{ _.each(details, function(detail) { }}
        <p>{{=detail.name}}: {{=detail.value}}</p>
    {{ }); }}
    <a href="#" class="edit-profile">Edit</a>
</script>
<script id="patient-profile-editor-template">
<div class="profile-editor">
  <p>
    <label for="deliveryDate">Date of Delivery</label>
    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'deliveryDate', id: 'deliveryDate', label: '', useTime: false, defaultToday: false])}
  </p>
  <p>
    <label for="deliveryPlace">Place of Delivery</label>
    <input type="text" name="deliveryPlace" >
  </p>
  <p>
    <label for="deliveryMode">Mode of Delivery</label>
    <input type="text" name="deliveryMode" >
  </p>
  <p>
    <label for="babyState">State of Baby</label>
    <input type="text" name="babyState" >
  </p>
</div>
</script>
<div class="patient-profile"></div>
<form class="pnc-triage-form">
	<p>
		<label for="temperature">Temperature</label>
		<input type="text" name="">
	</p>
	<p>
		<label for="pulse">Pulse</label>
		<input type="text" name="">
	</p>
	<p>
		<label for="bloodPressure">Blood Pressure</label>
		<input type="text" name="systolic" >
		<input type="text" name="diastolic" >
	</p>
	<p>
		<button class="button submit">Submit</button>
		<button class="button">Cancel</button>
	</p>
</form>

<script>
jq(function(){
	jq("submit").on("click", function(event){
		event.preventDefault();
		var data = jq("form.pnc-triage-form").serialize();

		jq.post(
			'${ui.actionLink("mchapp", "postnatalTriage", "savePostnatalTriageInformation")}',
			data,
			function (data) {
				if (data.status === "success") {
					//show success message
					//return back to queue
				} else if (data.status === "fail") {
					//show error message;
				}
			}, 
			"json");
	});
});
</script>