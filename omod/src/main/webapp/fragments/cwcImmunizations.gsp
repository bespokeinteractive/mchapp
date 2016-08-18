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

    var outcomeId;

    jq(function () {
        function SubmitInformation(){
            var data = jq("form#cwcExaminationsForm").serialize();
            data = data + "&" + objectToQueryString.convert(drugOrders["drug_orders"]);

            jq.post('${ui.actionLink("mchapp", "childWelfareExamination", "saveCwcExaminationInformation")}',
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

        //submit data
        jq("#antenatalExaminationSubmitButton").on("click", function (event) {
            event.preventDefault();

            if (jq('#exitPatientFromProgramme:checked').length > 0){
                exitcwcdialog.show();
            }else{
                SubmitInformation();
            }
        });

        var exitcwcdialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#exitCwcDialog',
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

                                jq('#state_name_' + idnt).text(jq('#vaccine-state option:selected').text());
                                jq('#state_date_' + idnt).text(moment(jq('#vaccine-date-field').val()).fromNow());

                                jq('#main-show-' + idnt).show();
                                jq('#no-show-' + idnt).hide();

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
                    return false;
                }
            }
        });

        jq('.update-vaccine a').click(function () {
            var idnt = jq(this).data('idnt');
            var name = jq(this).data('name');
            var prog = jq(this).data('prog');

            jq('#vaccine-idnt').val(idnt);
            jq('#vaccine-name').val(name);
            jq('#vaccine-prog').val(prog);

            jq('#vaccine-state').html(jq('#changeToState_' + idnt).html());

            vaccinationDialog.show();
        });

        jq('.chevron').click(function () {
            var idnt = jq(this).data('idnt');
            var name = jq(this).data('name');
            var prog = jq(this).data('prog');

            if (jq(this).hasClass('icon-chevron-right')) {
                jq(this).removeClass('icon-chevron-right');
                jq(this).addClass('icon-chevron-down');

                showEditWorkflowPopup(name, prog, idnt);
            }
            else {
                jq(this).removeClass('icon-chevron-down');
                jq(this).addClass('icon-chevron-right');

                jq("#currentStateDetails_" + idnt).show();
                jq("#currentStateVaccine_" + idnt).hide();
            }
        });

        NavigatorController = new KeyboardController(jq('#cwcExaminationsForm'));
        ko.applyBindings(drugOrders, jq(".drug-table")[0]);


        var examinations = [];

        var adddrugdialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#prescription-dialog',
            actions: {
                confirm: function () {
                    if (!drugDialogVerified()){
                        jq().toastmessage('showErrorToast', 'Ensure fields marked in red have been properly filled before you continue')
                        return false;
                    }

                    addDrug();
                    jq("#drugForm")[0].reset();
                    jq('select option[value!="0"]', '#drugForm').remove();
                    adddrugdialog.close();
                },
                cancel: function () {
                    jq("#drugForm")[0].reset();
                    jq('select option[value!="0"]', '#drugForm').remove();
                    adddrugdialog.close();
                }
            }
        });

        jq("#availableReferral").on("change", function () {
            selectReferrals(jq("#availableReferral").val());
        });

        jq("#addDrugsButton").on("click", function (e) {
            adddrugdialog.show();
        });

        jq(".drug-name").on("focus.autocomplete", function () {
            var selectedInput = this;
            jq(this).autocomplete({
                minLength: 3,
                source: function (request, response) {
                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getDrugs") }',
                            {
                                q: request.term
                            }
                    ).success(function (data) {
                                var results = [];
                                for (var i in data) {
                                    var result = {label: data[i].name, value: data[i].id};
                                    results.push(result);
                                }
                                response(results);
                            });
                },
                select: function (event, ui) {
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
                    ).success(function (data) {
                                var formulations = jq.map(data, function (formulation) {
                                    jq('#formulationsSelect').append(jq('<option>').attr('value', formulation.id).text(formulation.name + ':' + formulation.dozage));
                                });
                            });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getFrequencies") }').success(function (data) {
                        var frequencies = jq.map(data, function (frequency) {
                            jq('#frequencysSelect').append(jq('<option>').attr('value', frequency.uuid).text(frequency.name));
                        });
                    });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getDrugUnit") }').success(function (data) {
                        var durgunits = jq.map(data, function (drugUnit) {
                            console.log(drugUnit);
                            jq('#drugUnitsSelect').append(jq('<option>').val(drugUnit.id).text(drugUnit.label));
                        });
                    });
                },
                open: function () {
                    jq(this).removeClass("ui-corner-all").addClass("ui-corner-top");
                },
                close: function () {
                    jq(this).removeClass("ui-corner-top").addClass("ui-corner-all");
                }
            });
        });

        //examinations autocomplete functionality
        jq("#searchExaminations").autocomplete({
            minLength: 0,
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("mchapp", "examinationFilter", "searchFor") }', {
                    findingQuery: request.term
                }).success(function (data) {
                    examinations = data;
                    response(data);
                });
            },
            select: function (event, ui) {
                var examination = _.find(examinations, function (exam) {
                    return exam.value === ui.item.value;
                });

                if (!examinationArray.find(function (exam) {
                            return exam.value == examination.value;
                        })) {    var provisionalDiagnosisQuestionUuid = "b8bc4c9f-7ccb-4435-bc4e-646d4cf83f0a";

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

        jq("#exams-holder").on("click", "#selectedExamination", function () {
            var uid = jq(this).data('uid');
            examinationArray = examinationArray.filter(function (examination) {
                return examination.value != uid;
            });

            examinationSummary();
            jq(this).parent("div").remove();

            if (jq("#examination-detail-div").length == 0) {
                jq('#exams-set').val('');
                jq('#task-exams').hide();
            }
        });

        jq("#7cdc2d69-31b9-4592-9a3f-4bc167d5780b").on('change', function () {
            if (jq("#7cdc2d69-31b9-4592-9a3f-4bc167d5780b").is(':checked')) {
                jq('#specifyOther').show();
            } else {
                jq('#specifyOther').hide();
            }
        });

        function examinationSummary() {
            if (examinationArray.length == 0) {
                jq('#summaryTable tr:eq(1) td:eq(1)').text('N/A');
            }
            else {
                var exams = '';
                examinationArray.forEach(function (examination) {
                    exams += examination.label + '<br/>'
                });
                jq('#summaryTable tr:eq(1) td:eq(1)').html(exams);
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
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getInvestigations") }',
                        {
                            q: request.term
                        }
                ).success(function (data) {
                            var results = [];
                            for (var i in data) {
                                var result = {label: data[i].name, value: data[i].uuid};
                                results.push(result);
                            }
                            response(results);
                        });
            },
            minLength: 3,
            select: function (event, ui) {
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
            open: function () {
                jq(this).removeClass("ui-corner-all").addClass("ui-corner-top");
            },
            close: function () {
                jq(this).removeClass("ui-corner-top").addClass("ui-corner-all");
            }
        });

        jq("#investigations-holder").on("click", ".icon-remove", function () {
            var investigationId = parseInt(jq(this).parents('div.investigation').find('input[type="hidden"]').attr("value"));
            selectedInvestigationIds.splice(selectedInvestigationIds.indexOf(investigationId));

            investigationArray = investigationArray.filter(function (investigation) {
                return investigation.value != investigationId;
            });

            investigationSummary();

            jq(this).parents('div.investigation').remove();
            if (jq(".investigation").length == 0) {
                jq('#investigations-set').val('');
                jq('#task-investigations').hide();
            }
        });

        function investigationSummary() {
            if (investigationArray.length == 0) {
                jq('#summaryTable tr:eq(4) td:eq(1)').text('N/A');
            }
            else {
                var exams = '';
                investigationArray.forEach(function (investigation) {
                    exams += investigation.label + '<br/>'
                });
                jq('#summaryTable tr:eq(4) td:eq(1)').html(exams);
            }
        }

        jq('#specific-disability, .feeding-info input').change(function(){
            jq('#feeding-info-set').val('SET');

            var output = '';

            if (jq("input[name='concept.a082375c-bfe4-4395-9ed5-d58e9ab0edd3']:checked").val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
                output += '&#9745; Exclusive Breastfeeding (0-6 months)<br/>';
            }

            if (jq("input[name='concept.42197783-8b24-49b0-b290-cbb368fa0113']:checked").val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
                output += '&#9745; Counselled on Nutrition?<br/>';
            }

            if (jq("input[name='concept.8a3c420e-b4ff-4710-81fd-90c7bfa6de72']:checked").val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
                output += '&#9745; Counselled on HIV<br/>';
            }

            if (jq("input[name='concept.d311a2d5-8af3-4161-9df4-35f26b04dded']:checked").val() == '4536f271-5430-4345-b5f7-37ca4cfe1553'){
                output += '&#9745; Disability ' + jq('#specific-disability').val();
                jq('#specific-disability').show();
            }
            else{
                jq('#specific-disability').hide();
                jq('#specific-disability').val('');
            }

            if (output == ''){
                output = 'N/A';
            }

            jq('#summaryTable tr:eq(5) td:eq(1)').html(output);
        });

        jq('.treatment-info input').change(function(){
            jq('#treatment-info-set').val('SET');
            var output = '';

            if (!jq("input[name='concept.160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").val()) {
                output += 'RECEIVED LLITN: results not provided' +  '<br/>';
            }
            else {
                output += 'RECEIVED LLITN: ' + jq("input[name='concept.160428AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").data('value') + '<br/>';
            }

            if (!jq("input[name='concept.159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").val()) {
                output += 'Dewormed: results not provided' +  '<br/>';
            }
            else {
                output += 'Dewormed: ' + jq("input[name='concept.159922AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA']:checked").data('value') + '<br/>';
            }
            if (!jq("input[name='concept.c1346a48-9777-428f-a908-e8bff24e4e37']:checked").val()) {
                output += 'Vitamin A Supplementation (6-59 months): results not provided' +  '<br/>';
            }
            else {
                output += 'Vitamin A Supplementation (6-59 months): ' + jq("input[name='concept.c1346a48-9777-428f-a908-e8bff24e4e37']:checked").data('value') + '<br/>';
            }

            if (!jq("input[name='concept.534705aa-8857-4e70-9b08-b363fb3ce677']:checked").val()) {
                output += 'Supplemented with MNP (6-23 months): results not provided' +  '<br/>';
            }
            else {
                output += 'Supplemented with MNP (6-23 months): ' + jq("input[name='concept.534705aa-8857-4e70-9b08-b363fb3ce677']:checked").data('value') + '<br/>';
            }
            jq('#summaryTable tr:eq(6) td:eq(1)').html(output);
        });

        jq('#cwcFollowUp input').change(function(){
            jq('#referral-set').val('SET');
            var output = '';

            if (jq('input[value="d87a8764-8e2d-4297-b49a-acbc1210109e"]:checked').length > 0) {
                output += '&#9745; NUTRITIONAL MARASMUS<br/>';
            }

            if (jq('input[value="6eac3451-66b6-4057-b765-1b47e6ecff6b"]:checked').length > 0) {
                output += '&#9745; 	KWASHIORKOR<br/>';
            }

            if (jq('input[value="cdc6042c-7237-4150-87c4-12152c7e2542"]:checked').length > 0) {
                output += '&#9745; 	MALNUTRITION<br/>';
            }

            if (jq('input[value="7cdc2d69-31b9-4592-9a3f-4bc167d5780b"]:checked').length > 0) {
                output += '&#9745; 	OTHER ' + jq('#specifyOther').val();
            }

            if (output == ''){
                output = 'N/A';
            }

            jq('#summaryTable tr:eq(7) td:eq(1)').html(output);
        });

        jq('#availableReferral, #next-visit-date-display').change(function(){
            var output = '';

            if (jq('#availableReferral').val() == "1"){
                output += 'Internal Referral<br/>';
                jq('#referral-set').val('SET');
            }
            else if (jq('#availableReferral').val() == "2"){
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

        jq('#referralReason').change(function () {
            if (jq(this).val() == "8") {
                jq('#externalRefferalSpc').show();
            }
            else {
                jq('#externalRefferalSpc').hide();
            }
        }).change();

    });//End of Document Ready

    function refreshPage() {
        window.location.reload();
    }

    function isEmpty(o) {
        return o == null || o == '';
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
                        tbody.append('<tr align="center"><td colspan="6">No Previous Vaccinations found for ' + wfName + '</td></tr>');
                    } else {
                        for (index in data) {
                            var item = data[index];
                            console.log(item);
                            var row = '<tr>';
                            row += '<td>' + (parseInt(index) + 1) + '</td>';
                            row += '<td>' + item.stateName + '</td>';
                            row += '<td>' + moment(item.startDate, 'DD.MMM.YYYY').format('DD/MM/YYYY') + '</td>';
                            row += '<td>' + getReadableAge('${patient.birthdate}',  moment(item.startDate, 'DD.MMM.YYYY').format('DD/MM/YYYY')) + '</td>';
                            row += '<td>' + moment(item.dateCreated, 'DD.MMM.YYYY').format('DD/MM/YYYY') + '</td>';
                            row += '<td>' + item.creator + '</td>';
                            row += '</tr>';
                            tbody.append(row);
                        }

                    }

                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });

        jq("#currentStateVaccine_" + programWorkflowId).show();
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
        jq("#currentStateVaccine_" + divId).hide();
        jq("#currentStateDetails_" + divId).show();
        refreshPage();
    }

    function selectReferrals(selectedReferral) {
        if (selectedReferral == 1) {
            jq("#internalRefferalDiv").show();
            jq("#externalRefferalDiv").hide();
            jq("#externalRefferalFac").hide();
            jq("#externalRefferalRsn").hide();
            jq("#externalRefferalSpc").hide();
            jq("#externalRefferalCom").hide();
        } else if (selectedReferral == 2) {
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").show();
            jq("#externalRefferalFac").show();
            jq("#externalRefferalRsn").show();
            jq("#externalRefferalCom").show();

            jq('#referralReason').change();
        }
        else {
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").hide();
            jq("#externalRefferalFac").hide();
            jq("#externalRefferalRsn").hide();
            jq("#externalRefferalSpc").hide();
            jq("#externalRefferalCom").hide();
        }
    }

    function addDrug() {
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
.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
    color: #555;
    text-align: left;
}
#exams-holder input[type="radio"] {
    float: none;
}
.investigation .selecticon,
#examination-detail-div .selecticon {
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
.investigation {
    border-top: 1px dotted #ccc;
    margin: 0 0 5px;
}
.investigation:first-child {
    border-top: 1px none #ccc;
    margin: 5px 0 5px;
}
#examination-detail-div {
    border-top: 1px dotted #ccc;
    margin: 0 0 10px;
}
#examination-detail-div:first-child {
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
.simple-form-ui section fieldset select:focus, .simple-form-ui section fieldset input:focus, .simple-form-ui section #confirmationQuestion select:focus, .simple-form-ui section #confirmationQuestion input:focus, .simple-form-ui #confirmation fieldset select:focus, .simple-form-ui #confirmation fieldset input:focus, .simple-form-ui #confirmation #confirmationQuestion select:focus, .simple-form-ui #confirmation #confirmationQuestion input:focus, .simple-form-ui form section fieldset select:focus, .simple-form-ui form section fieldset input:focus, .simple-form-ui form section #confirmationQuestion select:focus, .simple-form-ui form section #confirmationQuestion input:focus, .simple-form-ui form #confirmation fieldset select:focus, .simple-form-ui form #confirmation fieldset input:focus, .simple-form-ui form #confirmation #confirmationQuestion select:focus, .simple-form-ui form #confirmation #confirmationQuestion input:focus {
    outline: 1px none #f00
}
.patient-profile {
    border: 1px solid #eee;
    margin: 5px 0;
    padding: 7px 12px;
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
    float: 			left;
    font-size: 		85% !important;
    min-width: 		80px;
    margin-right: 	4px;
}
.thirty-three-perc span{
    color: #555;
    float: left;
    font-size: 90%;
}
table[id*='workflowTable_'] th:first-child {
    width: 5px;
}
table[id*='workflowTable_'] th:nth-child(3),
table[id*='workflowTable_'] th:nth-child(4) {
    width: 80px;
}
.update-vaccine {
    float: right;
}
.update-vaccine a {
    cursor: pointer;
}
.update-vaccine a:hover {
    text-decoration: none;
}
.simple-form-ui section, .simple-form-ui #confirmation, .simple-form-ui form section, .simple-form-ui form #confirmation {
    background: #fff none repeat scroll 0 0;
}
.chevron {
    color: #4a80ff !important;
    cursor: pointer;
    font-size: 100% !important;
    margin: 5px;
    text-decoration: none;
}
#next-visit-date-wrapper{
    padding-left: 10px;
}
#next-visit-date label{
    display: none;
}
#next-visit-date input{
    width: 95%!important;
}
</style>

