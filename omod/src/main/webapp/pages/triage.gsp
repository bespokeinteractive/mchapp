<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Mother Child Health"])
    ui.includeJavascript("billingui", "moment.js")
%>
<script type="text/javascript">
function isValidDate(str) {
    var d = moment(str,'D/M/YYYY');
    var dt = moment(str, 'DD MMMM YYYY');
    if(d == null || !d.isValid() || !dt.isValid()) return false;

   return str.indexOf(d.format('D/M/YYYY')) >= 0 
        || str.indexOf(d.format('DD/MM/YYYY')) >= 0
        || str.indexOf(d.format('D/M/YY')) >= 0 
        || str.indexOf(d.format('DD/MM/YY')) >= 0
        || str.indexOf(dt.format('D MMM YYYY')) >= 0
        || str.indexOf(dt.format('DD MMMM YYYY')) >= 0
        || str.indexOf(dt.format('D MMM YY')) >= 0
        || str.indexOf(dt.format('DD MMMM YY')) >= 0;
}
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
	.print-only{
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
	#date-enrolled label{
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
</style>



<div class="clear"></div>
<div>
	<div class="example">
		<ul id="breadcrumbs">
			<li>
				<a href="${ui.pageLink('referenceapplication','home')}">
				<i class="icon-home small"></i></a>
			</li>

			<li>
				<i class="icon-chevron-right link"></i>
				<a href="${ui.pageLink('mchapp','triage')}">Mother Child Health</a>
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
			<span id="othname">${patient.givenName} ${patient.middleName?patient.middleName:''} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em></span>

			<span class="gender-age">
				<span>
					${gender}
				</span>
				<span id="agename">${patient.age} years (${ui.formatDatePretty(patient.birthdate)}) </span>

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

<% if (enrolledInAnc){ %>
	${ui.includeFragment("mchapp","antenatalTriage", [patientId: patientId])}
<% } else if (enrolledInPnc) { %>
	${ui.includeFragment("mchapp","postnatalTriage", [patientId: patientId])}
<% } else if (enrolledInCwc) { %>
	${ui.includeFragment("mchapp","cwcTriage")}
<% } else { %>
	${ui.includeFragment("mchapp","programSelection")}
<% } %>