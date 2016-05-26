<% 
	ui.includeCss("patientdashboardapp", "patientdashboardapp.css");
		
    ui.includeJavascript("uicommons", "handlebars/handlebars.min.js", Integer.MAX_VALUE - 1)
	
	ui.includeJavascript("uicommons", "navigator/validators.js", Integer.MAX_VALUE - 19)
    ui.includeJavascript("uicommons", "navigator/navigator.js", Integer.MAX_VALUE - 20)
    ui.includeJavascript("uicommons", "navigator/navigatorHandlers.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/navigatorModels.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/navigatorTemplates.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/exitHandlers.js", Integer.MAX_VALUE - 22)
%>

<script>
    var drugOrders = new DisplayDrugOrders();
    var selectedInvestigationIds = [];
    var investigationQuestionUuid = "1ad6f4a5-13fd-47fc-a975-f5a1aa61f757";
	var NavigatorController;
	
	var examinationArray = [];
	var investigationArray = [];
	
	var emrMessages = {};

	emrMessages["numericRangeHigh"] = "value should be less than {0}";
	emrMessages["numericRangeLow"] = "value should be more than {0}";
	emrMessages["requiredField"] = "Mandatory Field. Kindly provide details";
	emrMessages["numberField"] = "Value not a number";
    
    jq(function() {
		NavigatorController = new KeyboardController();
        ko.applyBindings(drugOrders, jq(".drug-table")[0]);
		
        var patientProfile = JSON.parse('${patientProfile}');
		
		console.log(patientProfile);
		
        if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        }

        var examinations = [];        
		
        var adddrugdialog = emr.setupConfirmationDialog({
            selector: '#prescription-dialog',
            actions: {
                confirm: function() {
                    addDrug();
                    jq("#drugForm")[0].reset();
                    jq('select option[value!="0"]', '#drugForm').remove();
                    adddrugdialog.close();
                },
                cancel: function() {
                    jq("#drugForm")[0].reset();
                    jq('select option[value!="0"]', '#drugForm').remove();
                    adddrugdialog.close();
                }
            }

        });

        jq("#availableReferral").on("change", function (){
            selectReferrals(jq( "#availableReferral" ).val());
        });

        jq("#addDrugsButton").on("click", function(e){
            adddrugdialog.show();
        });

        jq(".drug-name").on("focus.autocomplete", function () {
            var selectedInput = this;
            jq(this).autocomplete({
                minLength:3,
                source:function( request, response ) {
                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getDrugs") }',
                            {
                                q: request.term
                            }
                    ).success(function(data) {
                        var results = [];
                        for (var i in data) {
                            var result = { label: data[i].name, value: data[i].id};
                            results.push(result);
                        }
                        response(results);
                    });
                },
                select:function(event, ui){
                    event.preventDefault();
                    jq(selectedInput).val(ui.item.label);
                    jq(selectedInput).data("drug-id", ui.item.value);
                },
                change: function (event, ui) {
                    event.preventDefault();
                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getFormulationByDrugName") }',
                            {
                                "drugName": ui.item.label
                            }
                    ).success(function(data) {
                        var formulations = jq.map(data, function (formulation) {
                            jq('#formulationsSelect').append(jq('<option>').attr('value', formulation.id).text(formulation.name+':'+formulation.dozage));
                        });
                    });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getFrequencies") }').success(function(data) {
                        var frequencies = jq.map(data, function (frequency) {
                            jq('#frequencysSelect').append(jq('<option>').attr('value', frequency.uuid).text(frequency.name));
                        });
                    });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getDrugUnit") }').success(function(data) {
                        var durgunits = jq.map(data, function (drugUnit) {
                            jq('#drugUnitsSelect').append(jq('<option>').val(drugUnit.uuid).text(drugUnit.label));
                        });
                    });
                },
                open: function() {
                    jq( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
                },
                close: function() {
                    jq( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
                }
            });
        });
		
		//examinations autocomplete functionality
		jq("#searchExaminations").autocomplete({
            minLength:0,
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("mchapp", "examinationFilter", "searchFor") }', {
                    findingQuery: request.term
                }).success(function(data) {
                    examinations = data;
                    response(data);
                });
            },
            select: function(event, ui){
                var examination = _.find(examinations,function(exam){return exam.value === ui.item.value;});
				
				if (!examinationArray.find(function(exam){
					return exam.value == examination.value;})){
				
					var examTemplate = _.template(jq("#examination-detail-template").html());
					jq("#exams-holder").append(examTemplate(examination));
					jq('#exams-set').val('SET');
					jq('#task-exams').show();
					
					examinationArray.push(examination);
					examinationSummary();				
				}
				else {
					jq().toastmessage('showErrorToast', 'The test ' + examination.label + ' has already been added.');
				}
				
				jq(this).val('');
				return false;				
            }
        });
		
		jq("#exams-holder").on("click", "#selectedExamination",function(){
			var uid = jq(this).data('uid');
			examinationArray = examinationArray.filter(function(examination){
				return examination.value != uid;
			});
			
			examinationSummary();
            jq(this).parent("div").remove();
			
			if (jq("#examination-detail-div").length == 0){
				jq('#exams-set').val('');
				jq('#task-exams').hide();
			}
        });
		
		function examinationSummary(){
			if (examinationArray.length == 0){
				jq('#summaryTable tr:eq(0) td:eq(1)').text('N/A');
			}
			else{
				var exams = '';
				examinationArray.forEach(function(examination){
				  exams += examination.label +'<br/>'
				});
				jq('#summaryTable tr:eq(0) td:eq(1)').html(exams);
			}
		}

        //investigations autocomplete functionality
        jq("#investigation").autocomplete({
            source: function( request, response ) {
                jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getInvestigations") }',
                        {
                            q: request.term
                        }
                ).success(function(data) {
                    var results = [];
                    for (var i in data) {
                        var result = { label: data[i].name, value: data[i].uuid};
                        results.push(result);
                    }
                    response(results);
                });
            },
            minLength: 3,
            select: function( event, ui ) {
                if (!selectedInvestigationIds.includes(ui.item.value)) {
                    var investigation = {};
                    investigation.label = ui.item.label;
                    investigation.questionUuid = investigationQuestionUuid;
                    investigation.uuid = ui.item.value;
                    investigation.value = ui.item.value;
					
					investigationArray.push(ui.item);
					investigationSummary();
                    var investigationTemplate = _.template(jq("#investigation-template").html());
                    jq("#investigations-holder").append(investigationTemplate(investigation));
					jq('#investigations-set').val('SET');
					jq('#task-investigations').show();
					
                    selectedInvestigationIds.push(ui.item.value);
                } else {
                    jq().toastmessage('showErrorToast', ui.item.label + ' has already been added.');
                }
                jq(this).val('');
                return false;
            },
            open: function() {
                jq( this ).removeClass( "ui-corner-all" ).addClass( "ui-corner-top" );
            },
            close: function() {
                jq( this ).removeClass( "ui-corner-top" ).addClass( "ui-corner-all" );
            }
        });

        jq("#investigations-holder").on("click", ".icon-remove",function(){
            var investigationId = parseInt(jq(this).parents('div.investigation').find('input[type="hidden"]').attr("value"));
            selectedInvestigationIds.splice(selectedInvestigationIds.indexOf(investigationId));
			
			investigationArray = investigationArray.filter(function(investigation){
				return investigation.value != investigationId;
			});
			
			investigationSummary();
			
            jq(this).parents('div.investigation').remove();
			if (jq(".investigation").length == 0){
				jq('#investigations-set').val('');
				jq('#task-investigations').hide();
			}
        });
		
		function investigationSummary(){
			if (investigationArray.length == 0){
				jq('#summaryTable tr:eq(1) td:eq(1)').text('N/A');
			}
			else{
				var exams = '';
				investigationArray.forEach(function(investigation){
				  exams += investigation.label +'<br/>'
				});
				jq('#summaryTable tr:eq(1) td:eq(1)').html(exams);
			}
		}

        //submit data
        jq("#antenatalExaminationSubmitButton").on("click", function(event){
            event.preventDefault();
            var data = jq("form#antenatalExaminationsForm").serialize();
            data = data + "&" + objectToQueryString.convert(drugOrders["drug_orders"]);

            jq.post(
              '${ui.actionLink("mchapp", "antenatalExamination", "saveAntenatalExaminationInformation")}',
              data,
              function (data) {
                  if (data.status === "success") {
                      window.location = "${ui.pageLink("patientqueueapp", "mchClinicQueue")}"
                  } else if (data.status === "error") {
                      jq().toastmessage('showErrorToast', data.message);
                  }
              },
              "json"
            );
        });
		
		jq('#availableReferral').change(function(){
			if (jq(this).val() == "1"){
				jq('#summaryTable tr:eq(3) td:eq(1)').text('Internal Referral');
				jq('#referral-set').val('SET');
			}
			else if (jq(this).val() == "2"){
				jq('#summaryTable tr:eq(3) td:eq(1)').text('External Referral');
				jq('#referral-set').val('SET');
			}
			else {
				jq('#summaryTable tr:eq(3) td:eq(1)').text('N/A');
				jq('#referral-set').val('');
			}
		});
		
		jq('#referralReason').change(function(){
			if (jq(this).val() == "8"){
				jq('#externalRefferalSpc').show();
			}
			else{
				jq('#externalRefferalSpc').hide();
			}
		}).change();

    });

    function selectReferrals(selectedReferral){
        if(selectedReferral == 1){
            jq("#internalRefferalDiv").show();
            jq("#externalRefferalDiv").hide();
            jq("#externalRefferalFac").hide();
            jq("#externalRefferalRsn").hide();
            jq("#externalRefferalSpc").hide();
            jq("#externalRefferalCom").hide();
        }else if(selectedReferral == 2){
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").show();
            jq("#externalRefferalFac").show();
            jq("#externalRefferalRsn").show();
            jq("#externalRefferalCom").show();
			
			jq('#referralReason').change();
        }
        else{
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").hide();
            jq("#externalRefferalFac").hide();
            jq("#externalRefferalRsn").hide();
            jq("#externalRefferalSpc").hide();
            jq("#externalRefferalCom").hide();
        }
    }

    function addDrug(){
        var addDrugsTableBody = jq("#addDrugsTable tbody");
        var drugName = jq("#drugName").val();
        var drugDosage = jq("#drugDosage").val();
        var dosageUnit = {};
        dosageUnit.id = jq("#drugUnitsSelect option:selected").val();
        dosageUnit.text = jq("#drugUnitsSelect option:selected").text();
        var formulation = {};
        formulation.id = jq("#formulationsSelect option:selected").val();
        formulation.text = jq("#formulationsSelect option:selected").text();
        var frequency = {};
        frequency.id = jq("#frequencysSelect option:selected").val();
        frequency.text = jq("#frequencysSelect option:selected").text();
        var numberOfDays = jq("#numberOfDays").val();
        var comment = jq("#comment").val();

        var drugId = jq("#drugName").data("drugId");
        var drugOrderDetail = new DrugOrder(drugId, drugName, drugDosage,
                dosageUnit, formulation, frequency,
                numberOfDays, comment);

        drugOrders.addDrugOrder(drugId, drugOrderDetail);
    }
