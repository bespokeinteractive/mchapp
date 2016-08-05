<script>
	jq(function(){
		jq("#ul-left-menu").on("click", ".visit-summary", function(){
			jq("#visit-detail").html('<i class=\"icon-spinner icon-spin icon-2x pull-left\"></i> <span style="float: left; margin-top: 12px;">Loading...</span>');	
			jq("#drugs-detail").html("");
			jq("#opdRecordsPrintButton").hide();
			
			var visitSummary = jq(this);
			jq(".visit-summary").removeClass("selected");
			jq(visitSummary).addClass("selected");
			
			jq.getJSON('${ ui.actionLink("mchapp", "visitSummary" ,"getVisitSummaryDetails") }',
				{ 'encounterId' : jq(visitSummary).find(".encounter-id").val() }
			).success(function (data) {
				var visitDetailTemplate =  _.template(jq("#visit-detail-template").html());
				jq("#visit-detail").html(visitDetailTemplate(data.notes));

				if (data.drugs.length > 0) {
					var drugsTemplate =  _.template(jq("#drugs-template").html());
					jq("#drugs-detail").html(drugsTemplate(data));
				}
				else {
					var drugsTemplate =  _.template(jq("#empty-template").html());
					jq("#drugs-detail").html(drugsTemplate(data));
				}
				
				jq("#opdRecordsPrintButton").show(100);
			})
		});
		
		jq('#opdRecordsPrintButton').click(function(){
			jq("#printSection").print({
				globalStyles: 	false,
				mediaPrint: 	false,
				stylesheet: 	'${ui.resourceLink("mchapp", "styles/printout.css")}',
				iframe: 		false,
				width: 			600,
				height:			700
			});			
		});

		var visitSummaries = jq(".visit-summary");
		
		if (visitSummaries.length > 0) {
			visitSummaries[0].click();
			jq('#cs').show();
		}else{
			jq('#cs').hide();
		}
		
		/*jq('#ul-left-menu').slimScroll({
			allowPageScroll: false,
			height		   : '426px',
			distance	   : '11px',
			color		   : '#363463'
		});*/
		
		jq('#ul-left-menu').scrollTop(0);
		jq('#slimScrollDiv').scrollTop(0);
	});
</script>

<style>
	#ul-left-menu {
		border-top: medium none #fff;
		border-right: 	medium none #fff;
	}
	#ul-left-menu li:nth-child(1) { 
		border-top: 	1px solid #ccc;
	}
	#ul-left-menu li:last-child { 
		border-bottom:	1px solid #ccc;
		border-right:	1px solid #ccc;
	}
	.visit-summary{
		
	}
	#person-detail {
		display: none;
	}
	.dashboard .info-body label {
		display: inline-block;
		font-size: 90%;
		font-weight: bold;
		margin-bottom: 5px;
		width: 190px;
	}
	.clinical-history label{
		float: left;
	}
	.clinical-history span{
		float: 	left;
		display: inline-block;
	}
	.status.active {
		margin-right: 10px;
		margin-top: 7px;
	}
</style>

<div class="onerow">
	<div id="div-left-menu" style="padding-top: 15px;" class="col15 clear">
		<ul id="ul-left-menu" class="left-menu">
			<% visitSummaries.each { summary -> %>
			<li class="menu-item visit-summary" visitid="54" style="border-right:1px solid #ccc; margin-right: 15px; width: 168px; height: 18px;">
				<input type="hidden" class="encounter-id" value="${summary.encounterId}" >
				<span class="menu-date">
					<i class="icon-time"></i>
					<span id="vistdate">
						${ui.formatDatetimePretty(summary.visitDate)}
					</span>
				</span>
				<span class="menu-title">
					<i class="icon-stethoscope"></i>
						<% if (summary.outcome) { %>
							${ summary.outcome }
						<% }  else { %>
							No Outcome Yet
						<% } %>
				</span>
				<span class="arrow-border"></span>
				<span class="arrow"></span>
			</li>
			
			<% } %>
			
			<li style="height: 30px; margin-right: 15px; width: 168px;" class="menu-item">
			</li>
		</ul>
	</div>
	
	<div class="col16 dashboard opdRecordsPrintDiv" style="min-width: 78%">
		<div id="printSection">
			<div id="person-detail">
				<h3>PATIENT SUMMARY INFORMATION</h3>
				
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
			
			<div class="info-section" id="visit-detail">
				
			</div>
			
			<div class="info-sections" id="drugs-detail" style="margin: 0px 10px 0px 5px;">			
				
			</div>		
		</div>
		
		<button id="opdRecordsPrintButton" class="task" style="float: right; margin: 10px;">
			<i class="icon-print small"></i>
			Print
		</button>
	</div>
</div>

<div class="main-content" style="border-top: 1px none #ccc;">
    <div id=""></div>
</div>

