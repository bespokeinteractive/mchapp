<%
ui.includeJavascript("uicommons", "moment.js")
%>
<div>
	${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'date-enrolled', id: 'date-enrolled', label: 'Date of Enrollment', useTime: false, defaultToday: true])}
</div>
<div class="container">
	<div class="anc button">ANC</div>
	<div class="pnc button">PNC</div>
	<div class="cwc button">CWC</div>
	<br style="clear: both">
</div>
<script>
jq(function(){
	jq(".anc").on("click", function(){
		handleEnrollInProgram(
				"${ui.actionLink('mchapp', 'programSelection', 'enrollInAnc')}",
				"${ui.pageLink('mchapp','triage',[patientId: patient])}"
			);
	});

	jq(".pnc").on("click", function(){
		handleEnrollInProgram(
				"${ui.actionLink('mchapp', 'programSelection', 'enrollInPnc')}",
				"${ui.pageLink('mchapp','triage',[patientId: patient])}"
			);
	});

	jq(".cwc").on("click", function(){
		handleEnrollInProgram(
				"${ui.actionLink('mchapp', 'programSelection', 'enrollInCwc')}",
				"${ui.pageLink('mchapp','triage',[patientId: patient])}"
			);
	});

	var handleEnrollInProgram = function (postUrl, successUrl) {
		jq.post(
			postUrl,
			{
				patientId: ${patient.id},
				dateEnrolled: moment(jq("#date-enrolled-field").val(), "YYYY-MM-DD").format("DD/MM/YYYY")
			},
			null,
			'json'
		).done(function(data){
			if (data.status === "success") {
				jq().toastmessage('showNoticeToast', data.message);
				//redirect to triage page
				window.location = successUrl;
			} else if (data.status === "error") {
				//display error message
				jq().toastmessage({sticky : true});
				jq().toastmessage('showErrorToast', data.message);
			}
		}).fail(function(){
			//display error message
		});
	};
});
</script>
<style>
.anc,.pnc,.cwc {
  padding: 8px 6px;
  margin: 2px 4px;
  float: left;
  cursor: pointer;
}
.container {
  margin-top: 15px;
}
</style>