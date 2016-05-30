<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Mother Child Health"])
    ui.includeJavascript("billingui", "moment.js")
    ui.includeJavascript("mchapp", "object-to-query-string.js")
    ui.includeJavascript("mchapp", "drugOrder.js")
    ui.includeCss("registration", "onepcssgrid.css")
%>
<script type="text/javascript">
    var successUrl = "${ui.pageLink('mchapp','main',[patientId: patient, queueId: queueId])}";
    function isValidDate(str) {
        var d = moment(str, 'D/M/YYYY');
        var dt = moment(str, 'D MMMM YY');
        if (d == null || (!d.isValid() && !dt.isValid())) return false;

        var result = str.indexOf(d.format('D/M/YYYY')) >= 0
                || str.indexOf(d.format('DD/MM/YYYY')) >= 0
                || str.indexOf(d.format('D/M/YY')) >= 0
                || str.indexOf(d.format('DD/MM/YY')) >= 0
                || str.indexOf(dt.format('D MMM YYYY')) >= 0
                || str.indexOf(dt.format('DD MMMM YYYY')) >= 0
                || str.indexOf(dt.format('D MMM YY')) >= 0
                || str.indexOf(dt.format('DD MMMM YY')) >= 0;
        return result;
    }
	
	jq(function() {
		var birthdate = moment('${patient.birthdate}').fromNow().toString().replace('ago','') + '(' +moment().format('DD/MM/YYYY')+')';
		jq('#agename').text(birthdate);		
	});
</script>

<style>
	#summaryTable tr:nth-child(2n),
	#summaryTable tr:nth-child(2n+1){
		background: none;
	}
	#summaryTable{
		margin: -5px 0 -6px 0px;
	}
	#summaryTable tr,
	#summaryTable th,
	#summaryTable td {
		border: 		1px none  #eee;
		border-bottom: 	1px solid #eee;
	}
	#summaryTable td:first-child{
		vertical-align: top;
		width: 170px;
	}
	input[type="text"], input[type="password"], select {
		border: 1px solid #aaa !important;
		border-radius: 2px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 38px !important;
		line-height: 18px !important;
		padding: 0 10px !important;
		width: 100% !important;
	}
	.toast-item {
		background-color: #222;
	}
	.name {
		color: #f26522;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}
	.new-patient-header .demographics .gender-age {
		font-size: 14px;
		margin-left: -55px;
		margin-top: 12px;
	}
	.new-patient-header .demographics .gender-age span {
		border-bottom: 1px none #ddd;
	}
	.new-patient-header .identifiers {
		margin-top: 5px;
	}
	.tag {
		padding: 2px 10px;
	}
	.tad {
		background: #666 none repeat scroll 0 0;
		border-radius: 1px;
		color: white;
		display: inline;
		font-size: 0.8em;
		padding: 2px 10px;
	}

	.status-container {
		padding: 5px 10px 5px 5px;
	}
	.catg {
		color: #363463;
		margin: 35px 10px 0 0;
	}
	.print-only {
		display: none;
	}
	.button-group {
		display: inline-block;
		position: relative;
		vertical-align: middle;
	}
	.button-group > .button:first-child:not(:last-child):not(.dropdown-toggle) {
		border-bottom-right-radius: 0;
		border-top-right-radius: 0;
	}
	.button-group > .button:first-child {
		margin-left: 0;
	}

	.button-group > .button:hover, .button-group > .button:focus, .button-group > .button:active, .button-group > .button.active {
		z-index: 2;
	}
	.button-group > .button {
		border-radius: 5px;
		float: left;
		position: relative;
	}
	.button.active, button.active, input.active[type="submit"], input.active[type="button"], input.active[type="submit"], a.button.active {
		background: #d8d8d8 none repeat scroll 0 0;
		border-color: #d0d0d0;
	}
	.button-group > .button:not(:first-child):not(:last-child) {
		border-radius: 0;
	}
	.button-group > .button {
		border-radius: 5px;
		float: left;
		position: relative;
	}
	.button-group > .button:last-child:not(:first-child) {
		border-bottom-left-radius: 0;
		border-top-left-radius: 0;
	}
	.button-group .button + .button, .button-group .button + .button-group, .button-group .button-group + .button, .button-group .button-group + .button-group {
		margin-left: -1px;
	}
	ul.left-menu {
		border-style: solid;
	}
	.col15 {
		display: inline-block;
		float: left;
		max-width: 22%;
		min-width: 22%;
	}
	.col16 {
		display: inline-block;
		float: left;
		width: 730px;
	}
	#date-enrolled label {
		display: none;
	}
	.add-on {
		color: #f26522;
	}
	.append-to-value {
		color: #999;
		float: right;
		left: auto;
		margin-left: -200px;
		margin-top: 13px;
		padding-right: 55px;
		position: relative;
	}
	.menu-title span {
		display: inline-block;
		width: 65px;
	}
	span a:hover {
		text-decoration: none;
	}
	form label,
	.form label {
		display: inline-block;
		padding-left: 10px;
		width: 140px;
	}
	form input,
	form textarea,
	.form input,
	.form textarea {
		display: inline-block;
		min-width: 1%!important;
	}
	form select,
	form ul.select,
	.form select,
	.form ul.select {
		display: inline-block;
		min-width: 3%;
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus {
		outline: 2px none #007fff;
		box-shadow: 0 0 1px 0 #ccc !important;
	}
	form input[type="checkbox"], .form input[type="checkbox"] {
		margin-top: 4px;
		cursor: pointer;
	}
	.dialog-content textarea {
		border: 1px solid #aaa !important;
		margin: 10px;
		width: 90% !important;
	}	
	.onerow {
		clear: both;
		padding: 0 10px;
	}
	.col4 {
		width: 31%;
	}
	.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
		float: left;
		margin: 0 3% 0 0;
	}
	.col1.last, .col2.last, .col3.last, .col4.last, .col5.last, .col6.last, .col7.last, .col8.last, .col9.last, .col10.last, .col11.last, .col12 {
		margin: 0;
	}
	#confirmation .confirm {
		float: right;
	}
