<% def returnUrl = ui.pageLink("mchapp", "triage") %>
<script>
	jq(function(){
		jq("#triage-left-menu").on("click", ".triage-summary", function(){
			jq("#triage-detail").html('<i class=\"icon-spinner icon-spin icon-2x pull-left\"></i> <span style="float: left; margin-top: 12px;">Loading...</span>');	
			
			var triageSummary = jq(this);
			jq(".triage-summary").removeClass("selected");
			jq(triageSummary).addClass("selected");
			
			jq.getJSON('${ ui.actionLink("mchapp", "triageSummary" ,"getTriageSummaryDetails") }',
				{ 'encounterId' : jq(triageSummary).find(".encounter-id").val() }
			).success(function (data) {
				var triageDetailTemplate =  _.template(jq("#triage-detail-template").html());
				jq("#triage-detail").html(triageDetailTemplate(data.notes));
				
				jq("#opdRecordsPrintButton").show(100);
			}).error(function(data){
				console.info("Error");
			});
		});

		jq("#triage-left-menu").on("click", ".edit-link",function(e){
			e.preventDefault();
			var encounterId = jq(this).parents(".triage-summary").find(".encounter-id").val()
			window.location.href ="${ui.pageLink("mchapp", "triage", [patientId: patientId, queueId: queueId,isEdit:true])}encounterId=" + encounterId;
		});
		

		var triageSummaries = jq(".triage-summary");
		
		if (triageSummaries.length > 0) {
			triageSummaries[0].click();
			jq('#cs').show();
		}else{
			jq('#cs').hide();
		}
		
	
	});
</script>
<style>
	#triage-left-menu {
		border-top: medium none #fff;
		border-right: 	medium none #fff;
	}
	#triage-left-menu li:nth-child(1) { 
		border-top: 	1px solid #ccc;
	}
	#triage-left-menu li:last-child { 
		border-bottom:	1px solid #ccc;
		border-right:	1px solid #ccc;
	}
	.triage-summary{
		
	}
	#triage-person-detail {
		display: none;
	}
	.dashboard .info-body label {
		display: inline-block;
		font-size: 90%;
		font-weight: bold;
		margin-bottom: 5px;
		width: 190px;
	}
	.triage-info-history label{
		float: left;
	}
	.triage-info-history span{
		float: 	left;
		display: inline-block;
	}
	.status.active {
		margin-right: 10px;
		margin-top: 7px;
	}
</style>
<div class="onerow">
	<div id="triage-left-menu" style="padding-top: 15px;" class="col15 clear">
		<ul id="triage-left-menu" class="left-menu">
		<% triageSummaries.eachWithIndex { triagesummary, index -> %>
				<li class="menu-item triage-summary" visitid="54" style="border-right:1px solid #ccc; margin-right: 15px; width: 168px; height: 18px;">
				<input type="hidden" class="encounter-id" value="${triagesummary.encounterId}" >
				<span class="menu-date">
					<i class="icon-time"></i>
					<span id="vistdate">
						${ui.formatDatetimePretty(triagesummary.visitDate)}
					</span>
				</span>
				<span class="menu-title">
				<% if (index == 0) { %>
					<i class="icon-edit" style="float: left; margin-top: 1px; margin-right: 3px; color: rgb(0, 127, 255); font-weight: bold;"></i>
					<a style="float: left;" class="edit-link"[encounterId: encounterId]>Edit Triage Details</a>
				<% } else {%>
					<i class="icon-stethoscope"></i>
					${triagesummary.outcome?triagesummary.outcome:'Reviewed'}
				<%}%>
			</span>
			<span class="arrow-border"></span>
			<span class="arrow"></span>
		</li>
				<%}%>
				<li style="height: 30px; margin-right: 15px; width: 168px;" class="menu-item">
			</li>
		</ul>
	</div>
	<div class="col16 dashboard triageSummaryPrintDiv" style="min-width: 78%">
		<div id="printTriageSection">
			<div id="triage-person-detail">
				<h3>PATIENT TRIAGE SUMMARY INFORMATION</h3>
				
				<label>
					<span class='status active'></span>
					Identifier:
				</label>
				<span>${patient.getPatientIdentifier()}</span>
				<br/>
				
				<label>
					<span class='status active'></span>
					Full Names:
				</label>
				<span>${patient.givenName} ${patient.familyName} ${patient.middleName?patient.middleName:''}</span>
				<br/>
				
				<label>
					<span class='status active'></span>
					Age:
				</label>
				<span>${patient.age} (${ui.formatDatePretty(patient.birthdate)})</span>
				<br/>
				
				<label>
					<span class='status active'></span>
					Gender:
				</label>
				<span>${gender}</span>
				<br/>
			</div>
			<div class="info-section" id="triage-detail">
				
			</div>
			
		</div>
		
		<button id="triageSummaryPrintButton" class="task" style="float: right; margin: 10px;">
			<i class="icon-print small"></i>
			Print
		</button>
	</div>

<script id="triage-detail-template" type="text/template">
	<div class="col16 dashboard">
	<div class="info-section" id="triage-detail">
	<div class="info-header">
		<i class="icon-user-md"></i>
		<h3>TRIAGE SUMMARY INFORMATION</h3>
	</div>
		<div class="info-body">
			<% if(enrolledInAnc){%>
			 <label><span class="status active"></span>Weight:</label>
             <span>{{-weight}}</span>
             <br>
             
            <label><span class="status active"></span>Systolic:</label>
			<span>{{-systolic}}</span>
			<br>

			<label><span class="status active"></span>Daistolic:</label>
			<span>{{-daistolic}}</span>
			<br>
			
			<label><span class="status active"></span>Height:</label>
			<span>{{-height}}</span>
			<br>
			<%}
			else if (enrolledInPnc) { %>
			
			<label><span class="status active"></span>Temperature:</label>
			<span>{{-temperature}}</span>
			<br>
			
			<label><span class="status active"></span>Pulse Rate:</label>
			<span>{{-pulseRate}}</span>
			<br>

			<label><span class="status active"></span>Systolic:</label>
			<span>{{-systolic}}</span>
			<br>

		   <label><span class="status active"></span>Daistolic:</label>
		   <span>{{-daistolic}}</span>
		   <br>
			
			<%} else {%>
			
			<label><span class="status active"></span>Weight:</label>
			<span>{{-weight}}</span>
			<br>
			
			<label><span class="status active"></span>Height:</label>
			<span>{{-height}}</span>
			<br>
			
			<label><span class="status active"></span>Weight Category:</label>
			<span>{{-weightcategory}}</span>
			<br>
			
			<label><span class="status active"></span>Growth Status:</label>
			<span>{{-growthStatus}}</span>
			<br>
			
			<label><span class="status active"></span>M.U.A.C:</label>
			<span>{{-muac}}</span>
			<br>
			
			<%} %>
			</div>



</script>
</div>
</div>
</div>



<div class="clear"></div>
<div class="clear"></div>
