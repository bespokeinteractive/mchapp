<script>
    jq(function () {
    	var isEdit=${isEdit};
		
    	jq("#editStatus").val(isEdit?"true":"false");
        var patientProfile = JSON.parse('${patientProfile}');
        if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        } else {
            jq(".patient-profile-editor").prependTo(jq(".profile-editor"));
        }

        jq(".patient-profile").on("click", ".edit-profile", function(){
            jq(".patient-profile").empty();
            jq("<span style='margin-top: 5px; display: block;'><a href=\"#\" class=\"cancel\"><i class='icon-remove small'></i>Cancel Edit</a></span>").appendTo(jq(".patient-profile"));
            jq(".patient-profile-editor").prependTo(jq(".profile-editor"));
            for (var i = 0; i < patientProfile.details.length; i++) {
                if (isValidDate(patientProfile.details[i].value)) {
                    jq("input[name\$='"+ patientProfile.details[i].uuid +"']").val(moment(patientProfile.details[i].value, 'D/M/YYYY').format('YYYY-MM-DD')).change();
                    jq("#"+ patientProfile.details[i].uuid + "-display").val(moment(patientProfile.details[i].value, 'D/M/YYYY').format('DD MMM YYYY')).change();
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

        jq("form").on("change", "#gestation", function(e) {
            var gestationPeriod = jq(this).val();
            var lastMenstrualPeriod = moment().add(-gestationPeriod, "weeks");
            console.log(lastMenstrualPeriod)
            jq('#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field', document.forms[0]).val(lastMenstrualPeriod.format('YYYY-MM-DD'));
            jq('#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-display', document.forms[0]).val(lastMenstrualPeriod.format('DD MMM YYYY'));
            jq("#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA").change();
        })

        function calculateExpectedDeliveryDate() {
            var lastMenstrualPeriod = jq("#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field", document.forms[0]).val();
            var expectedDate = moment(lastMenstrualPeriod, "YYYY-MM-DD").add(9, "months")
			expectedDate = expectedDate.add(7, 'days');
            jq('#5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field', document.forms[0]).val(expectedDate.format('YYYY-MM-DD'));
            jq('#5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-display', document.forms[0]).val(expectedDate.format('DD MMM YYYY'));
        }

        function calculateGestationInWeeks(){
            var lastMenstrualPeriod = moment(jq("#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field", document.forms[0]).val(), "YYYY-MM-DD");
            var expectedDate = moment();
            var gestationInWeeks = Math.round(moment.duration(expectedDate.diff(lastMenstrualPeriod)).asWeeks());
            jq('#gestation', document.forms[0]).val(gestationInWeeks);
        }

        //submit data
        jq(".submit").on("click", function(event){
			var selectedLmp = jq('#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field').val();
			
			if(jq('form #1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA-field').length > 0 && !isValidDate(selectedLmp)){
				jq().toastmessage('showErrorToast', "Check that the L.M.P has been provided!");
				return false;
			}
			
			if (!jq.isNumeric(jq('#visitNumber').val())){
				jq().toastmessage('showErrorToast', "Check that the ANC Visit Count has been filled properly!");
				return false;
			}
			
            event.preventDefault();
            var data = jq("form#antenatal-triage-form").serialize();

            jq.post(
                '${ui.actionLink("mchapp", "antenatalTriage", "saveAntenatalTriageInformation")}',
                data,
                function (data) {
                    if (data.status === "success") {
                        //show success message
                        if(data.isEdit){
                        	window.location = "${ui.pageLink("mchapp", "main",[patientId: patientId, queueId: queueId])}";
                        }else{
                            window.location = "${ui.pageLink("patientqueueapp", "mchTriageQueue")}"
                          	 }
                    } else if (data.status === "error") {
                        //show error message;
                        jq().toastmessage('showErrorToast', data.message);
                    }
                }, 
                "json"
			);
        });
    });
</script>
<script id="patient-profile-template" type="text/template">
    {{ _.each(details, function(profileDetail) { }}
		<span class="menu-title">
			<i class="icon-angle-right"></i>
			<span>{{=profileDetail.name}}:</span>{{=profileDetail.value}}
		</span>
    {{ }); }}
	
	<span style="border-top: 1px dotted rgb(136, 136, 136); display: block; margin-top: 5px; padding-top: 5px;">
		<a href="#" class="edit-profile">
			<i class="icon-pencil"></i>
			Edit Details
		</a>	
	</span>
</script>

<div>
	<div style="padding-top: 15px;" class="col15 clear">
		<ul id="left-menu" class="left-menu">
			<li class="menu-item selected" visitid="54">
				<span class="menu-date">
					<i class="icon-time"></i>
					<span id="vistdate">23 May 2016<br> &nbsp; &nbsp; (Active since 04:10 PM)</span>
				</span>
				
				<div class="patient-profile">
				
				</div>
				
				
				
				<span class="arrow-border"></span>
				<span class="arrow"></span>
			</li>

			<li style="height: 30px;" class="menu-item" visitid="53">
			</li>
		</ul>
	</div>
	
	<div style="min-width: 70%" class="col16 dashboard">
		<div class="info-section">
			<form id="antenatal-triage-form">
			<input type="hidden" value="" id="editStatus" name="isEdit"/>
				<div class="profile-editor"></div>
				
				<div class="info-header">
					<i class="icon-diagnosis"></i>
					<h3>TRIAGE DETAILS</h3>
				</div>
				
				<div class="info-body" style="margin-bottom: 20px; padding-bottom: 10px;">
					<input type="hidden" name="patientId" value="${patientId}" >
					<input type="hidden" name="queueId" value="${queueId}" >
					<input type="hidden" name="patientEnrollmentDate" value='${patientProgram?patientProgram.dateEnrolled:"--"}'>
					<div>
						<label for="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Weight</label>
						<input type="text" id="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" name="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" class="number numeric-range" value="${weight}"/>
						<span class="append-to-value">Kgs</span>
						<span id="12482" class="field-error" style="display: none"></span>
					</div>
					<div>
						<label for="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Height</label>
						<input type="text" id="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" name="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" class="number numeric-range" value="${height}"/>
						<span class="append-to-value">Mtrs</span>
						 <span id="12483" class="field-error" style="display: none"></span>
					</div>
					<div>
						<label for="systolic">Blood Pressure</label>
						<input type="text" id="systolic" name="concept.6aa7eab2-138a-4041-a87f-00d9421492bc" class="number numeric-range" value="${systolic}"  />
						<span class="append-to-value">Systolic</span>
						<span id="12485" class="field-error" style="display: none"></span>
					</div>
					
					<div>
						<label for="diastolic"></label>
						<input type="text" id="diastolic" name="concept.5086AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" class="number numeric-range" value="${daistolic}"/>
						<span class="append-to-value">Diastolic</span>
						<span id="12484" class="field-error" style="display: none"></span>
					</div>					
				</div>
				
				<div class="info-header">
					<i class="icon-group"></i>
					<h3>VISIT DETAILS</h3>
				</div>
				
				<div class="info-body">
					<div>
						<label for="concept.1425AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Number of Visit</label>
						<input type="text" name="concept.1425AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="visitNumber" value="${visitCount}">
						<span id="" class="field-error" style="display: none"></span>
					</div>
			
					<%if(!isEdit){ %>
						<div>
							<label></label>
							<label style="padding-left: 0px; width: auto; cursor: pointer;">
								<input type="checkbox" name="send_for_examination" value="11303942-75cd-442a-aead-ae1d2ea9b3eb" >
								Tick to Send to Examination Room
							</label>
						</div>
					<% }%>
				</div>
				
				
				
				
			</form>
			
			<div>
				<span class="button submit confirm right" id="antenatalTriageFormSubmitButton" style="margin-top: 10px; margin-right: 30px;">
					<i class="icon-save"></i>
					Save
				</span>
			</div>
		</div>
	</div>
</div>

<div class="container">	
	<br style="clear: both">
</div>


<div class="template-holder" style="display:none;">
	<div class="patient-profile-editor">
		<div class="info-header">
			<i class="icon-user-md"></i>
			<h3>ANTENATAL DETAILS</h3>
		</div>
		
		<div class="info-body" style="margin-bottom: 20px; padding-bottom: 10px;">
			<div>				
				<label for="parity">Parity</label>
				<input type="text" name="concept.1053AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="parity" />				
				<span class="append-to-value">Pregnancies</span>
			</div>
		
			<div>
				<label for="gravidae">Gravida</label>
				<input type="text" name="concept.5624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="gravida" />
				<span class="append-to-value">Pregnancies</span>
			</div>
			
			<div>				
				${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: 'L.M.P', useTime: false, defaultToday: false, endDate: new Date(), class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
			</div>
			
			<div>
				${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: 'E.D.D', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
			</div>
			
			<div>
				<label for="gestation">Gestation</label>
				<input type="text" id="gestation">
				<span class="append-to-value">Weeks</span>
			</div>
		</div>
	</div>
</div>
<div class="">&nbsp;</div>

