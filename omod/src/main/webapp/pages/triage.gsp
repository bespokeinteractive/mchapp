<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH"])
%>
<div class="clear"></div>
<div id="content">
	<div class="example">
		<ul id="breadcrumbs">
			<li>
				<a href="${ui.pageLink('referenceapplication','home')}">
<i class="icon-home small"></i></a>
			</li>

<li>
	<i class="icon-chevron-right link"></i>
	<a href="${ui.pageLink('mchapp','triage')}">MCH</a>
</li>

<li>
	<i class="icon-chevron-right link"></i>
	CWC Triage
</li>
</ul>
</div>

<div class="patient-header new-patient-header">
	<div class="demographics">
		<h1 class="name">
			<span id="surname">${patient.names.familyName},<em>surname</em></span>
			<span id="othname">${patient.names.givenName} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<em>other names</em></span>

			<span class="gender-age">
				<span>
					<% if (patient.gender == "F") { %>
					Female
					<% } else { %>
					Male
					<% } %>
				</span>
				<span id="agename">${patient.age} years (15.Oct.1996) </span>

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