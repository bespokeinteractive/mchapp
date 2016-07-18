<% ui.includeJavascript("billingui", "moment.js") %>

<% if (enrolledInAnc){ %>
	<script id="patient-profile-template" type="text/template">
		<div class="header-template" style="padding-left: 0px; font-size: 141%; font-weight: bold;">
			<i class='icon-quote-left small'></i>
			<span>ANC PROFILE</span><br/>
		</div>
		
		<div id="profile-items">
			<div class="thirty-three-perc">
				<small><i class="icon-calendar small"></i> Enrolled:</small> 
				${ui.formatDatePretty(enrollmentDate)}	
			</div>
			{{ _.each(details, function(profileDetail) { }}
				{{if (isValidDate(profileDetail.value)) { }}
					<small><i class="icon-time small"></i> {{=profileDetail.name}}:</small>
				{{ } else { }}
					<small><i class="icon-user small"></i> {{=profileDetail.name}}:</small>
				{{ } }}
				
				
				{{=profileDetail.value}}
			{{ }); }}
			
			<small><i class="icon-undo small"></i> Maturity:</small> <span class="maturity"></span>
			<div class="clear"></div>
		</div>
		
	</script>
<% } else if (enrolledInPnc) { %>
	<script id="patient-profile-template" type="text/template">
		<div class="header-template" style="padding-left: 0px; font-size: 141%; font-weight: bold;">
			<i class='icon-quote-left small'></i>
			<span>PNC PROFILE</span><br/>
		</div>
		
		<div id="profile-items">
			<div class="thirty-three-perc">
				<small><i class="icon-calendar small"></i> Enrolled:</small>
				<span>
					${ui.formatDatePretty(enrollmentDate)}	
				</span>
			</div>
			
			{{ _.each(details, function(profileDetail) { }}
				<div class="thirty-three-perc">
					{{if (isValidDate(profileDetail.value)) { }}
						<small>
							<i class="icon-time small"></i>
							{{=profileDetail.name}}:
						</small>
						
						<span>
							{{=moment(profileDetail.value,"DD MMMM YYYY").format("DD/YY/YYYY")}}
						</span>
						
					{{ } else { }}
						<small>
							<i class="icon-user small"></i>
							{{=profileDetail.name}}:
						</small>
						
						<span>
							{{=profileDetail.value}}
						</span>
					{{ } }}					
					
				</div>				
			{{ }); }}	
		</div>		
		<div class="clear"></div>
		
	</script>
<% } else if (enrolledInCwc) { %>
	<script id="patient-profile-template" type="text/template">
		<div class="header-template" style="padding-left: 0px; font-size: 141%; font-weight: bold;">
			<i class='icon-quote-left small'></i>
			<span>CWC PROFILE</span><br/>	
		</div>
		
		<div id="profile-items">
			<div class="thirty-three-perc">
				<small><i class="icon-calendar small"></i> Enrolled:</small>
				<span>
					${ui.formatDatePretty(enrollmentDate)}	
				</span>
			</div>
			
			
		</div>		
		<div class="clear"></div>
		
	</script>
<% } %>

<div class="patient-profile"></div>
