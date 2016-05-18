<script>
    jq(function() {
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
                console.log(examination);
                var examTemplate = _.template(jq("#examination-detail-template").html());
                jq("fieldset").append(examTemplate(examination));
                jq("#searchExaminations").val("fdsf");
            }
        });
        var adddrugdialog = emr.setupConfirmationDialog({
            selector: '#prescription-dialog',
            actions: {
                confirm: function() {
                    adddrugdialog.close();
                },
                cancel: function() {
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
                            jq('#drugUnitsSelect').append(jq('<option>').text(drugUnit.name).attr('value', drugUnit.id));
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
</script>

<div>
    <label>Breast Exam:</label><br>
    <input type="text" id="searchExaminations" name="" value="">
</div>

<script id="examination-detail-template" type="text/template">
<div>
    <label>{{-label}}</label>
    {{ _.each(answers, function(answer, index) { }}
    <input type="radio" name="concept.{{=value}}" value="{{=answer.uuid}}">{{=answer.display}}
{{ }); }}
</div>
</script>

<div>
    <fieldset>
        <legend>Examinations</legend>

    </fieldset>
</div>

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
        <th></th>
    </tr>
    </thead>
    <tbody ></tbody>
</table>

<div style="margin-top:5px">
    <input class="button confirm" type="button" id="addDrugsButton" name="" value="Add">
</div>
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
                <input type="text"  style="width: 60px!important;">
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
                <input type="text">
            </li>
            <li>
                <label>Comment</label>
                <textarea></textarea>
            </li>
        </ul>

        <label class="button confirm right">Confirm</label>
        <label class="button cancel">Cancel</label>
    </div>
</div>