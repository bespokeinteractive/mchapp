<script>
    var drugOrders = [];
    
    jq(function() {

        var patientProfile = JSON.parse('${patientProfile}');
        if (patientProfile.details.length > 0) {
            var patientProfileTemplate = _.template(jq("#patient-profile-template").html());
            jq(".patient-profile").append(patientProfileTemplate(patientProfile));
        }

        var examinations = [];

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
                console.log(examinations);
                var examination = _.find(examinations,function(exam){return exam.value === ui.item.value;});
                var examTemplate = _.template(jq("#examination-detail-template").html());
                jq("fieldset").append(examTemplate(examination));
                jq(this).val('');
                return false;
            }
        });
        var adddrugdialog = emr.setupConfirmationDialog({
            selector: '#prescription-dialog',
            actions: {
                confirm: function() {
                    addDrug();
                    jq("#drugForm")[0].reset();
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
                    jq(selectedInput).attr("identifier", ui.item.value);
                },
                change: function (event, ui) {
                    event.preventDefault();
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
                        var result = { label: data[i].name, value: data[i].id};
                        results.push(result);
                    }
                    response(results);
                });
            },
            minLength: 3,
            select: function( event, ui ) {
                var selectedInvestigation = document.createElement('option');
                selectedInvestigation.value = ui.item.value;
                selectedInvestigation.text = ui.item.label;
                selectedInvestigation.id = ui.item.value;
                var selectedInvestigationList = document.getElementById("selectedInvestigationList");
                //adds the selected procedures to the div
                var selectedInvestigationP = document.createElement("P");
                selectedInvestigationP.className = "selectp";
                var selectedInvestigationT = document.createTextNode(ui.item.label);
                selectedInvestigationP.id = ui.item.value;
                selectedInvestigationP.appendChild(selectedInvestigationT);
                var btnselectedRemoveIcon = document.createElement("p");
                btnselectedRemoveIcon.className = "icon-remove selecticon";
                btnselectedRemoveIcon.id = "investigationRemoveIcon";
                selectedInvestigationP.appendChild(btnselectedRemoveIcon);
                var selectedInvestigationDiv = document.getElementById("selected-investigations");
                //check if the item already exist before appending
                var exists = false;
                for (var i = 0; i < selectedInvestigationList.length; i++) {
                    if(selectedInvestigationList.options[i].value==ui.item.value)
                    {
                        exists = true;
                        jq().toastmessage('showErrorToast', 'Already exists');
                    }
                }
                if(exists == false)
                {
                    selectedInvestigationList.appendChild(selectedInvestigation);
                    selectedInvestigationDiv.appendChild(selectedInvestigationP);
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

        jq("#selected-investigations").on("click", "#investigationRemoveIcon",function(){
            var investigationId = jq(this).parent("p").attr("id");
            var investigationP = jq(this).parent("p");
            var divProcedure = investigationP.parent("div");
            var selectInputPosition = divProcedure.siblings("p");
            var selectedProcedure = selectInputPosition.find("select");
            var removeProcedure = selectedProcedure.find("#" + investigationId);
            investigationP.remove();
            removeProcedure.remove();
        });


        jq("fieldset").on("click", "#selectedExamination",function(){
            jq(this).parent("div").remove();
        });
        jq("#addDrugsTable").on("click", "#removeDrug", function(){
            var buttonHolder = jq(this).parent("td");
            buttonHolder.parent("tr").remove();
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
        var drugOrderObject = {};
        var addDrugsTableBody = jq("#addDrugsTable tbody");
        var drugName = jq("#drugName").val();
        var drugDosage = jq("#drugDosage").val();
        var drugUnitsSelect = jq("#drugUnitsSelect option:selected").text();
        var formulationsSelect = jq("#formulationsSelect option:selected").text();
        var frequencysSelect = jq("#frequencysSelect option:selected").text();
        var numberOfDays = jq("#numberOfDays").val();
        var comment = jq("#comment").val();


        var identifier= jq("#drugName").attr("identifier");


        var drugOrder=  {
                    name: drugName,
                    dosage: drugDosage,
                    dosage_unit: jq("#drugUnitsSelect").val(),
                    formulation: jq("#formulationsSelect").val(),
                    frequency: jq("#frequencysSelect").val(),
                    number_of_days: numberOfDays,
                    comment: comment
                     }

        drugOrderObject[identifier] = drugOrder;

        drugOrders.push(drugOrderObject);

        addDrugsTableBody.append("<tr><td>"+  drugName + "</td><td>"+  drugDosage + " " + drugUnitsSelect + "</td><td>" +formulationsSelect + "</td><td>"
                + frequencysSelect + "</td><td>" + numberOfDays + "</td><td>" + comment +"</td><td><p id=\"removeDrug\" class=\"icon-remove selecticon\"></p></td></tr>");
    }
    function myConverterTest() {
        return convert(drugOrders);
    }
</script>


<script id="examination-detail-template" type="text/template">
    <div id="examination-detail-div">
        <label>{{-label}}</label>
        {{ _.each(answers, function(answer, index) { }}
            <input type="radio" name="concept.{{=value}}" value="{{=answer.uuid}}">{{=answer.display}}
        {{ }); }}
        <p id="selectedExamination" class="icon-remove selecticon"></p>
    </div>
</script>

<script id="patient-profile-template" type="text/template">
    {{ _.each(details, function(profileDetail) { }}
        <p>{{=profileDetail.name}}: {{=profileDetail.value}}</p>
    {{ }); }}
</script>

<div class="patient-profile"></div>

<div>
    <label>Examination:</label><br>
    <input type="text" id="searchExaminations" name="" value="">
</div>

<div>
    <fieldset>
        <legend>Examinations</legend>

    </fieldset>
</div>

<div>
    <h2> Investigations </h2>
     <p>
        <input type="text" style="width: 450px" id="investigation" name="investigation" placeholder="Enter Investigations" />
        <select style="display: none" id="selectedInvestigationList"></select>
        <div class="selectdiv"  id="selected-investigations"></div>
    </p>
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
        <form id="drugForm">
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
        </form>
    </div>
</div>