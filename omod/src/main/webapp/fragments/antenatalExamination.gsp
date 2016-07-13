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
    var selectedDiagnosisIds = [];
    var investigationQuestionUuid = "1ad6f4a5-13fd-47fc-a975-f5a1aa61f757";
    var provisionalDiagnosisQuestionUuid = "b8bc4c9f-7ccb-4435-bc4e-646d4cf83f0a";
    var finalDiagnosisQuestionUuid = "7033ef37-461c-4953-a757-34722b6d9e38"
    var diagnosisQuestionUuid = "";
    var NavigatorController;
	
	var examinationArray = [];
	var investigationArray = [];
    var diagnosisArray = [];


    var emrMessages = {};

	emrMessages["numericRangeHigh"] = "value should be less than {0}";
	emrMessages["numericRangeLow"] = "value should be more than {0}";
	emrMessages["requiredField"] = "Mandatory Field. Kindly provide details";
	emrMessages["numberField"] = "Value not a number";
    var currentWorkflowBeingEdited;
    var patientProgramForWorkflowEdited;
    jq(function() {

		jq(".infant-feeding").hide();
		jq(".decision-feeding").hide();

        jq('input[type=radio][name="concept.fb5a5471-e912-4288-8c25-750f7f88281f"]').change(function() {
            if (this.value == '4536f271-5430-4345-b5f7-37ca4cfe1553') {
                jq(".infant-feeding").show();
            }
            else if (this.value == '606720bb-4a7a-4c4c-b3b5-9a8e910758c9') {
                jq(".infant-feeding").hide();
                jq(".decision-feeding").hide();
            }
        });
        jq('input[type=radio][name="concept.8a3c420e-b4ff-4710-81fd-90c7bfa6de72"]').change(function() {
            if (this.value == '4536f271-5430-4345-b5f7-37ca4cfe1553') {
                jq(".decision-feeding").show();
            }
            else if (this.value == '606720bb-4a7a-4c4c-b3b5-9a8e910758c9') {
                jq(".decision-feeding").hide();
            }
        });

        jq(".datepicker").datepicker({
            changeMonth: true,
            changeYear: true,
            dateFormat: 'yy-mm-dd'
        });

        var vaccinationDialog = emr.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
            selector: '#vaccinations-dialog',
            actions: {
                confirm: function () {
                    if (jq('#vaccine-state').val() == 0) {
						jq().toastmessage('showErrorToast', "Kindly select a vaccine state!");
						return false;
					}
					
					var idnt = jq('#vaccine-idnt').val();
					var prog = jq('#vaccine-prog').val();
					var name = jq('#vaccine-name').val();
					
					var state = jq('#vaccine-state').val();
					
					var stateData = {
						patientProgramId: prog,
						programWorkflowId: idnt,
						programWorkflowStateId: jq('#vaccine-state').val(),
						onDateDMY: jq('#vaccine-date-field').val()
					}

					jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "changeToState") }', stateData)
					.success(function (data) {
						jq().toastmessage('showNoticeToast', data.message);
						
						showEditWorkflowPopup(name, prog, idnt);
						
						jq('#state_name_'+idnt).text(jq('#vaccine-state option:selected').text());
						jq('#state_date_'+idnt).text(moment(jq('#vaccine-date-field').val()).fromNow());
						
						jq('#main-show-'+idnt).show();
						jq('#no-show-'+idnt).hide();
						
						jq('#immunizations-set').val('SET');
						
						vaccinationDialog.close();
						return false;
						
					}).error(function (xhr, status, err) {
						jq().toastmessage('showErrorToast', "AJAX error!" + err);
						return false;
					});
                },
                cancel: function () {
                    vaccinationDialog.close();
                }
            }
        });

        jq('.update-vaccine a').click(function(){
			var idnt = jq(this).data('idnt');
			var name = jq(this).data('name');
			var prog = jq(this).data('prog');
			
			jq('#vaccine-idnt').val(idnt);
			jq('#vaccine-name').val(name);
			jq('#vaccine-prog').val(prog);
			
			jq('#vaccine-state').html(jq('#changeToState_'+idnt).html());			
		
			vaccinationDialog.show();		
		});

        jq("#programExit").on("click", function (e) {
            exitcwcdialog.show();
        });

        jq('.chevron').click(function (){
            var idnt = jq(this).data('idnt');
            var name = jq(this).data('name');
            var prog = jq(this).data('prog');

            if (jq(this).hasClass('icon-chevron-right')){
                jq(this).removeClass('icon-chevron-right');
                jq(this).addClass('icon-chevron-down');

                showEditWorkflowPopup(name, prog, idnt);
            }
            else{
                jq(this).removeClass('icon-chevron-down');
                jq(this).addClass('icon-chevron-right');

                jq("#currentStateDetails_" + idnt).show();
                jq("#" + idnt).hide();
            }
        });
		
		NavigatorController = new KeyboardController(jq('#antenatalExaminationsForm'));
        ko.applyBindings(drugOrders, jq(".drug-table")[0]);
		
        var patientProfile = JSON.parse('${patientProfile}');

        if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        }


        var lastMenstrualPeriod = _.find(patientProfile.details, function(profile){
            return profile.uuid == "1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
        });
        var lastMenstrualPeriod = moment(lastMenstrualPeriod.value, "DD-MM-YYYY");
        var todaysDate = moment();
        var gestationInWeeks = Math.ceil(moment.duration(todaysDate.diff(lastMenstrualPeriod)).asWeeks());

        if(gestationInWeeks < 16)
        {
            jq("#lessthan16").show();
            jq("#next-visit-date").hide();
            jq("#maturity").val(gestationInWeeks + " Weeks");
        }
        else if(gestationInWeeks >= 16)
        {
            jq("#lessthan16").hide();
        }


        var examinations = [];        
		
        var adddrugdialog = emr.setupConfirmationDialog({
			dialogOpts: {
				overlayClose: false,
				close: true
			},
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
                            jq('#drugUnitsSelect').append(jq('<option>').val(drugUnit.id).text(drugUnit.label));
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

        //select whether diagnosis is provisional or final
        jq("#provisional-diagnosis").on("click", function(){
            diagnosisQuestionUuid = provisionalDiagnosisQuestionUuid;
        })
        jq("#final-diagnosis").on("click", function(){
            diagnosisQuestionUuid = finalDiagnosisQuestionUuid;
        })

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
                jq('#summaryTable tr:eq(1) td:eq(1)').text('N/A');
            }
            else{
                var diagnoses = '';
                diagnosisArray.forEach(function(diagnosis){
                    diagnoses += diagnosis.label +'<br/>'
                });
                jq('#summaryTable tr:eq(1) td:eq(1)').html(diagnoses);
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
				jq('#summaryTable tr:eq(2) td:eq(1)').text('N/A');
			}
			else{
				var exams = '';
				investigationArray.forEach(function(investigation){
				  exams += investigation.label +'<br/>'
				});
				jq('#summaryTable tr:eq(2) td:eq(1)').html(exams);
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
		
		jq('.conditions-info input').change(function(){
			jq('#conditions-info-set').val('SET');
			var output = '';

			if (jq('input[value="a8390549-394c-44c7-a0c3-404c1799b1b9"]:checked').length > 0) {
				output += 'Hypertension<br/>';
			}
			
			if (jq('input[value="119481AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"]:checked').length > 0) {
				output += 'Diabetes<br/>';
			}
			
			if (jq('input[value="4e896673-d822-458e-bbfe-604747e0afe8"]:checked').length > 0) {
				output += 'Epilepsy<br/>';
			}
			
			if (jq('input[value="4c9b4d7d-7cb0-4d49-a833-2a13490b4632"]:checked').length > 0) {
				output += 'STIs / RTI<br/>';
			}
			
			if (jq('input[value="0731fc60-1c30-464b-93e9-e4adc8537e42"]:checked').length > 0) {
				output += 'Malaria in Pregnancy<br/>';
			}
						
			if (output == ''){
				output = 'N/A';
				jq('#conditions-info-set').val('');
			}
			
			jq('#summaryTable tr:eq(3) td:eq(1)').html(output);
		});
		
		jq('.hiv-info input').change(function(){
			jq('#hiv-info-set').val('SET');
			
			var output = '';

			if (!jq("input[name='concept.1406dbf3-05da-4264-9659-fb688cea5809']:checked").val()) {}
			else {
				output += 'Prior Known Status: ' + jq("input[name='concept.1406dbf3-05da-4264-9659-fb688cea5809']:checked").data('value') + '<br/>';
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
			
			jq('#summaryTable tr:eq(4) td:eq(1)').html(output);
			
			if (jq(this).attr('name') == 'concept.93366255-8903-44af-8370-3b68c0400930'){
				if (jq(this).val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
					jq('#partner-result').show(300);
				}
				else{
					jq('#partner-result').hide(300);
					jq('#partner-result input').removeAttr('checked');
				}
			};

            if (jq(this).attr('name') == 'concept.93366255-8903-44af-8370-3b68c0400930'){
                if (jq(this).val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
                    jq('#partner-result').show(300);
                }
                else{
                    jq('#partner-result').hide(300);
                    jq('#partner-result input').removeAttr('checked');
                }
            };
		});
		
		jq('.treatment-info input').change(function(){
			jq('#treatment-info-set').val('SET');
			
			var output = '';

			if (!jq("input[name='concept.159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").val()) {}
			else {
				output += 'Deworming: ' + jq("input[name='concept.159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").val()) {}
			else {
				output += 'Received LLITN: ' + jq("input[name='concept.160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").data('value') + '<br/>';
			}
			
			if (!jq("input[name='concept.0a92efcc-51b3-448d-b4e3-a743ea5aa18c']:checked").val()) {}
			else {
				output += 'ANC Exercise Given: ' + jq("input[name='concept.0a92efcc-51b3-448d-b4e3-a743ea5aa18c']:checked").data('value') + '<br/>';
			}
			
			jq('#summaryTable tr:eq(5) td:eq(1)').html(output);
		});
		
		jq('#availableReferral').change(function(){
			if (jq(this).val() == "1"){
				jq('#summaryTable tr:eq(6) td:eq(1)').text('Internal Referral');
				jq('#referral-set').val('SET');
			}
			else if (jq(this).val() == "2"){
				jq('#summaryTable tr:eq(6) td:eq(1)').text('External Referral');
				jq('#referral-set').val('SET');
			}
			else {
				jq('#summaryTable tr:eq(6) td:eq(1)').text('N/A');
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
    function isEmpty(o) {
        return o == null || o == '';
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
                    jq().toastmessage('showNoticeToast', data.message);
                    refreshPage();
                    jq("#programExit").hide();
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });
    }

    function refreshPage() {
        window.location.reload();
    }

    function showEditWorkflowPopup(wfName, patientProgramId, programWorkflowId) {
        jq("#currentStateDetails_" + programWorkflowId).hide();
        var params = {
            patientProgramId: patientProgramId,
            programWorkflowId: programWorkflowId
        }
        jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "getPossibleNextStates") }', params)
                .success(function (data) {
                    //load drop down
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });
        jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "getPatientStates") }', params)
                .success(function (data) {
                    //load list of previous vaccines
                    var tableId = "workflowTable_" + programWorkflowId;
                    jq('#' + tableId + ' > tbody > tr').remove();
                    var tbody = jq('#' + tableId + ' > tbody');

                    if (data.length == 0) {
                        tbody.append('<tr align="center"><td colspan="5">No Previous Vaccinations found for ' + wfName + '</td></tr>');
                    } else {
                        for (index in data) {
                            var item = data[index];
                            var row = '<tr>';
                            row += '<td>' + (parseInt(index)+1) + '</td>';
                            row += '<td>' + item.stateName + '</td>';
                            row += '<td>' + moment(item.startDate, 'DD.MMM.YYYY').format('DD/MM/YYYY') + '</td>';
                            row += '<td>' + moment(item.dateCreated, 'DD.MMM.YYYY').format('DD/MM/YYYY') + '</td>';
                            row += '<td>' + item.creator + '</td>';
                            row += '</tr>';
                            tbody.append(row);
                        }

                    }

                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });


        jq("#" + programWorkflowId).show();
        currentWorkflowBeingEdited = programWorkflowId;
        patientProgramForWorkflowEdited = patientProgramId;
    }

    function handleChangeWorkflowState(c) {
        var stateId = jq("#changeToState_" + c).val();
        var onDate = jq("#datepicker_" + c).val()
        if (stateId == 0) {
            jq().toastmessage('showErrorToast', "Select State!");
            return;
        } else if (isEmpty(onDate)) {
            jq().toastmessage('showErrorToast', "Select Date!");
            return;
        } else {
            jq().toastmessage('showNoticeToast', "Saving State...!");
            processHandleChangeWorkflowState(stateId, onDate);
        }

    }

    function processHandleChangeWorkflowState(stateId, onDateDMY) {
        var ppId = patientProgramForWorkflowEdited;
        var wfId = currentWorkflowBeingEdited;
        var lastStateStartDate = jq('#lastStateStartDate').val();
        var lastStateEndDate = jq('#lastStateEndDate').val();
        var lastState = jq('lastState').val();
        var stateData = {
            patientProgramId: ppId,
            programWorkflowId: wfId,
            programWorkflowStateId: stateId,
            onDateDMY: onDateDMY
        }

        jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "changeToState") }', stateData)
                .success(function (data) {
                    jq().toastmessage('showNoticeToast', data.message);
                    return data.status;
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });
    }

    function hideLayer(divId) {
        jq("#" + ddiagnosisivId).hide();
        jq("#currentStateDetails_" + divId).show();
        refreshPage();
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
	.patient-profdiagnosisile{
		border: 1px solid #eee;
		margin: 5px 0;
		padding: 7px 12px;
	}
	#profile-items small{
		margin-left: 5.5%;
	}
	#profile-items small:first-child{
		margin-left: 2px;
	}
	table[id*='workflowTable_'] th:first-child{
		width: 5px;
	}
	table[id*='workflowTable_'] th:nth-child(3),
	table[id*='workflowTable_'] th:nth-child(4){
		width: 80px;
	}
	.update-vaccine{
		float: right;
	}
	.update-vaccine a{
		cursor: pointer;
	}
	.update-vaccine a:hover{
		text-decoration: none;
	}
	.simple-form-ui section, .simple-form-ui #confirmation, .simple-form-ui form section, .simple-form-ui form #confirmation {
		background: #fff none repeat scroll 0 0;
	}
	.chevron{
		color: #4a80ff !important;
		cursor: pointer;
		font-size: 100% !important;
		margin: 5px;
		text-decoration: none;
	}
	.floating-controls{
		margin-top: 5px;
	}
	.floating-controls input{
		cursor: pointer;
		float: none!important;
	}
	.floating-controls label{
		cursor: pointer;
	}
	.floating-controls span{
		color: #f26522;
	}
	.floating-controls textarea{
		resize: none;
	}
	.conditions-info label{
		color: #f26522;
		width: auto;
	}
	#partner-result{
		display: none;
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

