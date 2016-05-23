<%
	ui.includeJavascript("uicommons", "moment.js")
%>

<script>
	jq(function(){
		jq('.button-group').on("click", ".button", function(){
			jq(".button").removeClass("active");
			jq(this).addClass("active");
		});
		
		jq('.confirm').click(function(){
			var programme = jq("label.button.active").data("role");
			handleEnrollInProgram(
				"${ui.actionLink('mchapp', 'programSelection', '" + programme + "')}",
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
	span.date input {
		display: inline-block;
		padding: 5px 10px;
		width: 200px;
	}
</style>

<div>
	<div id="div-left-menu" style="padding-top: 15px; color: #363463;" class="col15 clear">
		<ul id="ul-left-menu" class="left-menu">
			<li class="menu-item visit-summary selected" visitid="54">
				<span class="menu-date">
					<i class="icon-user"></i>
					<span id="vistdate">
						PATIENT ENROLMENT
					</span>
				</span>
				<span class="menu-title">
					<i class="icon-info-sign"></i>
					MCH PROGRAMME
				</span>
				<span class="arrow-border"></span>
				<span class="arrow"></span>
			</li>
			
			<li style="height: 30px;" class="menu-item">
			</li>
		</ul>
	</div>
	
	<div style="min-width: 78%" class="col16 dashboard">			
		<div id="visit-detail" class="info-section">
			<div class="info-header">
				<i class="icon-user-md"></i>
				<h3>ENROLMENT DETAILS</h3>
			</div>

			<div class="info-body">
				<div>
					<label for="date-enrolled-display" style="display: inline-block; width: 190px; padding-left: 10px;">Date of Enrollment</label>
					<span>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'date-enrolled', id: 'date-enrolled', label: 'Date of Enrollment', useTime: false, defaultToday: true])}</span>							
				</div>
				
				<div style="margin-top: 5px;">
					<label for="date-enrolled-display" style="display: inline-block; width: 190px; padding-left: 10px;">Select Programme</label>
					<span>
						<div class="example" style="display: inline">
							<div class="button-group">
								<label data-role="enrollInAnc" class="button active"> ANC </label>
								<label data-role="enrollInPnc" class="button"> PNC </label>
								<label data-role="enrollInCwc" class="button"> CWC </label>
							</div>
						</div>
					
					</span>
				</div>
			</div>
		</div>		
		
		<button style="float: right; margin: 10px; display: block;" class="confirm">
			<i class="icon-save small"></i>
			Enroll
		</button>
	</div>
</div>

<div class="container">	
	<br style="clear: both">
</div>