<div style="padding: 0 4px">
    <field>
        <input type="hidden" id="immunizations-set" class=""/>
        <span id="immunizations-lbl" class="field-error" style="display: none"></span>
    </field>

    <div style="min-width: 78%" class="col16 dashboard">
        <% patientProgram.program.workflows.each { workflow -> %>
        <% def stateId; def stateStart; def stateName; %>
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
                <a><i class="icon-chevron-right small right chevron"
                      data-idnt="${workflow.programWorkflowId}" data-name="${workflow.concept.name}"
                      data-prog="${patientProgram.patientProgramId}"></i></a>
            </div>

            <div class="info-body">
                <div id="currentStateVaccine_${workflow.programWorkflowId}" style="display: none;">
                    <table id="workflowTable_${workflow.programWorkflowId}">
                        <thead>
                        <tr>
                        <thead>
                        <th>#</th>
                        <th>VACCINE</th>
                        <th>GIVEN ON</th>
                        <th>AT AGE</th>
                        <th>RECORDED</th>
                        <th>PROVIDER</th>
                        </thead>
                    </tr>
                    </thead>

                        <tbody>

                        </tbody>
                    </table>

                    <div class="update-vaccine">
                        <a data-idnt="${workflow.programWorkflowId}" data-name="${workflow.concept.name}"
                           data-prog="${patientProgram.patientProgramId}">
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
                            Date: <span id="state_date_${workflow.programWorkflowId}">${
                                ui.formatDatePretty(stateStart)}</span> )
                        </small>
                    </div>
                    <% } else { %>
                    <div id="no-show-${workflow.programWorkflowId}"
                         style="margin-left: 20px; color: rgb(153, 153, 153);">
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
        <% } %>

    </div>
</div>