<form method="post" id="antenatalExaminationsForm" class="simple-form-ui">
	<input type="hidden" name="patientId" value="${patient.patientId}" >
	<input type="hidden" name="queueId" value="${queueId}" >
	
	<section>
		<span class="title">Clinical Notes</span>

        <fieldset class="no-confirmation">
            <legend>Immunizations</legend>

            <div style="padding: 0 4px">
                <field>

                </field>

                <div style="min-width: 78%" class="col16 dashboard">
                    <% patientProgram.program.workflows.each { workflow -> %>
                    <% def stateId; def stateStart; def stateName; %>
                    <div id="data-holder">
                        <div style="" valign="top">
                            <div class="info-section">
                                <% patientProgram.states.each { state -> %>
                                <% if (!state.voided && state.state.programWorkflow.programWorkflowId == workflow.programWorkflowId && state.active) {
                                    stateId = state.state.concept.conceptId;
                                    stateName = state.state.concept.name;
                                    stateStart = state.startDate;
                                } %>
                                <% } %>

                                <div class="info-header">
                                    <i class="icon-medicine"></i>

                                    <h3>${workflow.concept.name}</h3>
                                    <a><i class="icon-chevron-right small right chevron" data-idnt="${workflow.programWorkflowId}" data-name="${workflow.concept.name}" data-prog="${patientProgram.patientProgramId}"></i></a>
                                </div>

                                <div class="info-body">
                                    <div id="${workflow.programWorkflowId}" style="display: none;">
                                        <table id="workflowTable_${workflow.programWorkflowId}">
                                            <thead>
                                            <tr>
                                            <thead>
                                            <th>#</th>
                                            <th>VACCINE</th>
                                            <th>GIVEN ON</th>
                                            <th>RECORDED</th>
                                            <th>PROVIDER</th>
                                            </thead>
                                        </tr>
                                        </thead>

                                            <tbody>

                                            </tbody>
                                        </table>

                                        <div class="update-vaccine">
											<a data-idnt="${workflow.programWorkflowId}" data-name="${workflow.concept.name}" data-prog="${patientProgram.patientProgramId}">
												<i class="icon-pencil small"></i>
												Update Vaccine
											</a>											
										</div>

                                        <div class="">&nbsp;</div>

                                        <div style="display: none">
											<select name="changeToState_${workflow.programWorkflowId}"
													id="changeToState_${workflow.programWorkflowId}">
												<option value="0">Select a State</option>
												<% if (workflow.states != null || workflow.states != "") { %>
												<% workflow.states.each { state -> %>
												<option id="${state.id}"
														value="${state.id}">${state.concept.name}</option>
												<% } %>
												<% } %>
											</select>
										</div>

                                    </div>

                                   <div id="currentStateDetails_${workflow.programWorkflowId}">
										<% if (stateId != null) { %>
											<div id='main-show-${workflow.programWorkflowId}'>
												<span class="status active"></span>
												<span id="state_name_${workflow.programWorkflowId}">${stateName}</span>
												
												<small style="font-size: 77%; margin-left: 10px;">
													( <span class="icon-time"></span>
													Date: <span id="state_date_${workflow.programWorkflowId}">${ui.formatDatePretty(stateStart)}</span> )
												</small>												
											</div>											
										<% } else { %>
											<div id="no-show-${workflow.programWorkflowId}" style="margin-left: 20px; color: rgb(153, 153, 153);">
												<em>(No Previous Vaccinations Found)</em>												
											</div>
									 		<div id='main-show-${workflow.programWorkflowId}' style="display: none;">
												<span class="status active"></span>
												<span id="state_name_${workflow.programWorkflowId}"></span>
												
												<small style="font-size: 77%; margin-left: 10px;">
													( <span class="icon-time"></span>
													Date: <span id="state_date_${workflow.programWorkflowId}"></span> )
												</small>												
											</div>
										<% } %>

									</div>

                                </div>
                            </div>
                        </td>
                        </div>
                        <% } %>

                    </div>
                </div>
            </div>
        </fieldset>

		<fieldset class="no-confirmation">
			<legend>Examinations</legend>
			<div style="padding: 0 4px">
                <div style="display:none" id="lessthan16">
                    <p>There is palpable mass, Please select next visit date</p>

                    <label for="maturity" class="label title-label">Maturity <span class="important"></span></label>
                    <input type="text" id="maturity" disabled="disabled" />
                    <div>
                        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.ac5c88af-3104-4ca2-b1f7-2073b1364065', id: 'under-16-weeks-next-visit-date', label: 'Next visit date', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
                    </div>
                    <label for="fundalHeight" class="label title-label">Fundal Height<span class="important"></span></label>
                    <input type="text" id="fundalHeight" name="concept.1439AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value=""/>
                </div>
                <div>
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
			</div>				
		</fieldset>

        <fieldset class="no-confirmation">
            <legend>Diagnosis</legend>
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
            <br><br><br>
            <div>
                <label for="diagnoses" class="label title-label">Diagnosis <span class="important"></span></label>
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
			<legend>Conditions</legend>
			<label class="label title-label">Conditions <span class="important"></span></label>
			<field>
				<input type="hidden" id="conditions-info-set" class=""/>
				<span id="conditions-info-lbl" class="field-error" style="display: none"></span>
			</field>
				
			<div class="onerow floating-controls conditions-info">
				<div class="col4" style="width: 48%;">
					<label>
						<input type="checkbox" name="concept.7033ef37-461c-4953-a757-34722b6d9e38" value="a8390549-394c-44c7-a0c3-404c1799b1b9"
							<% if (preExisitingConditions.contains("a8390549-394c-44c7-a0c3-404c1799b1b9")) { %>
								checked="checked"
							<% } %>
						>
						Hypertension
					</label><br/>
				
					<label>
						<input type="checkbox" name="concept.7033ef37-461c-4953-a757-34722b6d9e38" value="119481AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
							<% if (preExisitingConditions.contains("119481AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")) { %>
								checked="checked"
							<% } %>
						>
						Diabetes
					</label><br/>
					
					<label>
						<input type="checkbox" name="concept.7033ef37-461c-4953-a757-34722b6d9e38" value="4e896673-d822-458e-bbfe-604747e0afe8"
							<% if (preExisitingConditions.contains("4e896673-d822-458e-bbfe-604747e0afe8")) { %>
								checked="checked"
							<% } %>
						>
						Epilepsy
					</label>
				
				</div>
				
				<div class="col4 last" style="width: 49%;">
					<label>
						<input type="checkbox" name="concept.7033ef37-461c-4953-a757-34722b6d9e38" value="0731fc60-1c30-464b-93e9-e4adc8537e42"
							<% if (preExisitingConditions.contains("0731fc60-1c30-464b-93e9-e4adc8537e42")) { %>
								checked="checked"
							<% } %>
						>
						Malaria in Pregnancy
					</label><br/>
					
					<label>
						<input type="checkbox" name="concept.7033ef37-461c-4953-a757-34722b6d9e38" value="4c9b4d7d-7cb0-4d49-a833-2a13490b4632"
							<% if (preExisitingConditions.contains("4c9b4d7d-7cb0-4d49-a833-2a13490b4632")) { %>
								checked="checked"
							<% } %>
						>
						STIs/RTI
					</label>				
				</div>				
			</div>
		</fieldset>

        <fieldset>
            <legend>Infant Feeding</legend>
            <label for="investigation" class="label title-label" style="width: auto;">Infant Feeding<span class="important"></span></label>

            <div class="onerow floating-controls hiv-info">
                <div class="col4" style="width: 48%;">
                    <div>
                        <span>Infant feeding counseling done?</span><br/>
                        <label>
                            <input id="infant-feeding-counseled" type="radio" data-value="Yes" name="concept.fb5a5471-e912-4288-8c25-750f7f88281f" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
                            Yes
                        </label><br/>

                        <label>
                            <input id="infant-feeding-counseled" type="radio" data-value="No" name="concept.fb5a5471-e912-4288-8c25-750f7f88281f" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
                            No
                        </label>
                    </div>

                    <div style="margin-top: 20px;" class="infant-feeding">
                        <span>Infant feeding options for HIV infected discussed?</span><br/>
                        <label>
                            <input id="hiv-feeding-counseled" type="radio" data-value="Yes" name="concept.8a3c420e-b4ff-4710-81fd-90c7bfa6de72" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
                            Yes
                        </label><br/>

                        <label>
                            <input id="hiv-feeding-counseled" type="radio" data-value="No" name="concept.8a3c420e-b4ff-4710-81fd-90c7bfa6de72" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
                            No
                        </label>
                    </div>
                </div>

                <div class="col4 last infant-feeding" style="width: 49%;">
                    <div>
                        <span>Counseling on exclusive breastfeeding done?</span><br/>
                        <label>
                        <input id="exclusive-counseled" type="radio" data-value="Yes" name="concept.42197783-8b24-49b0-b290-cbb368fa0113" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
                        Yes
                    </label><br/>

                        <label>
                            <input id="exclusive-counseled" type="radio" data-value="No" name="concept.42197783-8b24-49b0-b290-cbb368fa0113" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
                            No
                        </label>
                    </div>

                    <div style="margin-top: 20px;" class="decision-feeding">
                        <span>Mother's Breastfeeding decision?</span><br/>
                        <label>
                            <input id="breastfeeding-decision" type="radio" data-value="Positive" name="concept.a0bf86bb-b50e-4be4-a54c-32518bfb843f" value="a082375c-bfe4-4395-9ed5-d58e9ab0edd3">
                            Exclusive
                        </label><br/>

                        <label>
                            <input id="breastfeeding-decision" type="radio" data-value="Negative" name="concept.a0bf86bb-b50e-4be4-a54c-32518bfb843f" value="6225dd6f-f491-4c2b-ad88-b81eb5763650">
                            Replacement
                        </label><br/>

                        <label>
                            <input id="breastfeeding-decision" type="radio" data-value="Unknown" name="concept.a0bf86bb-b50e-4be4-a54c-32518bfb843f" value="8b8e1133-9fe1-49c9-9365-fdd49c95ee42">
                            Not Decided
                        </label>
                    </div>
                </div>
            </div>
        </fieldset>
		
		<fieldset>
			<legend>PMTCT Information</legend>
			<label for="investigation" class="label title-label" style="width: auto;">PMTCT Information<span class="important"></span></label>
			
			<field>
				<input type="hidden" id="hiv-info-set" class=""/>
				<span id="hiv-info-lbl" class="field-error"></span>
			</field>
			
			<div class="onerow floating-controls hiv-info">
				<div class="col4" style="width: 48%;">
					<div>
						<span>Prior Known Status:</span><br/>
						<label>
							<input id="prior-status-positive" type="radio" data-value="Positive" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="aca8224b-2f4b-46cb-b75d-9e532745d61f">
							Positive
						</label><br/>
						
						<label>
							<input id="prior-status-negative" type="radio" data-value="Negative" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="7480ebef-125b-4e0d-a8e5-256224ee31a0">
							Negative
						</label><br/>
						
						<label>
							<input id="prior-status-unknown" type="radio" data-value="Unknown" name="concept.1406dbf3-05da-4264-9659-fb688cea5809" value="ec8e61d3-e9c9-4020-9c62-8403e14af5af">
							Unknown
						</label>				
					</div>
					<div style="margin-top: 20px;">
						<span>Patner Tested?</span><br/>
						<label>
							<input id="couple-counselled" type="radio" data-value="Yes" name="concept.93366255-8903-44af-8370-3b68c0400930" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						
						<label>
							<input id="couple-counselled" type="radio" data-value="No" name="concept.93366255-8903-44af-8370-3b68c0400930" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>
                    <!-- Concepts still missing  for this block-->
                    <div>
                        <span>Assessed through?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuid" value="conceptuuid">
                            WHO Stage
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.conceptuuid" value="conceptuuid">
                            CD4 Count
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
                    <div>
                        <span>Start on ART?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuid" value="conceptuuid">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.conceptuuid" value="conceptuuid">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>

                    <div>
                        <span>NVP for Mother?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuid" value="conceptuuid">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.2conceptuuid" value="conceptuuid">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
                    <!--end of concept missing block-->
                    <div>
                        <span>Screened for TB?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.26a924e0-1648-4112-959f-d47647021dc9" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.26a924e0-1648-4112-959f-d47647021dc9" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
				</div>
				
				<div class="col4 last" style="width: 49%;">
					<div>
						<span>Couple Counselled?</span><br/>
						<label>
							<input id="couple-counselled" type="radio" data-value="Yes" name="concept.27b96311-bc00-4839-b7c9-31401b44cd3a" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						
						<label>
							<input id="couple-counselled" type="radio" data-value="No" name="concept.27b96311-bc00-4839-b7c9-31401b44cd3a" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label><br/>
						
						<label>
							&nbsp;
						</label>
					</div>

					<div style="margin-top: 20px;" id="partner-result">
						<span>Patner Results</span><br/>
						<label>
							<input id="prior-status-positive" type="radio" data-value="Positive" name="concept.df68a879-70c4-40d5-becc-a2679b174036" value="aca8224b-2f4b-46cb-b75d-9e532745d61f">
							Positive
						</label><br/>
						
						<label>
							<input id="prior-status-negative" type="radio" data-value="Negative" name="concept.df68a879-70c4-40d5-becc-a2679b174036" value="7480ebef-125b-4e0d-a8e5-256224ee31a0">
							Negative
						</label><br/>
						
						<label>
							<input id="prior-status-unknown" type="radio" data-value="Unknown" name="concept.df68a879-70c4-40d5-becc-a2679b174036" value="ec8e61d3-e9c9-4020-9c62-8403e14af5af">
							Unknown
						</label>
					</div>
                    <!-- Concepts still missing  for this block-->
                    <div>
                        <span>AZT Given?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuida" value="conceptuuid">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.conceptuuid" value="conceptuuid">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
                    <div>
                        <span>HAART Given?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuida" value="conceptuuid">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.conceptuuid" value="conceptuuid">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
                    <div>
                        <span>CTX Given?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuid" value="conceptuuid3">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.conceptuuid" value="conceptuuid9">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
                    <div>
                        <span>NVP for Baby?</span><br/>
                        <label>
                            <input id="couple-counselled" type="radio" data-value="Yes" name="concept.conceptuuida" value="conceptuuid">
                            Yes
                        </label><br/>

                        <label>
                            <input id="couple-counselled" type="radio" data-value="No" name="concept.conceptuuid" value="conceptuuid">
                            No
                        </label><br/>

                        <label>
                            &nbsp;
                        </label>
                    </div>
                    <!--end of concept missing block-->

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
			<legend>Treatment</legend>
			<label class="label title-label" style="width: auto;">Treatment<span class="important"></span></label>
			
			<field>
				<input type="hidden" id="treatment-info-set" class=""/>
				<span id="treatment-info-lbl" class="field-error" style="display: none"></span>
			</field>
			
			<div class="onerow floating-controls treatment-info">
				<div class="col4" style="width: 48%;">
					<div>
						<span>Deworming</span><br/>
						<label>
							<input id="couple-counselled" data-value="Yes" type="radio" name="concept.159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						
						<label>
							<input id="couple-counselled" data-value="No" type="radio" name="concept.159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label><br/>
					</div>
					
					<div style="margin-top: 20px;">
						<span>Received LLITN</span><br/>
						<label>
							<input id="couple-counselled" data-value="Yes" type="radio" name="concept.160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						<label>
							<input id="couple-counselled" data-value="No" type="radio" name="concept.160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>					
				</div>
				
				<div class="col4 last" style="width: 49%;">
					<div>
						<span>ANC Exercise given?</span><br/>
						<label>
							<input id="couple-counselled" data-value="Yes" type="radio" name="concept.0a92efcc-51b3-448d-b4e3-a743ea5aa18c" value="4536f271-5430-4345-b5f7-37ca4cfe1553">
							Yes
						</label><br/>
						<label>
							<input id="couple-counselled" data-value="No" type="radio" name="concept.0a92efcc-51b3-448d-b4e3-a743ea5aa18c" value="606720bb-4a7a-4c4c-b3b5-9a8e910758c9">
							No
						</label>
					</div>				
				</div>
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
            <div id="next-visit-date" class="onerow">
                ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.ac5c88af-3104-4ca2-b1f7-2073b1364065', id: 'next-visit-date', label: 'Next Visit Date', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
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
						<tbody>
							<tr>
								<td><span class="status active"></span>Examinations</td>
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
								<td><span class="status active"></span>Prescriptions</td>
								<td>N/A</td>
							</tr>
							
							<tr>
								<td><span class="status active"></span>Conditions</td>
								<td>N/A</td>
							</tr>
							
							<tr>
								<td><span class="status active"></span>PMTCT Information</td>
								<td>N/A</td>
							</tr>
							
							<tr>
								<td><span class="status active"></span>Treatment</td>
								<td>N/A</td>
							</tr>
							
							<tr>
								<td><span class="status active"></span>Outcome</td>
								<td>N/A</td>
							</tr>
						</tbody>
					</table>
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

<div id="vaccinations-dialog" class="dialog" style="display: none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>
        <h3>UPDATE VACCINE</h3>
    </div>

    <div class="dialog-content">
        <ul>
			<li>
				<label for="vaccine-name">Vaccine Name:</label>
				<input type="text"   id="vaccine-name" readonly="">
				<input type="hidden" id="vaccine-idnt" readonly="">
				<input type="hidden" id="vaccine-prog" readonly="">
			</li>
			
			<li>
				<label for="vaccine-state">Change State:</label>
				<select id="vaccine-state">
					<option value="0">Select a State</option>
				</select>
			</li>
			
			<li>				
				${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'vaccine-date', id: 'vaccine-date', label: 'Change Date', useTime: false, defaultToday: true,startDate: patient.birthdate, endDate: new Date()])}
			</li>
			
			<span class="button confirm" style="float: right; margin-right: 17px;">
				<i class="icon-save small"></i>
				Save
			</span>
			
			<span class="button cancel">Cancel</span>
		</ul>
    </div>
</div>