</script>

<style>
	.title-label{
		color: #009384;
		cursor: pointer;
		font-size: 1.3em;
		font-weight: normal;
	}
	#exams-holder input[type="radio"]{
		float: none;
	}
	.investigation .selecticon,
	#examination-detail-div .selecticon{
		color: #f00;
		cursor: pointer;
		float: right;
		margin: 7px 7px 0 0;
	}	
	.tasks {
		margin: 10px 0 0;
		padding-bottom: 10px;
		width: 100%;
	}
	.investigation{
		border-top: 1px dotted #ccc;
		margin: 0 0 5px;
	}
	.investigation:first-child{
		border-top: 1px none #ccc;
		margin: 5px 0 5px;
	}
	#examination-detail-div{
		border-top: 1px dotted #ccc;
		margin: 0 0 10px;
	}
	#examination-detail-div:first-child{
		border-top: 1px none #ccc;
		margin: 10px 0 10px;
	}
	section {
		min-height: 300px;
	}
	.dialog-content input[type="text"], .dialog-content select {
		display: inline-block !important;
		width: 238px !important;
	}
	.simple-form-ui section fieldset select:focus, .simple-form-ui section fieldset input:focus, .simple-form-ui section #confirmationQuestion select:focus, .simple-form-ui section #confirmationQuestion input:focus, .simple-form-ui #confirmation fieldset select:focus, .simple-form-ui #confirmation fieldset input:focus, .simple-form-ui #confirmation #confirmationQuestion select:focus, .simple-form-ui #confirmation #confirmationQuestion input:focus, .simple-form-ui form section fieldset select:focus, .simple-form-ui form section fieldset input:focus, .simple-form-ui form section #confirmationQuestion select:focus, .simple-form-ui form section #confirmationQuestion input:focus, .simple-form-ui form #confirmation fieldset select:focus, .simple-form-ui form #confirmation fieldset input:focus, .simple-form-ui form #confirmation #confirmationQuestion select:focus, .simple-form-ui form #confirmation #confirmationQuestion input:focus{
		outline: 1px none #f00
	}
	.patient-profile{
		border: 1px solid #eee;
		margin: 5px 0;
		padding: 7px 12px;
	}
	.patient-profile small{
		margin-left: 5.5%;
	}
	.patient-profile small:first-child{
		margin-left: 15px;
	}
	

