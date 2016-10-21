<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Stores:-Receipt Details"])
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
                Receipt ID: ${title}
            </li>
        </ul>
    </div>
</div>

<div>
    ID: ${drugObject.id} <br />
    VMM Stage: ${drugObject.id} <br />
    Remark: ${drugObject.remark} <br />
    Quantity Transacted: ${drugObject.quantity} <br />
    Transaction Date: ${drugObject.createdOn} <br />
    Created By: ${drugObject.createdBy} <br />
    Transaction Drug: ${drugObject.storeDrug.inventoryDrug.name} <br />
    Drug Batch: ${drugObject.storeDrug.batchNo} <br />
    Transaction Type: ${drugObject.transactionType.transactionType} <br />
    Issued To: ${drugObject.patient == null ? "Dispensed From Stores": patient} <br />
</div>