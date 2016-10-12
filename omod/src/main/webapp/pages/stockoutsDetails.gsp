<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Stockout Details"])
    ui.includeJavascript("billingui", "moment.js")

    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
%>

<script>
    jq(function () {

        

    }); //end of doc ready
</script>

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
                <a href="${ui.pageLink('mchapp', 'stores')}">MCH Stores</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Transaction: 00${transactionId}
            </li>
        </ul>
    </div>
</div>

<div>
    ID: ${stockout.id} <br />
    Drug: ${stockout.drug.name} <br />
    Date: ${ui.formatDatePretty(stockout.createdOn)} <br />
    Depleted On: ${ui.formatDatePretty(stockout.dateDepleted)} <br />
    Restocked On: ${stockout.dateRestocked? ui.formatDatePretty(stockout.dateRestocked) : 'N/A'} <br />
    Remarks: ${stockout.remarks} <br />
</div>