<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Mother Child Health"])
    ui.includeJavascript("billingui", "moment.js")
%>
<script type="text/javascript">
    var successUrl = "${ui.pageLink('mchapp','triage',[patientId: patient, queueId: queueId])}";
    function isValidDate(str) {
        var d = moment(str, 'D/M/YYYY');
        var dt = moment(str, 'D MMMM YY');
        var dh = moment(str, 'YYYY-MM-DD');
        if (d == null || (!d.isValid() && !dt.isValid()&& !dh.isValid())) return false;

        var result = str.indexOf(d.format('D/M/YYYY')) >= 0
                || str.indexOf(d.format('DD/MM/YYYY')) >= 0
                || str.indexOf(d.format('D/M/YY')) >= 0
                || str.indexOf(d.format('DD/MM/YY')) >= 0
                || str.indexOf(dt.format('D MMM YYYY')) >= 0
                || str.indexOf(dt.format('DD MMMM YYYY')) >= 0
                || str.indexOf(dt.format('D MMM YY')) >= 0
                || str.indexOf(dt.format('DD MMMM YY')) >= 0
                || str.indexOf(dh.format('YYYY-MM-DD')) >= 0;
        return result;
    }
	
	jq(function() {
		var age;
		var desc;
		
		if (${patient.age} == 0){
			age = Math.floor(moment.duration(moment().diff(moment('${patient.birthdate}'))).asMonths());
			desc = ' months';
			if (age <= 0) {
				age = Math.floor(moment.duration(moment().diff(moment('${patient.birthdate}'))).asWeeks());
				desc = ' weeks';
				
				if (age <= 0) {
					age = Math.floor(moment.duration(moment().diff(moment('${patient.birthdate}'))).asDays());
					desc = ' days';
					
					if (age <= 0) {
						age = Math.floor(moment.duration(moment().diff(moment('${patient.birthdate}'))).asHours());
						desc = ' hours';
					}
				}
			}
			
			age += desc;
		}
		else{
			age = moment('${patient.birthdate}').fromNow().toString().replace('ago','').replace('a year','1 year') + '(' +moment('${patient.birthdate}').format('DD/MM/YYYY')+')';		
		}
		
		jq('#agename').text(age);
	});
</script>

<style>
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
		max-width: 35%;
		min-width: 28%;
	}

	.col16 {
		display: inline-block;
		float: left;
		width: 720px;
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
		padding-right: 35px;
		position: relative;
	}

	.menu-title span {
		display: inline-block;
		width: 80px;
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
		min-width: 74%;
	}

	form select,
	form ul.select,
	.form select,
	.form ul.select {
		display: inline-block;
		min-width: 74%;
	}

	#5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA label,
	#1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA label {
		display: none;
	}

	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus {
		outline: 2px none #007fff;
		box-shadow: 0 0 1px 0 #ccc !important;
	}

	form input[type="checkbox"], .form input[type="checkbox"] {
		margin-top: 4px;
		cursor: pointer;
	}
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4 !important;
	}
	ul.left-menu li {
		width: 250px;
	}
	.dashboard .info-header h3 {
		color: #f26522;
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
                <a href="${ui.pageLink('patientqueueapp', 'mchTriageQueue')}">Mother Child Health</a>
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

        <div id="stacont" class="status-container">
            <span class="status active"></span>
            Visit Status
        </div>

        <div class="tag">Outpatient</div>

        <div class="tad" id="lstdate">Last Visit: ${ui.formatDatePretty(previousVisit)}</div>
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

<% if (enrolledInAnc) { %>
${ui.includeFragment("mchapp", "antenatalTriage", [patientId: patientId, queueId: queueId])}
<% } else if (enrolledInPnc) { %>
${ui.includeFragment("mchapp", "postnatalTriage", [patientId: patientId, queueId: queueId])}
<% } else if (enrolledInCwc) { %>
${ui.includeFragment("mchapp", "cwcTriage", [patientId: patientId])}
<% } else { %>
${ui.includeFragment("mchapp", "programSelection", [patientId: patientId, queueId: queueId])}
<% } %>