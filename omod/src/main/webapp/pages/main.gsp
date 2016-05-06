<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Module"])
    ui.includeJavascript("billingui", "moment.js")
%>

<head>
    <script>
        jq(function () {
            jq("#tabs").tabs();
        });
    </script>
</head>

<div id="tabs" style="margin-top: 40px!important;">
    <ul>
        <li><a href="#tabs-1">ANC TRIAGE</a></li>
        <li><a href="#tabs-2">CWC TRIAGE</a></li>
        <li><a href="#tabs-3">PNC TRIAGE</a></li>

    </ul>

    <div id="tabs-1" >
        ${ui.includeFragment("mchapp","antenatalTriage")}
    </div>

    <div id="tabs-2">
         ${ui.includeFragment("mchapp","cwcTriage")}
    </div>

    <div id="tabs-3">
        ${ui.includeFragment("mchapp","postnatalTriage")}
    </div>
</div>
