<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Stores"])
    ui.includeJavascript("billingui", "moment.js")
%>

<script>
	jq(function () {
		jq("#tabs").tabs();		
		
		jq('#inline-tabs li').click(function(){			
			
		}).click();
	});
</script>

<style>
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}	
	.dashboard {
		border: 1px solid #eee;
		margin-bottom: 5px;
		padding: 2px 0 0;
	}	
	.dashboard .info-section {
        margin: 2px 5px 5px;
    }	
	.dashboard .info-header i {
		font-size: 2.5em !important;
		margin-right: 0;
		padding-right: 0;
	}	
	.info-header div {
		display: inline-block;
		float: right;
		margin-top: 7px;
	}	
	input[type="text"], select {
		border: 1px solid #aaa;
		border-radius: 2px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 30px;
		padding-left: 5px;
	}	
	.info-header span {
		cursor: pointer;
		display: inline-block;
		float: right;
		margin-top: -2px;
		padding-right: 5px;
	}
	.add-on {
		color: #f26522;
		float: right;
		font-size: 8px !important;
		left: auto;
		margin-left: -29px;
		margin-top: 4px !important;
		position: absolute;
	}
	#inline-tabs {
		background: #f9f9f9 none repeat scroll 0 0;
	}
	#outsDate, #outsFrom,
	#rcptDate, #rcptFrom,
	#issueDate, #issueFrom,
	#returnDate, #returnFrom {
		float: none;
		margin-bottom: -9px;
		margin-top: 12px;
		padding-right: 0;
	}
	#outsFrom-display, #outsDate-display,
	#rcptFrom-display, #rcptDate-display,
	#issueFrom-display, #issueDate-display,
	#returnFrom-display, #returnDate-display{
		width: 150px;
	}
	.name {
		color: #f26522;
	}
</style>

<div class="clear"></div>
<div class="container">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="">MCH</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Manage Stores
            </li>
        </ul>
    </div>
	
	<div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>MCH STORES &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
            </h1>
        </div>
		
		<div id="show-icon">
			&nbsp;
		</div>

        <div id="tabs" style="margin-top: 20px!important;">
            <ul id="inline-tabs">
                <li><a href="#receipts">Receipts</a></li>
                <li><a href="#issues">Issues</a></li>
                <li><a href="#returns">Returns</a></li>
                <li><a href="#stockouts">Stock Outs</a></li>
                <li><a href="#equipments">Equipments</a></li>
            </ul>

            <div id="receipts">
				${ ui.includeFragment("mchapp", "storesReceipts") }
            </div>

            <div id="issues">
				${ ui.includeFragment("mchapp", "storesIssues") }
            </div>

            <div id="returns">
				${ ui.includeFragment("mchapp", "storesReturns") }
            </div>
			
			<div id="stockouts">
				${ ui.includeFragment("mchapp", "storesOuts") }
            </div>
			
			<div id="equipments">
				${ ui.includeFragment("mchapp", "storesEquipments") }
            </div>
        </div>

    </div>
</div>