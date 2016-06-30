<%
	ui.includeJavascript("uicommons", "moment.js")
%>

<script>
	var age 	= ${patient.age};
	var gender 	= '${patient.gender}';
	var select  = 'enrollInAnc';
	
	jq(function(){
		if (age <= 5){
			jq("input[name='enrollIn'][value='enrollInCwc']").attr('checked', 'checked');
			select = 'enrollInCwc';
		}
		
		jq("input[name='enrollIn']").change(function(){
			var programme = jq(this).val();
			
			if (age <= 5 && programme !== 'enrollInCwc'){
				jq("input[name='enrollIn'][value='enrollInCwc']").attr('checked', 'checked');
				jq().toastmessage('showErrorToast', 'This patient can only be registered for CWC');
				return false;
			}
			else if (age > 5 && programme === 'enrollInCwc'){
				jq("input[name='enrollIn'][value='" + select + "']").attr('checked', 'checked');
				jq().toastmessage('showErrorToast', 'This programme is only valid for children upto 5yrs');
				return false;
			}
			
			select = programme;
		});
		
		jq('.confirm').click(function(){
			if (!jq("input[name='enrollIn']:checked").val()) {
				jq().toastmessage('showErrorToast', 'No MCH programme has been selected');
			}

			var programme = jq("input[name='enrollIn']:checked").val();	
			
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
				successUrl
			);			
		});
		
		var handleEnrollInProgram = function (postUrl, successUrl) {
			jq.post(
				postUrl,
				{
					patientId: ${patient.id},
					dateEnrolled: moment(jq("#date-enrolled-field").val(), "YYYY-MM-DD").format("DD/MM/YYYY"),
				},
				null,
				'json'
			).done(function(data){
				if (data.status === "success") {
					jq().toastmessage('showSuccessToast', data.message);
					//redirect to triage page
					alert(successUrl)
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
		width: 252px!important;
	}
	.tasks {
        background: white none repeat scroll 0 0;
		border: 1px solid #cdd3d7;
		border-radius: 4px;
		box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
		color: #404040;
		display: inline-block;
		font: 13px/20px "Lucida Grande",Verdana,sans-serif;
		margin-bottom: 5px;
		width: 250px;
    }

    .tasks-header {
        position: relative;
        line-height: 24px;
        padding: 7px 15px;
        color: #5d6b6c;
        text-shadow: 0 1px rgba(255, 255, 255, 0.7);
        background: #f0f1f2;
        border-bottom: 1px solid #d1d1d1;
        border-radius: 3px 3px 0 0;
        background-image: -webkit-linear-gradient(top, #f5f7fd, #e6eaec);
        background-image: -moz-linear-gradient(top, #f5f7fd, #e6eaec);
        background-image: -o-linear-gradient(top, #f5f7fd, #e6eaec);
        background-image: linear-gradient(to bottom, #f5f7fd, #e6eaec);
        -webkit-box-shadow: inset 0 1px rgba(255, 255, 255, 0.5), 0 1px rgba(0, 0, 0, 0.03);
        box-shadow: inset 0 1px rgba(255, 255, 255, 0.5), 0 1px rgba(0, 0, 0, 0.03);
    }

    .tasks-title {
        line-height: inherit;
        font-size: 14px;
        font-weight: bold;
        color: inherit;
    }

    .tasks-lists {
        background: rgba(0, 0, 0, 0) url("../ms/uiframework/resource/registration/images/view_list.png") no-repeat scroll 3px 0 / 85% auto;
        position: absolute;
        top: 50%;
        right: 10px;
        margin-top: -11px;
        padding: 10px 4px;
        width: 19px;
        height: 3px;
        font: 0/0 serif;
        text-shadow: none;
        color: transparent;
    }

    .tasks-lists:before {
        display: block;
        height: 3px;
        background: #8c959d;
        border-radius: 1px;
        -webkit-box-shadow: 0 6px #8c959d, 0 -6px #8c959d;
        box-shadow: 0 6px #8c959d, 0 -6px #8c959d;
    }

    .tasks-list-item {
        display: block;
        line-height: 24px;
        padding: 5px 10px;
        cursor: pointer;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
        user-select: none;
    }

    .tasks-list-item + .tasks-list-item {
        border-top: 1px solid #f0f2f3;
    }

    .tasks-list-cb {
        display: none;
    }
	
	.tasks-list-mark {
		border: 2px solid #c4cbd2;
		border-radius: 5px;
		display: inline-block;
		height: 20px;
		margin-right: 0;
		position: relative;
		vertical-align: top;
		width: 20px;
	}

    .tasks-list-mark:before {
        content: '';
        display: none;
        position: absolute;
        top: 50%;
        left: 50%;
        margin: -5px 0 0 -6px;
        height: 4px;
        width: 8px;
        border: solid #39ca74;
        border-width: 0 0 4px 4px;
        -webkit-transform: rotate(-45deg);
        -moz-transform: rotate(-45deg);
        -ms-transform: rotate(-45deg);
        -o-transform: rotate(-45deg);
        transform: rotate(-45deg);
    }

    .tasks-list-cb:checked ~ .tasks-list-mark {
        border-color: #39ca74;
    }

    .tasks-list-cb:checked ~ .tasks-list-mark:before {
        display: block;
    }

    .tasks-list-desc {
        font-weight: bold;
        color: #555;
    }

    .tasks-list-cb:checked ~ .tasks-list-desc {
        color: #34bf6e;
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
					<label for="date-enrolled-display" style="display: inline-block; width: 190px; float: left; padding: 5px 4px 0px 10px;">Select Programme</label>
					
					<div class="tasks">
						<header class="tasks-header">
							<span class="tasks-title">MCH PROGRAMMES</span>
							<a class="tasks-lists"></a>
						</header>

						<div class="tasks-list">
							<label class="tasks-list-item">
								<input type="radio" class="tasks-list-cb" value="enrollInAnc" name="enrollIn" style="display:none!important" checked="checked">
								<span class="tasks-list-mark"></span>
								<span class="tasks-list-desc"> ANTENATAL CLINIC</span>
							</label>

							<label class="tasks-list-item">
								<input type="radio" class="tasks-list-cb" value="enrollInPnc" name="enrollIn" style="display:none!important">
								<span class="tasks-list-mark"></span>
								<span class="tasks-list-desc"> POST-NATAL CLINIC</span>
							</label>

							<label class="tasks-list-item">
								<input type="radio" class="tasks-list-cb" value="enrollInCwc" name="enrollIn" style="display:none!important">
								<span class="tasks-list-mark"></span>
								<span class="tasks-list-desc"> CHILD WELFARE CLINIC</span>
							</label>
						</div>
					</div>					
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
