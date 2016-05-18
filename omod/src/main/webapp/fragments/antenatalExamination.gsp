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
    });
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