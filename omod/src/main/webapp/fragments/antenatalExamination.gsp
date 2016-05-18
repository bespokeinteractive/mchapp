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

        jq("#availableReferral").on("change", function (){
            selectReferrals(jq( "#availableReferral" ).val());
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