<script id="visit-detail-template" type="text/template">
	<div class="info-header">
		<i class="icon-user-md"></i>
		<h3>CLINICAL HISTORY SUMMARY INFORMATION</h3>
	</div>

	<div class="info-body clinical-history">
		<% if (enrolledInAnc){ %>
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Examination:</label>
				<span>{{=examinations}}</span>			
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Diagnosis:</label>
				<span>{{=diagnosis}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Investigations:</label>
				<span>{{=investigations}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>HIV Prior Status:</label>
				<span>{{=hivPriorStatus}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Partner Tested:</label>
				<span>{{=hivPartnerTested}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Partner Result:</label>
				<span>{{=hivPartnerStatus}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Couple Councelled:</label>
				<span>{{=hivCoupleCouncelled}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Feeding Councelling:</label>
				<span>{{=ancCouncelling}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Exclusive Breastfeeding:</label>
				<span>{{=ancExlussiveBF}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Infant Feeding:</label>
				<span>{{=ancForInfected}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Breastfeeding Decision:</label>
				<span>{{=ancDecisionOnBF}}</span>
				<div class="clear"></div>
			</div>
			
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Deworming:</label>
				<span>{{=ancDeworming}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>ANC Exercise:</label>
				<span>{{=ancExcercise}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Treated Net:</label>
				<span>{{=ancLLITN}}</span>
				<div class="clear"></div>
			</div>			
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Internal Referral:</label>
				<span>{{=internalReferral}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>External Referral:</label>
				<span>{{-externalReferral}}</span>
				<div class="clear"></div>
			</div>
			
			
		<% } else if (enrolledInPnc) { %>
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Examination:</label>
				<span>{{=examinations}}</span>			
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Diagnosis:</label>
				<span>{{=diagnosis}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Investigations:</label>
				<span>{{=investigations}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>HIV Prior Status:</label>
				<span>{{=hivPriorStatus}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Partner Tested:</label>
				<span>{{=hivPartnerTested}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Partner Result:</label>
				<span>{{=hivPartnerStatus}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Couple Concelled:</label>
				<span>{{=hivCoupleCouncelled}}</span>
				<div class="clear"></div>
			</div>
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Cervical Screening Method:</label>
				<span>{{=pncCervicalScreeningMethod}}</span>
				<div class="clear"></div>
			</div>
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Cervical Screening Result:</label>
				<span>{{=pncCervicalScreeningResult}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Exercise Given:</label>
				<span>{{=pncExcercise}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Multivitamin Given:</label>
				<span>{{=pncMultivitamin}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Vitamin A Given:</label>
				<span>{{=pncVitaminA}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Haematinics Given:</label>
				<span>{{=pncHaematinics}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>FP Method:</label>
				<span>{{=pncFamilyPlanning}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Internal Referral:</label>
				<span>{{=internalReferral}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>External Referral:</label>
				<span>{{-externalReferral}}</span>
				<div class="clear"></div>
			</div>
			
			
		<% } else { %>		
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Examination:</label>
				<span>{{=examinations}}</span>			
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Diagnosis:</label>
				<span>{{=diagnosis}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Investigations:</label>
				<span>{{=investigations}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>CWC Followup:</label>
				<span>{{=cwcFollowUp}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Exclussive Breastfeeding:</label>
				<span>{{=cwcBreastFeedingExclussive}}</span>
				<div class="clear"></div>
			</div>
			
			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Breastfeeding & Infected:</label>
				<span>{{=cwcBreastFeedingInfected}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>Internal Referral:</label>
				<span>{{=internalReferral}}</span>
				<div class="clear"></div>
			</div>

			<div>
				<label style="display: inline-block; font-weight: bold; width: 210px"><span class="status active"></span>External Referral:</label>
				<span>{{-externalReferral}}</span>
				<div class="clear"></div>
			</div>
		<% } %>
	</div>
</script>


<script id="drugs-template" type="text/template">
	<div class="info-header">
		<i class="icon-medicine"></i>
		<h3>DRUGS PRESCRIPTION SUMMARY INFORMATION</h3>
	</div>

	<table id="drugList">
		<thead>
			<tr style="border-bottom: 1px solid #eee;">
				<th>#</th>
				<th>NAME</th>
				<th>FORMULATION</th>
				<th>DOSAGE</th>
			</tr>
		</thead>
		<tbody>
		{{ _.each(drugs, function(drug, index) { }}
			<tr style="border: 1px solid #eee;">
				<td style="border: 1px solid #eee; padding: 5px 10px; margin: 0;">{{=index+1}}</td>
				<td style="border: 1px solid #eee; padding: 5px 10px; margin: 0;">{{-drug.inventoryDrug.name}}</td>
				<td style="border: 1px solid #eee; padding: 5px 10px; margin: 0;">{{-drug.inventoryDrugFormulation.name}}:{{-drug.inventoryDrugFormulation.dozage}}</td>
				<td style="border: 1px solid #eee; padding: 5px 10px; margin: 0;">{{-drug.dosage}}:{{-drug.dosageUnit.name}}</td>
			</tr>
		{{ }); }}
		 </tbody>
	</table>
</script>

<script id="empty-template" type="text/template">
	<div class="info-header">
		<i class="icon-medicine"></i>
		<h3>DRUGS PRESCRIPTION SUMMARY INFORMATION</h3>
	</div>

	<table id="drugList">
		<thead>
			<tr>
				<th>#</th>
				<th>Name</th>
				<th>Formulation</th>
				<th>Unit</th>
				<th>Dosage</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<td></td>
				<td style="text-align: center;" colspan="4">No Drugs Prescribed</td>
			</tr>
		 </tbody>
	</table>
</script>

<div></div>
<div style="clear: both;"></div>
<div style="clear: both;"></div>