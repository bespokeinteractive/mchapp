<%
	ui.includeJavascript("uicommons", "moment.js")
%>

<script>
	var age 	= ${patient.age}
	var gender 	= '${patient.gender}'
	
	jq(function(){
		if (age <= 5){
			jq(".button").removeClass("active");
			jq('#cwc').addClass("active");
		}
	
		jq('.button-group').on("click", ".button", function(){
			var programme = jq(this).data("role");
			
			if (age <= 5 && programme !== 'enrollInCwc'){
				jq(".button").removeClass("active");
				jq('#cwc').addClass("active");
				
				jq().toastmessage('showErrorToast', 'This programme is only valid for children upto 5yrs');
				return false;
			}
						
			jq(".button").removeClass("active");
			jq(this).addClass("active");
		});
		
		jq('.confirm').click(function(){
			var programme = jq("label.button.active").data("role");
			
			if (age <= 5 && programme !== 'enrollInCwc'){				
				jq().toastmessage('showErrorToast', 'This programme is only valid for children upto 5yrs');
				return false;
			}
			else if (age > 5 && gender =='M'){
				jq().toastmessage('showErrorToast', 'This programme is only valid for Women or Children upto 5yrs');
				return false;
			}
			
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
					jq().toastmessage('showSuccessToast', data.message);
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
	input[type="text"], input[type="password"], select {
		border: 1px solid #aaa !important;
		border-radius: 2px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 38px !important;
		line-height: 18px !important;
		padding: 0 10px !important;
	}
	span.date input {
		display: inline-block;
		padding: 5px 10px;
		width: 222px!important;
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
								<label data-role="enrollInAnc" id="anc" class="button active"> ANC </label>
								<label data-role="enrollInPnc" id="pnc" class="button"> PNC </label>
								<label data-role="enrollInCwc" id="cwc" class="button"> CWC </label>
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