</style>

<script id="examination-detail-template" type="text/template">
    <div id="examination-detail-div">
        <span id="selectedExamination" data-uid="{{=value}}" class="icon-remove selecticon"></span>
        <label style="margin-top: 0px; width: 95%;">{{-label}}</label>
		<br/>
		
        {{ _.each(answers, function(answer, index) { }}
			<label style="width: 95%; cursor: pointer;">
				<input type="radio" name="concept.{{=value}}" value="{{=answer.uuid}}">
				{{=answer.display}}			
			</label>
			<br/>
        {{ }); }}
    </div>
</script>

<script id="investigation-template" type="text/template">
  <div class="investigation">
	<span class="icon-remove selecticon"></span>
    <label style="margin-top: 2px; width: 95%;">{{=label}} 
		<input type="hidden" name="test_order.{{=questionUuid}}" value="{{=uuid}}"/>
	</label>
  </div>
</script>

<script id="patient-profile-template" type="text/template">
	<small><i class="icon-calendar small"></i> Enrolled:</small> ${ui.formatDatePretty(enrollmentDate)}	
    {{ _.each(details, function(profileDetail) { }}
		{{if (isValidDate(profileDetail.value)) { }}
			<small><i class="icon-time small"></i> {{=profileDetail.name}}:</small>
		{{ } else { }}
			<small><i class="icon-user small"></i> {{=profileDetail.name}}:</small>
		{{ } }}
        
		
		{{=profileDetail.value}}
    {{ }); }}
