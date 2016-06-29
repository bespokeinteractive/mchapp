<% if (enrolledInAnc){ %>
	<script id="patient-profile-template" type="text/template">
		<div class="header-template" style="padding-left: 0px; font-size: 141%; font-weight: bold;">
			<i class='icon-quote-left small'></i>
			<span>ANC PROFILE</span><br/>
		</div>
		
		<div id="profile-items">
			<small><i class="icon-calendar small"></i> Enrolled:</small> ${ui.formatDatePretty(enrollmentDate)}	
			{{ _.each(details, function(profileDetail) { }}
				{{if (isValidDate(profileDetail.value)) { }}
					<small><i class="icon-time small"></i> {{=profileDetail.name}}:</small>
				{{ } else { }}
					<small><i class="icon-user small"></i> {{=profileDetail.name}}:</small>
				{{ } }}
				
				
				{{=profileDetail.value}}
			{{ }); }}	
		</div>
		
	</script>
<% } else if (enrolledInPnc) { %>
	<script id="patient-profile-template" type="text/template">
		<div class="header-template" style="padding-left: 0px; font-size: 141%; font-weight: bold;">
			<i class='icon-quote-left small'></i>
			<span>PNC PROFILE</span><br/>	
		</div>
		
		<div id="profile-items">
			<small><i class="icon-calendar small"></i> Enrolled:</small> ${ui.formatDatePretty(enrollmentDate)}	
			{{ _.each(details, function(profileDetail) { }}
				{{if (isValidDate(profileDetail.value)) { }}
					<small><i class="icon-time small"></i> {{=profileDetail.name}}:</small>
				{{ } else { }}
					<small><i class="icon-user small"></i> {{=profileDetail.name}}:</small>
				{{ } }}
				
				
				{{=profileDetail.value}}
			{{ }); }}	
		</div>
		
	</script>
<% } else if (enrolledInCwc) { %>
	<script id="patient-profile-template" type="text/template">
		<div class="header-template" style="padding-left: 0px; font-size: 141%; font-weight: bold;">
			<i class='icon-quote-left small'></i>
			<span>CWC PROFILE</span><br/>	
		</div>
		
		<small><i class="icon-calendar small"></i> Enrolled:</small> ${ui.formatDatePretty(enrollmentDate)}
		{{ _.each(details, function(profileDetail) { }}
		{{if (isValidDate(profileDetail.value)) { }}
		<small><i class="icon-time small"></i> {{=profileDetail.name}}:</small>
		{{ } else { }}
		<small><i class="icon-user small"></i> {{=profileDetail.name}}:</small>
		{{ } }}


		{{=profileDetail.value}}
		{{ }); }}
	</script>
<% } %>

<div class="patient-profile"></div>
