<script>
    jq(function(){
        var patientProfile = JSON.parse('${patientProfile.toJSON()}');
        var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
        jq(".patient-profile").append(patientProfileTemplate(patientProfile));

        var examinations = [{
            "value": "48AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
            "label": "Pregnancy, miscarriage",
            "answers": [
                {
                    "uuid": "1066AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                    "display": "No"
                },
                {
                    "uuid": "1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                    "display": "Sí"
                },
                {
                    "uuid": "1067AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                    "display": "Desconocido"
                }
            ]
        },
            {
                "value": "155AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                "label": "Epilepsy",
                "answers": [
                    {
                        "uuid": "1065AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "display": "Sí"
                    },
                    {
                        "uuid": "1066AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "display": "No"
                    },
                    {
                        "uuid": "1067AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",
                        "display": "Desconocido"
                    }
                ]
            }
        ];

        jq("#searchExaminations").autocomplete({
            minLength:0,
            source:examinations,
            select:function(event, ui){
                var examination = _.find(examinations,function(exam){return exam.value === ui.item.value;});
                var examTemplate = _.template(jq("#examination-detail-template").html());
                jq("fieldset").append(examTemplate(examination));
                jq("#searchExaminations").val("");
                return false;
            }
        });
        jq("#availableReferral").on("change", function (){
            selectReferrals(jq( "#availableReferral" ).val());
        });

        var adddrugdialog = emr.setupConfirmationDialog({
            selector: '#prescription-dialog',
            actions: {
                confirm: function() {
                    addDrug();
                    adddrugdialog.close();
                },
                cancel: function() {
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
                            jq('#formulationsSelect').append(jq('<option>').text(formulation.name).attr('value', formulation.id));
                        });
                    });

                    jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getFrequencies") }').success(function(data) {
                        var frequencies = jq.map(data, function (frequency) {
                            jq('#frequencysSelect').append(jq('<option>').text(frequency.name).attr('value', frequency.id));
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

        jq("fieldset").on("click", "#selectedExamination",function(){
            console.log(jq(this).parent("div"));
            jq(this).parent("div").remove();
        });

    });

    function selectReferrals(selectedReferral){
        //1 = internal referral
        //2 = external referral
        if(selectedReferral == 1){
            jq("#externalRefferalDiv").hide();
            jq("#internalRefferalDiv").show();
        }else if(selectedReferral == 2){
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").show();
        }
        else{
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").hide();
        }
    }
    function addDrug(){
        var addDrugsTableBody = jq("#addDrugsTable tbody");
        var drugName = jq("#drugName").val();
        var drugDosage = jq("#drugDosage").val();
        var drugUnitsSelect = jq("#drugUnitsSelect option:selected").text();
        var formulationsSelect = jq("#formulationsSelect option:selected").text();
        var frequencysSelect = jq("#frequencysSelect option:selected").text();
        var numberOfDays = jq("#numberOfDays").val();
        var comment = jq("#comment").val();

        addDrugsTableBody.append("<tr><td>"+  drugName + "</td><td>"+  drugDosage + " " + drugUnitsSelect + "</td><td>" +formulationsSelect + "</td><td>"
                + frequencysSelect + "</td><td>" + numberOfDays + "</td><td>" + comment +"</td></tr>");
    }
</script>

<script id="patient-profile-template" type="text/template">
    {{ _.each(profileDetails, function(profileDetail) { }}
        <p>{{=profileDetail.name}}: {{=profileDetail.value}}</p>
    {{ }); }}
</script>

<div>
    <label>Exam:</label><br>
    <input type="text" id="searchExaminations" name="" value="">
</div>

<script id="examination-detail-template" type="text/template">
    <div>
        <label>{{-label}}</label>
        {{ _.each(answers, function(answer, index) { }}
            <input type="radio" name="concept.{{=value}}" value="{{=answer.uuid}}">{{=answer.display}}
        {{ }); }}
        <p id="selectedExamination" class="icon-remove selecticon"></p>
    </div>
</script>

<div>
    <fieldset>
        <legend>Examinations</legend>

    </fieldset>
</div>
<br>

<h2> Prescribe Drugs</h2>

<table id="addDrugsTable">
    <thead>
    <tr>
        <th>Drug Name</th>
        <th>Dosage</th>
        <th>Formulation</th>
        <th>Frequency</th>
        <th>Days</th>
        <th>Comments</th>
    </tr>
    </thead>
    <tbody ></tbody>
</table>

<div style="margin-top:5px">
    <input class="button confirm" type="button" id="addDrugsButton" name="" value="Add">
</div>

<br>

<div>
    <h2> Patient Referral</h2>
    <select id="availableReferral" name="availableReferral">
        <option value="0">Select Option</option>
        <option value="1">Internal Referral</option>
        <option value="2">External Referral</option>
    </select>
</div>
<div id="internalRefferalDiv" style="display: none">
    <h2> Internal Referral</h2>
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
    <h2> External Referral</h2>
    <select id="externalRefferal" name="">
        <option value="0">Select Option</option>
        <% if (externalReferrals != null || externalReferrals != "") { %>
            <% externalReferrals.each { externalReferral -> %>
                <option ${externalReferral.id} >${externalReferral.label}</option>
            <% } %>
        <% } %>
    </select>

    <h2>Facility</h2>
    <input type="text" id="referralFacility" name="">

    <h2>Referral Reason</h2>
    <select id="referralReason" name="">
        <option value="0">Select Option</option>
        <% if (referralReasons != null || referralReasons != "") { %>
            <% referralReasons.each { referralReason -> %>
                <option ${referralReason.id} >${referralReason.label}</option>
            <% } %>
        <% } %>
    </select>

    <h2>Comment</h2>
    <textarea></textarea>
</div>


<div id="prescription-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Prescription</h3>
    </div>

    <div class="dialog-content">
        <ul>
            <li>
                <label>Drug</label>
                <input class="drug-name" id="drugName" type="text">
            </li>
            <li>
                <label>Dosage</label>
                <input type="text" id="drugDosage"  style="width: 60px!important;">
                <select id="drugUnitsSelect">
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

        <label class="button confirm right">Confirm</label>
        <label class="button cancel">Cancel</label>
    </div>
</div>

