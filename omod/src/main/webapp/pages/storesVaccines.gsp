<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Drug Transactions"])
    
	ui.includeJavascript("billingui", "jq.print.js")
	ui.includeJavascript("billingui", "moment.js")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
	
    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
	ui.includeCss("mchapp", "views.css")	
%>

<script>
	jq(function () {		
		jq("#printButton").on("click", function(e){
            jq("#print").print({
				globalStyles: 	false,
				mediaPrint: 	false,
				stylesheet: 	'${ui.resourceLink("pharmacyapp", "styles/print-out.css")}',
				iframe: 		false,
				width: 			800,
				height:			700
			});
        });
		
        jq("#returnToDrugList").on("click", function (e) {
            window.location.href = emr.pageLink("mchapp", "stores");
        });		
	});
</script>

<style>
	table{
		margin-top: 3px;
	}
	.name {
		color: #f26522;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}
	th:first-child{
		width: 5px;
	}
	.print-only{
		display: none;
	}
</style>

<div class="clear"></div>

<div id="current" class="container">
	<div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
					<i class="icon-home small"></i>
				</a>
            </li>
			
			<li>
                <a href="${ui.pageLink('mchapp', 'stores')}">
					<i class="icon-chevron-right link"></i>MCH Stores
				</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                View Item Details
            </li>
        </ul>
    </div>
	
	<div class="patient-header new-patient-header">
		<div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>VIEW CURRENT DRUGS STOCK &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
            </h1>
        </div>
		
		<div class="show-icon">
			&nbsp;
		</div>
		
		<div class="exampler">
			
			<div>
				<span>Drug Name:</span><b>${drug.name}</b><br/>
				<span>Category:</span>${drug.category.name}<br/>
				<span>Current Qnty:</span>${quantity}<br/>
			</div>
		</div>
	</div>
</div>

<div id="print">
	<center class="print-only">		
		<h2>
			<img width="100" height="100" align="center" title="OpenMRS" alt="OpenMRS" src="${ui.resourceLink('billingui', 'images/kenya_logo.bmp')}"><br/>
			<b>
				<u>${userLocation}</u>
			</b>
		</h2>
		
		<h2><b>CURRENT STOCK BALANCE</b></h2>
	</center>
	
	<div class="print-only">
		<label>
			<span class='status active'></span>
			Drug Name:
		</label>
		<span>${drug.name}</span>
		<br/>
		
		<label>
			<span class='status active'></span>
			Category:
		</label>
		<span>${drug.category.name}</span>
		<br/>
		
		<label>
			<span class='status active'></span>
			Available:
		</label>
		<span>${quantity}</span>
		<br/>
		<br/>
	</div>

	<table cellpadding="5" cellspacing="0" width="100%" id="queueList">
		<tr align="center">
			<thead>
				<th>#</th>
				<th>DATE</th>
				<th>TRANSACTION</th>
				<th>BATCH</th>
				<th>EXPIRY</th>
				<th>OPENING</th>
				<th>RECEIVED</th>
				<th>ISSUED</th>
				<th>CLOSING</th>
			</thead>
		</tr>
		
		<tbody>
			<% storeDrugs.eachWithIndex { it, index -> %>
				<tr>
					<td>${index+1}</td>
					<td>${ui.formatDatePretty(it.createdOn)}</td>
					<td>${(it.transactionType.transactionType).toString().toUpperCase()}</td>
					<td>${it.storeDrug.batchNo}</td>
					<td>${ui.formatDatePretty(it.storeDrug.expiryDate)}</td>
					<td>${it.openingBalance}</td>
					
					<% if (it.transactionType.id == 1 || it.transactionType.id == 3) { %>
						<td>${it.quantity}</td>
						<td>&mdash;</td>
					<% } else { %>
						<td>&mdash;</td>
						<td>${it.quantity}</td>				
					<% } %>
					
					<td>${it.closingBalance}</td>			
				</tr>		
			<% } %>	
		</tbody>
	</table>
</div>

<div style="margin:10px 0 20px;">
	<span id="printButton" class="button task right">
		<i class="icon-print"> </i>
		Print
	</span>
	<span id="returnToDrugList" class="button cancel">Back To List</span>
</div>