</script>

<div class="patient-profile"></div>

<form method="post" id="antenatalExaminationsForm" class="simple-form-ui">
	<input type="hidden" name="patientId" value="${patient.patientId}" >
	<input type="hidden" name="queueId" value="${queueId}" >
	
	<section>
		<span class="title">Clinical Notes</span>
		<fieldset class="no-confirmation">
			<legend>Examinations</legend>
			<div style="padding: 0 4px">
				<label for="searchExaminations" class="label title-label">Examinations <span class="important"></span></label>
				<input type="text" id="searchExaminations" name="" value="" placeholder="Add Examination"/>
				<field>
					<input type="hidden" id="exams-set" class=""/>
					<span id="exams-lbl" class="field-error" style="display: none"></span>
				</field>
				
				<div class="tasks" id="task-exams" style="display:none;">
					<header class="tasks-header">
						<span id="title-symptom" class="tasks-title">PATIENT'S EXAMINATIONS</span>
						<a class="tasks-lists"></a>
					</header>
					
					<div id="exams-holder"></div>						
				</div>
			</div>				
		</fieldset>
		
		<fieldset class="no-confirmation">
			<legend>Investigations</legend>
			<div>
				<label for="investigation" class="label title-label">Investigations <span class="important"></span></label>
				<input type="text" style="width: 450px" id="investigation" name="investigation" placeholder="Enter Investigations" >
				
				<field>
					<input type="hidden" id="investigations-set" class=""/>
					<span id="investigations-lbl" class="field-error" style="display: none"></span>
				</field>
				
				<div class="tasks" id="task-investigations" style="display:none;">
					<header class="tasks-header">
						<span id="title-symptom" class="tasks-title">PATIENT'S INVESTIGATIONS</span>
						<a class="tasks-lists"></a>
					</header>
					
					<div id="investigations-holder"></div>						
				</div>
				
				<select style="display: none" id="selectedInvestigationList"></select>
				
				<div class="selectdiv" id="selected-investigations"></div>					
			</div>
		</fieldset>
		
		<fieldset class="no-confirmation">
			<legend>Prescription</legend>
			<label class="label title-label">Prescription <span class="important"></span></label>

			<table class="drug-table">
				<thead>
					<tr>
						<th>Drug Name</th>
						<th>Dosage</th>
						<th>Formulation</th>
						<th>Frequency</th>
						<th>Days</th>
						<th>Comments</th>
						<th></th>
					</tr>
				</thead>
				
				<tbody data-bind="foreach: display_drug_orders">					
					<tr>
						<td data-bind="text: drug_name"></td>
						<td data-bind="text: (dosage + ' ' + dosage_unit_label)"></td>
						<td data-bind="text: formulation_label"></td>
						<td data-bind="text: frequency_label"></td>
						<td data-bind="text: number_of_days"></td>
						<td data-bind="text: comment"></td>
						<td data-bind="click: \$parent.remove">
							<i class="icon-remove small" style="cursor: pointer; color: #f00;"></i>							
						</td>
					</tr>
				</tbody>
				
				<tbody data-bind="visible: display_drug_orders().length==0">
					<tr>
						<td colspan="8">
							<div style="padding: 6px 10px; border-top: 1px solid #ddd; border-bottom: 3px solid #ddd; margin: -5px -10px;">No Drugs Added Yet</div>
						</td>
					</tr>
				</tbody>
			</table>
			
			<field>
				<input type="hidden" id="prescriptions-set" class=""/>
				<span id="prescriptions-lbl" class="field-error" style="display: none"></span>
			</field>
			
			<div style="margin-top:5px">
				<span class="button confirm" id="addDrugsButton" style="float: right; margin-right: 0px;">
					<i class="icon-plus-sign"></i>
					Add Drugs
				</span>
			</div>
		</fieldset>
		
		<fieldset>
			<legend>Referral</legend>
			
			<field>
				<input type="hidden" id="referral-set" class=""/>
				<span id="referral-lbl" class="field-error" style="display: none"></span>
			</field>
			
			<div class="onerow">
				<div class="col4">
					<label for="availableReferral">Referral Available</label>
					<select id="availableReferral" name="availableReferral">
						<option value="0">Select Option</option>
						<option value="1">Internal Referral</option>
						<option value="2">External Referral</option>
					</select>				
				</div>
				
				<div class="col4">
					<div id="internalRefferalDiv" style="display: none">
						<label for="internalRefferal">Internal Referral</label>
						<select id="internalRefferal" name="">
							<option value="0">Select Option</option>
							<% if (internalReferrals != null || internalReferrals != "") { %>
							<% internalReferrals.each { internalReferral -> %>
							<option ${internalReferral.id} >${internalReferral.label}</option>
							<% } %>
							<% } %>
						</select>
					</div>
					
					<div id="externalRefferalDiv" style="display: none">
						<label> External Referral</label>
						<select id="externalRefferal" name="">
							<option value="0">Select Option</option>
							<% if (externalReferrals != null || externalReferrals != "") { %>
							<% externalReferrals.each { externalReferral -> %>
							<option ${externalReferral.id} >${externalReferral.label}</option>
							<% } %>
							<% } %>
						</select>
					</div>					
				</div>
				
				<div class="col4 last">
					<div id="externalRefferalFac" style="display: none">
						<label>Facility</label>
						<input type="text" id="referralFacility" name="">					
					</div>
				</div>			
			</div>
			
			<div class="onerow">
				<div class="col4">
					<div id="externalRefferalRsn" style="display: none">
						<label for="referralReason">Referral Reason</label>
						<select id="referralReason" name="">
							<option value="0">Select Option</option>
							<% if (referralReasons != null || referralReasons != "") { %>
							<% referralReasons.each { referralReason -> %>
							<option value="${referralReason.id}" >${referralReason.label}</option>
							<% } %>
							<% } %>
						</select>
					</div>				
				</div>
				
				<div class="col4 last" style="width: 65%;">
					<div id="externalRefferalSpc" style="display: none">
						<label for="specify" style="width: 200px">If Other, Please Specify</label>
						<input id ="specify" type="text" name="" placeholder="Please Specify" style="display: inline;">
					</div>
				</div>
			</div>
			
			<div class="onerow">
				<div id="externalRefferalCom" style="display: none">
					<label for="comments">Comment</label>
					<textarea id="comments" style="width: 95.7%; resize: none;"></textarea>				
				</div>
			</div>
		</fieldset>
	</section>
	
	<div id="confirmation" style="width:74.6%; min-height: 400px;">
		<span id="confirmation_label" class="title">Confirmation</span>
		
		<div class="dashboard">
			<div class="info-section">
				<div class="info-header">
					<i class="icon-list-ul"></i>
					<h3>OPD SUMMARY &amp; CONFIRMATION</h3>
				</div>					
				
				<div class="info-body">
					<table id="summaryTable">
						<tbody><tr>
							<td><span class="status active"></span>Examinations</td>
							<td>N/A</td>
						</tr>
						
						<tr>
							<td><span class="status active"></span>Investigations</td>
							<td>N/A</td>
						</tr>
						
						<tr>
							<td><span class="status active"></span>Prescriptions</td>
							<td>N/A</td>
						</tr>
						
						<tr>
							<td><span class="status active"></span>Outcome</td>
							<td>N/A</td>
						</tr>
					</tbody></table>
				</div>
			</div>				
		</div>
		
		<div id="confirmationQuestion" class="focused" style="margin-top:20px">		
			<field style="display: inline"> 
				<button class="button submit confirm" style="display: none;"></button>
			</field>
			
			<input type="button" value="Submit" class="button submit confirm" id="antenatalExaminationSubmitButton">
		</div>
	</div>
</form>

<div id="prescription-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Prescription</h3>
    </div>

    <div class="dialog-content">
        <form id="drugForm">
            <ul>
                <li>
                    <label>Drug</label>
                    <input class="drug-name" id="drugName" type="text">
                </li>
                <li>
                    <label>Dosage</label>
                    <input type="text" id="drugDosage" style="width: 60px !important;">
                    <select id="drugUnitsSelect" style="width: 174px !important;">
                        <option value="0">Select Unit</option>
                    </select>
                </li>

                <li>
                    <label>Formulation</label>
                    <select id="formulationsSelect" >
                        <option value="0">Select Formulation</option>
                    </select>
                </li>
                <li>
                    <label>Frequency</label>
                    <select id="frequencysSelect">
                        <option value="0">Select Frequency</option>
                    </select>
                </li>

                <li>
                    <label>Number of Days</label>
                    <input id="numberOfDays" type="text">
                </li>
                <li>
                    <label>Comment</label>
                    <textarea id="comment"></textarea>
                </li>
            </ul>
            <label class="button confirm" style="float: right; width: auto!important;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>