</style>


<div class="clear"></div>

<div>
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('patientqueueapp', 'mchClinicQueue')}">Mother Child Health</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                ${title}
            </li>
        </ul>
    </div>
</div>

<div class="patient-header new-patient-header">
    <div class="demographics">
        <h1 class="name">
            <span id="surname">${patient.familyName},<em>surname</em></span>
            <span id="othname">${patient.givenName} ${patient.middleName ? patient.middleName : ''} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em>
            </span>

            <span class="gender-age">
                <span>
                    ${gender}
                </span>
                <span id="agename"></span>

            </span>
        </h1>

        <br/>

        <div class="tad" id="lstdate">Last Visit: ${ui.formatDatePretty(previousVisit)}</div>

        <div class="tad" id="enrollmentDate">Enrollment Date: ${patientProgram?ui.formatDatePretty(patientProgram.dateEnrolled):"--"}</div>

        <div class="tad" id="completionDate">Completion Date:
        <% if (patientProgram && patientProgram.dateCompleted != null) { %>
        ${ui.formatDatePretty(patientProgram.dateCompleted)}
        <% } else { %>
            <em>Still Enrolled</em>
            <% } %>

        </div>

        <div class="tad" id="outcome">Outcome:
        <% if (patientProgram && patientProgram.outcome != null) { %>
        ${patientProgram.outcome.name}
        <% } else { %>
            <em>(none)</em>
            <% } %>
        </div>
    </div>

    <div class="identifiers">
        <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
        <span>${patient.getPatientIdentifier()}</span>
        <br>

        <div class="catg">
            <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${patientCategory}
        </div>
    </div>
</div>

<% if (enrolledInAnc){ %>
	${ui.includeFragment("mchapp","antenatalExamination", [patientId: patient.patientId, queueId: queueId])}
<% } else if (enrolledInPnc) { %>
	${ui.includeFragment("mchapp","postnatalExamination", [patientId: patient.patientId, queueId: queueId])}
<% } else if (enrolledInCwc) { %>
	${ui.includeFragment("mchapp","childWelfareExamination", [patientId: patient.patientId])}
<% } else { %>
	${ui.includeFragment("mchapp","programSelection", [patientId: patient.patientId, queueId: queueId])}
<% } %>