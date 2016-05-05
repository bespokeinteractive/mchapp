<form class="pnc-triage-form">
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