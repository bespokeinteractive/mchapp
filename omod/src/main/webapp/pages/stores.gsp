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

        <div id="tabs" style="margin-top: 40px!important;">
            <ul id="inline-tabs">
                <li><a href="#receipts">Receipts</a></li>
                <li><a href="#issues">Issues</a></li>
                <li><a href="#returns">Returns</a></li>
                <li><a href="#stockouts">Stock Outs</a></li>
                <li><a href="#equipments">Equipments</a></li>
            </ul>

            <div id="receipts">
				x
            </div>

            <div id="issues">
				x
            </div>

            <div id="returns">
				x
            </div>
			
			<div id="stockouts">
				x
            </div>
			
			<div id="equipments">
				x
            </div>
        </div>

    </div>
</div>