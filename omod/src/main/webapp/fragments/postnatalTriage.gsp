<form>
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
		<button class="button">Submit</button>
		<button class="button">Cancel</button>
	</p>
</form>