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
	var selectedDiagnosisIds = [];
    var selectedInvestigationIds = [];
	var examinationArray = [];
	var NavigatorController;

	var provisionalDiagnosisQuestionUuid = "b8bc4c9f-7ccb-4435-bc4e-646d4cf83f0a";
	var finalDiagnosisQuestionUuid = "7033ef37-461c-4953-a757-34722b6d9e38"
	var diagnosisQuestionUuid = "";
	var investigationQuestionUuid = "1ad6f4a5-13fd-47fc-a975-f5a1aa61f757";
	var diagnosisArray = [];
	var investigationArray = [];

	var emrMessages = {};

	emrMessages["numericRangeHigh"] = "value should be less than {0}";
	emrMessages["numericRangeLow"] = "value should be more than {0}";
	emrMessages["requiredField"] = "Mandatory Field. Kindly provide details";
	emrMessages["numberField"] = "Value not a number";

    jq(function(){
		
		NavigatorController = new KeyboardController(jq('#postnatalExaminationsForm'));
        ko.applyBindings(drugOrders, jq(".drug-table")[0]);

		var patientProfile = JSON.parse('${patientProfile}');
		var patientHistoricalProfile = JSON.parse('${patientHistoricalProfile}');
		if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        }

        var examinations = [];
		
		var exitcwcdialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#exitPncDialog',
            actions: {
                confirm: function () {
                    var endDate = jq("#complete-date-field").val();
                    outcomeId = jq("#programOutcome").val();
                    var startDate = "${patientProgram.dateEnrolled}";

                    if (outcomeId == '' || outcomeId == "0") {
                        alert("Outcome Required");
                        return;
                    }
                    //&& startDate > endDate run test to ensure end date is not earlier than start start date

                    else if (!isEmpty(startDate) && !isEmpty(endDate)) {
                        var result = handleExitProgram(${patientProgram.patientProgramId}, "${patientProgram.dateEnrolled}",
                                endDate, outcomeId);

                    } else {
                        alert("invalid end date");
                        return;
                    }
                    exitcwcdialog.close();
                },
                cancel: function () {
                    exitcwcdialog.close();
                }
            }
        });
		
		function SubmitInformation(){
            var data = jq("form#postnatalExaminationsForm").serialize();
            data = data + "&" + objectToQueryString.convert(drugOrders.drug_orders);
			
            jq.post('${ui.actionLink("mchapp", "postnatalExamination", "savePostnatalExaminationInformation")}',
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
		}
		
		function handleExitProgram(programId, enrollmentDateYmd, completionDateYmd, outcomeId) {
			var updateData = {
				programId: programId,
				enrollmentDateYmd: enrollmentDateYmd,
				completionDateYmd: completionDateYmd,
				outcomeId: outcomeId
			}
			jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "updatePatientProgram") }', updateData)
				.success(function (data) {
					SubmitInformation();
				}).error(function (xhr, status, err) {
					jq().toastmessage('showErrorToast', "AJAX error!" + err);
				}
			);
		}
		
        jq("#postnatal-examination-submit").on("click", function(event){
            event.preventDefault();
			
			if (jq('#exitPatientFromProgramme:checked').length > 0){
				exitcwcdialog.show();
			}else{
				SubmitInformation();
			}
        });

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
            select:function(event, ui){
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

		function examinationSummary(){
			if (examinationArray.length == 0){
				jq('#summaryTable tr:eq(1) td:eq(1)').text('N/A');
			}
			else{
				var exams = '';
				examinationArray.forEach(function(examination){
				  exams += examination.label +'<br/>'
				});
				jq('#summaryTable tr:eq(1) td:eq(1)').html(exams);
			}
		}

        jq("#availableReferral").on("change", function (){
            selectReferrals(jq( "#availableReferral" ).val());
        });

        var adddrugdialog = emr.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
            selector: '#prescription-dialog',
            actions: {
                confirm: function() {
					if (!drugDialogVerified()){
						jq().toastmessage('showErrorToast', 'Ensure fields marked in red have been properly filled before you continue')
						return false;
					}
					
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
                    jq(selectedInput).val(ui.item.label);
                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getFormulationByDrugName") }',
                            {
                                "drugName": ui.item.label
                            }
                    ).success(function(data) {
                        var formulations = jq.map(data, function (formulation) {
                            jq('#formulationsSelect').append(jq('<option>').text(formulation.name+':'+formulation.dozage).attr('value', formulation.id));
                        });
                    });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getFrequencies") }').success(function(data) {
                        var frequencies = jq.map(data, function (frequency) {
                            jq('#frequencysSelect').append(jq('<option>').text(frequency.name).attr('value', frequency.uuid));
                        });
                    });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getDrugUnit") }').success(function(data) {
                        var durgunits = jq.map(data, function (drugUnit) {
                            jq('#drugUnitsSelect').append(jq('<option>').text(drugUnit.label).attr('value', drugUnit.id));
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

		//select whether diagnosis is provisional or final
		jq("#provisional-diagnosis").on("click", function(){
			diagnosisQuestionUuid = provisionalDiagnosisQuestionUuid;
		});
		
		jq("#final-diagnosis").on("click", function(){
			diagnosisQuestionUuid = finalDiagnosisQuestionUuid;
		});

		//Diagnosis autocomplete functionality
		jq("#diagnoses").autocomplete({
			source: function( request, response ) {
				jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getDiagnosis") }',
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
				if (!selectedDiagnosisIds.includes(ui.item.value)) {
					var diagnosis = {};
					diagnosis.label = ui.item.label;
					diagnosis.questionUuid = diagnosisQuestionUuid;
					diagnosis.uuid = ui.item.value;
					diagnosis.value = ui.item.value;

					diagnosisArray.push(ui.item);
					diagnosisSummary();
					var diagnosisTemplate = _.template(jq("#diagnosis-template").html());
					jq("#diagnosis-holder").append(diagnosisTemplate(diagnosis));
					jq('#diagnosis-set').val('SET');
					jq('#task-diagnosis').show();

					selectedDiagnosisIds.push(ui.item.value);
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

		function diagnosisSummary(){
			if (diagnosisArray.length == 0){
				jq('#summaryTable tr:eq(3) td:eq(1)').text('N/A');
			}
			else{
				var diagnoses = '';
				diagnosisArray.forEach(function(diagnosis){
					diagnoses += diagnosis.label +'<br/>'
				});
				jq('#summaryTable tr:eq(3) td:eq(1)').html(diagnoses);
			}
		}

		jq("#diagnosis-holder").on("click", ".icon-remove",function(){
			var diagnosisId = jq(this).parents('div.diagnosis').find('input[type="hidden"]').attr("value");
			selectedDiagnosisIds.splice(selectedDiagnosisIds.indexOf(diagnosisId));

			diagnosisArray = diagnosisArray.filter(function(diagnosis){
				return diagnosis.value != diagnosisId;
			});

			diagnosisSummary();

			jq(this).parents('div.diagnosis').remove();
			if (jq(".diagnosis").length == 0){
				jq('#diagnosis-set').val('');
				jq('#task-diagnosis').hide();
			}
		});

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
            var investigationId = jq(this).parents('div.investigation').find('input[type="hidden"]').attr("value");
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
				jq('#summaryTable tr:eq(4) td:eq(1)').text('N/A');
			}
			else{
				var exams = '';
				investigationArray.forEach(function(investigation){
				  exams += investigation.label +'<br/>'
				});
				jq('#summaryTable tr:eq(4) td:eq(1)').html(exams);
			}
		}

		jq('#availableReferral, #next-visit-date-display').change(function(){
			var output = '';
			
			if (jq('#availableReferral').val() == "1"){
				output += 'Internal Referral<br/>';
				jq('#referral-set').val('SET');
			}
			else if (jq('#availableReferral') == "2"){
				output += 'External Referral<br/>';
				jq('#referral-set').val('SET');
			}
			
			if (jq('#next-visit-date-display').val() != ''){
				output += 'Next Visit: ' + jq('#next-visit-date-display').val();
				jq('#referral-set').val('SET');
			}
			
			if (output == ''){
				jq('#referral-set').val('');
				output = 'N/A';			
			}
			
			jq('#summaryTable tr:eq(8) td:eq(1)').html(output);
		});

		jq('#referralReason').change(function(){
			if (jq(this).val() == "8"){
				jq('#externalRefferalSpc').show();
			}
			else{
				jq('#externalRefferalSpc').hide();
			}
		}).change();

		jq('#374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA').change(function(){
			if (jq(this).val() == "0"){
				jq('#summaryTable tr:eq(7) td:eq(1)').text('N/A');
				jq('#family-planning-set').val('');
			}
			else {
				jq('#summaryTable tr:eq(7) td:eq(1)').text(jq('#374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA :selected').text());
				jq('#family-planning-set').val('SET');
			}
		});

		jq('.hiv-info input').change(function(){
			jq('#hiv-info-set').val('SET');

			var output = '';

			if (!jq("input[name='concept.1406dbf3-05da-4264-9659-fb688cea5809']:checked").val()) {}
			else {
				output += 'Prior Known Status: ' + jq("input[name='concept.1406dbf3-05da-4264-9659-fb688cea5809']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.11724bb1-9033-457b-9b09-d4080f459f2f']:checked").val()) {}
			else {
				output += 'Tested in PNC: ' + jq("input[name='concept.11724bb1-9033-457b-9b09-d4080f459f2f']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.0a24f03e-9133-4401-b683-76c45e166912']:checked").val()) {}
			else {
				output += 'Tested Results: ' + jq("input[name='concept.0a24f03e-9133-4401-b683-76c45e166912']:checked").data('value') + '<br/>';
			}

			if (!jq("input[name='concept.27b96311-bc00-4839-b7c9-31401b44cd3a']:checked").val()) {}
			else {
				output += 'Couple Counselled: ' + jq("input[name='concept.27b96311-bc00-4839-b7c9-31401b44cd3a']:checked").data('value') + '<br/>';
			}

			if (!jq("input[name='concept.93366255-8903-44af-8370-3b68c0400930']:checked").val()) {}
			else {
				output += 'Patner Tested: ' + jq("input[name='concept.93366255-8903-44af-8370-3b68c0400930']:checked").data('value') + '<br/>';
			}

			if (!jq("input[name='concept.df68a879-70c4-40d5-becc-a2679b174036']:checked").val()) {}
			else {
				output += 'Patner Results: ' + jq("input[name='concept.df68a879-70c4-40d5-becc-a2679b174036']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.162327AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").val()) {}
			else {
				output += 'NVP for Baby: ' + jq("input[name='concept.162327AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.7e5aa2a0-de37-4baa-8b44-2b8fe460c6fb']:checked").val()) {}
			else {
				output += 'CTX for Baby: ' + jq("input[name='concept.7e5aa2a0-de37-4baa-8b44-2b8fe460c6fb']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.a0b98c2e-ac37-4878-ad42-34bdb0d1926a']:checked").val()) {}
			else {
				output += 'CTX for Mother: ' + jq("input[name='concept.a0b98c2e-ac37-4878-ad42-34bdb0d1926a']:checked").data('value') + '<br/>';
			}

			jq('#summaryTable tr:eq(5) td:eq(1)').html(output);
			
			if (jq(this).attr('name') == 'concept.93366255-8903-44af-8370-3b68c0400930'){
				if (jq(this).val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
					jq('.partner-results').show(300);
				}
				else{
					jq('.partner-results').hide(300);
					jq('.partner-results input').removeAttr('checked');
				}
			}
			
			if (jq(this).attr('name') == 'concept.11724bb1-9033-457b-9b09-d4080f459f2f'){
				if (jq(this).val() == '606720bb-4a7a-4c4c-b3b5-9a8e910758c9'){
					jq('.anc-tests').hide(300);
					jq('.initial-hide').hide(300);
					
					jq('.anc-tests input').removeAttr('checked');					
					jq('.initial-hide input').removeAttr('checked');
				}
				else{
					jq('.anc-tests').show(300);
					jq('.initial-hide').show(300);
				}
			}
			
			if (jq(this).attr('name') == 'concept.0a24f03e-9133-4401-b683-76c45e166912'){
				if (jq(this).val() == '7480ebef-125b-4e0d-a8e5-256224ee31a0'){
					jq('.nvp-ctx-info').show(300);
				}
				else{
					jq('.nvp-ctx-info').hide(300);
					jq('.nvp-ctx-info input').removeAttr('checked');
				}
			}
		});
		jq('.cervical-info input').change(function(){
			jq('#cervical-info-set').val('SET');
			var output = '';

			if (!jq("input[name='concept.50c026c3-f2bc-44b9-a9dd-e972ffcbb774']:checked").val()) {
			output += 'Screening Method: results not provided' +  '<br/>';
			}
			else {
				output += 'Screening Method: ' + jq("input[name='concept.50c026c3-f2bc-44b9-a9dd-e972ffcbb774']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.1406dbf3-05da-4264-9659-fb688cea5809']:checked").val()) {
			output += 'Screening results: results not provided' +  '<br/>';
			}
			else {
				output += 'Screening Results: ' + jq("input[name='concept.1406dbf3-05da-4264-9659-fb688cea5809']:checked").data('value') + '<br/>';
			}
			jq('#summaryTable tr:eq(6) td:eq(1)').html(output);
			
			
		});

		jq('.misc-info input').change(function(){
			jq('#misc-info-set').val('SET');

			var output = '';

			if (!jq("input[name='concept.ba18b0c3-8208-465a-9c95-2f85047e2939']:checked").val()) {}
			else {
				output += 'PNC Exercise: ' + jq("input[name='concept.ba18b0c3-8208-465a-9c95-2f85047e2939']:checked").data('value') + '<br/>';
			}

			if (!jq("input[name='concept.5712097d-a478-4ff4-a2aa-bd827a6833ed']:checked").val()) {}
			else {
				output += 'Multi-vitamin: ' + jq("input[name='concept.5712097d-a478-4ff4-a2aa-bd827a6833ed']:checked").data('value') + '<br/>';
			}

			if (!jq("input[name='concept.5d935a14-9c53-4171-bda7-51da05fbb9eb']:checked").val()) {}
			else {
				output += 'Haematinics: ' + jq("input[name='concept.5d935a14-9c53-4171-bda7-51da05fbb9eb']:checked").data('value') + '<br/>';
			}

			if (!jq("input[name='concept.c764e84f-cfb2-424a-acec-20e4fb8531b7']:checked").val()) {}
			else {
				output += 'Vitamin A Suppliments: ' + jq("input[name='concept.c764e84f-cfb2-424a-acec-20e4fb8531b7']:checked").data('value') + '<br/>';
			}

			jq('#summaryTable tr:eq(7) td:eq(1)').html(output);
		});
    });
	
	function isEmpty(o) {
        return o == null || o == '';
    }

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
	function formatHispDate(HispDate){
		return 'Date';
	}
</script>


<style>
	
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
	.thirty-three-perc{
		border-left: 1px solid #363463;
		display: inline-block;
		float: left;
		font-size: 15px !important;
		padding-left: 1%;
		width: 32%;
	}
	.thirty-three-perc small{
		float: left;
		font-size: 85% !important;
		min-width: 150px;
		margin-right: 4px;
	}
	.thirty-three-perc span{
		color: #555;
		float: left;
		font-size: 90%;
	}
	#next-visit-date label,
	.anc-tests,
	.initial-hide,
	.nvp-ctx-info,
	.partner-results{
		display: none;
	}
	.simple-form-ui section, .simple-form-ui #confirmation, .simple-form-ui form section, .simple-form-ui form #confirmation {
		background: #fff none repeat scroll 0 0;
	}
	.important {
	    color: #f00 !important;
	}	
</style>

<script id="diagnosis-template" type="text/template">
  <div class="investigation diagnosis">
	<span class="icon-remove selecticon"></span>
    <label style="margin-top: 2px; width: 95%;">{{=label}}
		<input type="hidden" name="concept.{{=questionUuid}}" value="{{=uuid}}"/>
	</label>
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

<script id="examination-detail-template" type="text/template">
    <div id="examination-detail-div">
        <span id="selectedExamination" data-uid="{{=value}}" class="icon-remove selecticon"></span>
        <label style="margin-top: 0px; width: 95%;">{{-label}}</label>		
		<input type="{{-text_type}}" name="{{-text_name}}" style="margin-left: 10px ! important; width: 95% ! important;" placeholder="SPECIFY VALUE FOR {{-label}}"/>		
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

<form id="postnatalExaminationsForm" class="simple-form-ui">
	<input type="hidden" name="patientId" value="${patient.patientId}" >
	<input type="hidden" name="queueId" value="${queueId}" >

	<section>
		<span class="title">Clinical Notes</span>
		<fieldset class="no-confirmation">
			<legend>Symptoms</legend>
			<div style="padding: 0 4px">
				<label for="symptom" class="label">Symptoms <span class="important"></span></label>
				<input type="text" id="symptom" name="symptom" placeholder="Add Symptoms" />
				<field>
					<input type="hidden" id="symptoms-set" class=""/>
					<span id="symptoms-lbl" class="field-error" style="display: none"></span>
				</field>
			</div>

			<div class="tasks" id="task-symptom" style="display:none;">
				<header class="tasks-header">
					<span id="title-symptom" class="tasks-title">PATIENT'S SYMPTOMS</span>
					<a class="tasks-lists"></a>
				</header>
				
				<div id="symptoms-holder"></div>
			</div>
		</fieldset>
		
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
			<legend>Diagnosis</legend>
			<label for="diagnoses" class="label title-label">Diagnosis <span class="important"></span></label>
			<div class="tasks-list">
				<div class="left">
					<label id="ts01" class="tasks-list-item" for="provisional-diagnosis">

						<input type="radio" name="diagnosis_type" id="provisional-diagnosis" value="true" data-bind="checked: diagnosisProvisional" class="tasks-list-cb focused"/>

						<span class="tasks-list-mark"></span>
						<span class="tasks-list-desc">Provisional</span>
					</label>
				</div>

				<div class="left">
					<label class="tasks-list-item" for="final-diagnosis">
						<input type="radio" name="diagnosis_type" id="final-diagnosis" value="false" data-bind="checked: diagnosisProvisional" class="tasks-list-cb"/>
						<span class="tasks-list-mark"></span>
						<span class="tasks-list-desc">Final</span>
					</label>
				</div>
			</div>
			
			<div>
				<input type="text" style="width: 450px" id="diagnoses" name="diagnosis" placeholder="Enter Diagnosis" >

				<field>
					<input type="hidden" id="diagnosis-set" class=""/>
					<span id="diagnosis-lbl" class="field-error" style="display: none"></span>
				</field>

				<div class="tasks" id="task-diagnosis" style="display:none;">
					<header class="tasks-header">
						<span id="title-diagnosis" class="tasks-title">PATIENT'S DIAGNOSIS</span>
						<a class="tasks-lists"></a>
					</header>

					<div id="diagnosis-holder"></div>
				</div>
				<select style="display: none" id="selectedDiagnosisList"></select>
				<div class="selectdiv" id="selected-diagnosis"></div>
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

		<fieldset>
			<legend>PMTCT Information</legend>
			<label for="investigation" class="label title-label" style="width: auto;">PMTCT Information<span class="important"></span></label>

			<field>
				<input type="hidden" id="hiv-info-set" class=""/>
				<span id="hiv-info-lbl" class="field-error" style="display: none"></span>
			</field>

			<div class="onerow floating-controls hiv-info">
				<div class="col4" style="width: 33%; margin: 0 1% 0 0">
					<div class="testbox">
						<div>Prior Known Status</div>
						<label>
							<input id="prior-status-positive" type="radio" data-value="Positive" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="7480ebef-125b-4e0d-a8e5-256224ee31a0">
							Positive
						</label><br/>

						<label>
							<input id="prior-status-negative" type="radio" data-value="Negative" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="aca8224b-2f4b-46cb-b75d-9e532745d61f">
							Negative
						</label><br/>

						<label>
							<input id="prior-status-unknown" type="radio" data-value="Unknown" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="ec8e61d3-e9c9-4020-9c62-8403e14af5af">
							Unknown
						</label>
					</div>
				</div>
				
				<div class="col4" style="width: 33%; margin: 0 1% 0 0">
					<div class="testbox">
						<div>HIV Tested in PNC</div>
						
						<label>
							<input id="" type="radio" data-value="Within 72hrs" name="concept.11724bb1-9033-457b-9b09-d4080f459f2f" value="d26536f5-b8df-4740-b25b-28e2b1702a71">
							Within 72hrs
						</label><br/>

						<label>
							<input id="" type="radio" data-value="After 72hrs" name="concept.11724bb1-9033-457b-9b09-d4080f459f2f" value="43539d76-be01-45a8-96c6-968930d2e862">
							After 72hrs
						</label>
						
						<label>
							<input id="" type="radio" data-value="Not Tested" name="concept.11724bb1-9033-457b-9b09-d4080f459f2f" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							Not Tested
						</label><br/>
					</div>
				</div>
				
				<div class="col4 last" style="width: 32%;">
					<div class="testbox anc-tests">
						<div>PNC Test Results</div>
						<label>
							<input id="prior-status-positive" type="radio" data-value="Positive" name="concept.0a24f03e-9133-4401-b683-76c45e166912" value="7480ebef-125b-4e0d-a8e5-256224ee31a0">
							Positive
						</label><br/>

						<label>
							<input id="prior-status-negative" type="radio" data-value="Negative" name="concept.0a24f03e-9133-4401-b683-76c45e166912" value="aca8224b-2f4b-46cb-b75d-9e532745d61f">
							Negative
						</label><br/>

						<label>
							<input id="prior-status-unknown" type="radio" data-value="Unknown" name="concept.0a24f03e-9133-4401-b683-76c45e166912" value="ec8e61d3-e9c9-4020-9c62-8403e14af5af">
							Unknown
						</label>
					</div>
				</div>				
			</div>
			<div class="clear"></div>
			
			<div class="onerow floating-controls hiv-info initial-hide">
				<div class="col4" style="width: 33%; margin: 0 1% 0 0">
					<div class="testbox" class="couple-counselled">
						<div>Couple Counselled</div>

						<label>
							<input  type="radio" data-value="Yes" name="concept.27b96311-bc00-4839-b7c9-31401b44cd3a" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>

						<label>
							<input type="radio" data-value="No" name="concept.27b96311-bc00-4839-b7c9-31401b44cd3a" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>					
				</div>
				
				<div class="col4" style="width: 33%; margin: 0 1% 0 0">
					<div class="testbox partner-tested">
						<div>Patner Tested</div>		 
						<label>		 
							<input id="" type="radio" data-value="Yes" name="concept.93366255-8903-44af-8370-3b68c0400930" value="4536f271-5430-4345-b5f7-37ca4cfe1553">		 
							Yes		
						</label><br/>		
								
						<label>		
							<input id="" type="radio" data-value="No" name="concept.93366255-8903-44af-8370-3b68c0400930" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">		
							No		
						</label>		
					</div>
				</div>
				
				<div class="col4 last" style="width: 32%;">
					<div class="testbox partner-results">
						<div>Patner Results</div>
						<label>
							<input id="prior-status-positive" type="radio" data-value="Positive" name="concept.df68a879-70c4-40d5-becc-a2679b174036" value="7480ebef-125b-4e0d-a8e5-256224ee31a0">
							Positive
						</label><br/>
						<label>
							<input id="prior-status-negative" type="radio" data-value="Negative" name="concept.df68a879-70c4-40d5-becc-a2679b174036" value="aca8224b-2f4b-46cb-b75d-9e532745d61f">
							Negative
						</label><br/>
						
						<label>
							<input id="prior-status-unknown" type="radio" data-value="Unknown" name="concept.df68a879-70c4-40d5-becc-a2679b174036" value="ec8e61d3-e9c9-4020-9c62-8403e14af5af">
							Unknown
						</label>
					</div>					
				</div>
			</div>
			
			<div class="onerow floating-controls hiv-info nvp-ctx-info">
				<label class="label title-label" style="width: auto;">Formula & Supplements</label>
				<div class="clear"></div>
				
				<div class="col4" style="width: 33%; margin: 0 1% 0 0">
					<div class="testbox">
						<div>NVP for Baby</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.162327AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>

						<label>
							<input id="" type="radio" data-value="No" name="concept.162327AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>						
					</div>				
				</div>
				
				<div class="col4" style="width: 33%; margin: 0 1% 0 0">
					<div class="testbox">
						<div>CTX for Baby</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.7e5aa2a0-de37-4baa-8b44-2b8fe460c6fb" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>

						<label>
							<input id="" type="radio" data-value="No" name="concept.7e5aa2a0-de37-4baa-8b44-2b8fe460c6fb" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>				
				</div>
				
				<div class="col4 last" style="width: 32%;">
					<div class="testbox">
						<div>CTX for Mother</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.a0b98c2e-ac37-4878-ad42-34bdb0d1926a" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>

						<label>
							<input id="" type="radio" data-value="No" name="concept.a0b98c2e-ac37-4878-ad42-34bdb0d1926a" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label><br/>

						<label>
							&nbsp;
						</label>
					</div>
				</div>
			</div>
		</fieldset>
		<fieldset>
				<legend>Cervical Screening</legend>
					<label for="investigation" class="label title-label" style="width: auto;">Cervical Screening Information<span class="important"></span></label>
										
					<field>
						<input type="hidden" id="cervical-info-set" class=""/>
						<span id="cervical-info-lbl" class="field-error" style="display: none"></span>
					</field>
						<div class = "onerow floating controls cervical-info">
							<div class="col4" style="width: 48%;">
								<div>
									<span>Screening Method:</span><br/>
									<label>
										<input id="screening-method-via" type="radio"  name="concept.50c026c3-f2bc-44b9-a9dd-e972ffcbb774" value="556f371e-d980-4adb-adfc-93dc31973b98" data-value="VIA">
										V.I.A
									</label><br/>
								
									<label>
										<input id="screening-method-pap" type="radio" name="concept.50c026c3-f2bc-44b9-a9dd-e972ffcbb774" value="fc60e89d-68c8-4844-bd5a-efb43b203c18" data-value="PAP">
										P.A.P
									</label><br/>
				
								</div>
			
							<div>
								<span>Screening Results:</span><br/>
									<label>
										<input id="screening-positive" type="radio" data-value="Positive" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="7480ebef-125b-4e0d-a8e5-256224ee31a0" data-value="Positive">
										Positive
									</label><br/>
								
									<label>
										<input id="screening-negative" type="radio" data-value="Negative" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="aca8224b-2f4b-46cb-b75d-9e532745d61f" data-value="Negative">
										Negative
									</label><br/>
							</div>
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
			<legend>Suppliments</legend>
			<label for="investigation" class="label title-label" style="width: auto;">Suppliments & Exercise Information<span class="important"></span></label>

			<field>
				<input type="hidden" id="misc-info-set" class=""/>
				<span id="misc-info-lbl" class="field-error" style="display: none"></span>
			</field>

			<div class="onerow floating-controls misc-info">
				<div class="col4" style="width: 42%; margin: 0 1% 0 0;">
					<div class="testbox">
						<div>PNC Exercise given?</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.ba18b0c3-8208-465a-9c95-2f85047e2939" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						<label>
							<input id="" type="radio" data-value="No" name="concept.ba18b0c3-8208-465a-9c95-2f85047e2939" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>

					<div class="testbox">
						<div>Vitamin A supplementation</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.c764e84f-cfb2-424a-acec-20e4fb8531b7" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>

						<label>
							<input id="" type="radio" data-value="No" name="concept.c764e84f-cfb2-424a-acec-20e4fb8531b7" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>
				</div>

				<div class="col4 last" style="width: 49%;">
					<div class="testbox">
						<div>Multi-vitamin</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.5712097d-a478-4ff4-a2aa-bd827a6833ed" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						<label>
							<input id="" type="radio" data-value="No" name="concept.5712097d-a478-4ff4-a2aa-bd827a6833ed" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>

					<div class="testbox">
						<div>Haematinics</div>
						<label>
							<input id="" type="radio" data-value="Yes" name="concept.5d935a14-9c53-4171-bda7-51da05fbb9eb" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						<label>
							<input id="" type="radio" data-value="No" name="concept.5d935a14-9c53-4171-bda7-51da05fbb9eb" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>
				</div>
			</div>
		</fieldset>

		<fieldset>
			<legend>Family Planning</legend>
			<div class="label title-label" style="width: auto; border-bottom: 1px solid rgb(221, 221, 221); padding: 10px 0px 2px 10px;">Family Planning<span class="important"></span></div>

			<field>
				<input type="hidden" id="family-planning-set" class=""/>
				<span id="family-planning-lbl" class="field-error" style="display: none"></span>
			</field>

			<div class="onerow floating-controls misc-info">
				<div class="col4" style="width: 48%;">
					
					<label for="374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" style="width: auto; color: #009384">FP Method </label>
					
					<select name="concept.374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
						<option value="0" >Select Option</option>
						<% if (familyPlanningOptions != null || familyPlanningOptions != "") { %>
						<% familyPlanningOptions.each { familyPlanningOption -> %>
						<option value="${familyPlanningOption.answerConcept.uuid}">${familyPlanningOption.answerConcept.name}</option>
						<% } %>
						<% } %>
					</select>
				</div>

				<div class="col4 last" style="width: 49%;">
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'date.374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '000AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: 'Date', useTime: false, defaultToday: false, endDate: new Date(), class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
				</div>

				<div class="col4 last" style="width: 100%; margin-top: 10px;">
					<label for="fp-comment" style="width: auto; color: #009384">Comments</label>
					<textarea name="comment.374AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="fp-comment" style="width: 97%"></textarea>
				</div>
			</div>




		</fieldset>

		<fieldset>
			<legend>Referral Options</legend>

			<field>
				<input type="hidden" id="referral-set" class=""/>
				<span id="referral-lbl" class="field-error" style="display: none"></span>
			</field>
			
			<div class="label title-label" style="width: auto; border-bottom: 1px solid rgb(221, 221, 221); padding: 10px 0px 2px 10px;">Next Visit<span class="important"></span></div>
			<div id="next-visit-date" class="onerow">
				<div class="col4" style="padding-top: 5px;">
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.ac5c88af-3104-4ca2-b1f7-2073b1364065', id: 'next-visit-date', label: 'Next Visit Date',useTime: false, startToday: true, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
				</div>
				<div class="clear"></div>
			</div>

			<div class="label title-label" style="width: auto; border-bottom: 1px solid rgb(221, 221, 221); padding: 20px 0px 2px 10px;">Referral Options<span class="important"></span></div>
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
						<select id="internalRefferal" name="internalRefferal">
							<option value="0">Select Option</option>
							<% if (internalReferrals != null || internalReferrals != "") { %>
							<% internalReferrals.each { internalReferral -> %>
							<option value="${internalReferral.uuid}" >${internalReferral.label}</option>
							<% } %>
							<% } %>
						</select>
					</div>

					<div id="externalRefferalDiv" style="display: none">
						<label> External Referral</label>
						<select id="externalRefferal" name="concept.18b2b617-1631-457f-a36b-e593d948707f">
							<option value="0">Select Option</option>
							<% if (externalReferrals != null || externalReferrals != "") { %>
								<% externalReferrals.each { externalReferral -> %>
									<option value="${externalReferral.uuid}" >${externalReferral.label}</option>
								<% } %>
							<% } %>
						</select>
					</div>
				</div>

				<div class="col4 last">
					<div id="externalRefferalFac" style="display: none">
						<label>Facility</label>
						<input type="text" id="referralFacility" name="concept.161562AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
					</div>
				</div>
			</div>

			<div class="onerow">
				<div class="col4">
					<div id="externalRefferalRsn" style="display: none">
						<label for="referralReason">Referral Reason</label>
						<select id="referralReason" name="concept.cb2890d4-e3de-449a-9d34-c9f59e87945a">
							<option value="0">Select Option</option>
							<% if (referralReasons != null || referralReasons != "") { %>
							<% referralReasons.each { referralReason -> %>
							<option value="${referralReason.uuid}" >${referralReason.label}</option>
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
					<textarea id="comments" name="comment.18b2b617-1631-457f-a36b-e593d948707f" style="width: 95.7%; resize: none;"></textarea>
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
					<h3>PNC SUMMARY &amp; CONFIRMATION</h3>
				</div>

				<div class="info-body">
					<table id="summaryTable">
						<tbody>
							<tr>
								<td><span class="status active"></span>Symptoms</td>
								<td>N/A</td>
							</tr>
							
							<tr>
								<td><span class="status active"></span>Examinations</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Prescriptions</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Diagnosis</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Investigations</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>PMTCT Information</td>
								<td>N/A</td>
							</tr>

							<tr>
							<td><span class="status active"></span>Cervical Screening</td>
							<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Suppliments</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Family Planning</td>
								<td>N/A</td>
							</tr>

							<tr>
								<td><span class="status active"></span>Outcome</td>
								<td>N/A</td>
							</tr>
						</tbody>
					</table>
					
					<div>
						<label style="padding: 3px 10px; border: 1px solid #fff799; background: rgb(255, 247, 153) none repeat scroll 0px 0px; cursor: pointer; font-weight: normal; margin-top: 12px; width: 96.5%;">
							<input id="exitPatientFromProgramme" type="checkbox" name="exitPatientFromProgramme">
							Exit Patient from Program
						</label>
					</div>

				</div>
			</div>
		</div>

		<div id="confirmationQuestion" class="focused" style="margin-top:20px">
			<field style="display: inline">
				<button class="button submit confirm" style="display: none;"></button>
			</field>
			
			<span value="Submit" class="button submit confirm" id="postnatal-examination-submit">
                <i class="icon-save small"></i>
                Save
            </span>
			
            <span id="cancelButton" class="button cancel">
                <i class="icon-remove small"></i>			
				Cancel
			</span>
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
                    <label>Dosage<span class="important">*<span></label>
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
                    <label>Number of Days<span class="important">*<span></label>
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

<div id="exitPncDialog" class="dialog" style="display: none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>
        <h3>Exit From Program</h3>
    </div>

    <div class="dialog-content">
        <ul>
			<li>
                <label>Program</label>
                <input type="text" readonly="" value="POST-NATAL CLINIC">
            </li>
			
			<li>
				${ui.includeFragment("uicommons", "field/datetimepicker", [id: 'complete-date', label: 'Completion Date', formFieldName: 'referredDate', useTime: false, defaultToday: true, endDate: new Date(), startDate: patientProgram.dateEnrolled])}
			</li>
			
            <li>
                <label for="programOutcome">Outcome</label>
                <select name="programOutcome" id="programOutcome">
                    <option value="0">Choose Outcome</option>
                    <% if (possibleProgramOutcomes != null || possibleProgramOutcomes != "") { %>
                    <% possibleProgramOutcomes.each { outcome -> %>
                    <option id="${outcome.id}" value="${outcome.id}">${outcome.name}</option>
                    <% } %>
                    <% } %>
                </select>
            </li>
			
            <button class="button confirm" id="processProgramExit" style="float: right; margin-right: 18px;">
				<i class="icon-save small"></i>
				Save
			</button>
			
            <span class="button cancel">Cancel</span>
        </ul>
    </div>
</div>