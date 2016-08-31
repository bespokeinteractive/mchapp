<script>
    var receipts;

    jq(function () {
        receipts = new ReceiptsViewModel();
        listImmunizationReceipts();

        jq(".searchParams").on('blur change', function () {
            var rcptNames = jq("#rcptNames").val();
            var fromDate = jq("#rcptFrom-field").val();
            var toDate = jq("#rcptDate-field").val();
            listImmunizationReceipts(rcptNames, fromDate, toDate);
        });

        jq(".date").on('dblclick', function () {
//           Clear the date fields
        });

        ko.applyBindings(receipts, jq("#receiptsList")[0]);



        jq("#rcptName").autocomplete({
            minLength: 3,
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("pharmacyapp", "addReceiptsToStore", "fetchDrugListByName") }',
                        {
                            searchPhrase: request.term
                        }
                ).success(function (data) {
                            var results = [];
                            for (var i in data) {
                                var result = {label: data[i].name, value: data[i]};
                                results.push(result);
                            }
                            response(results);
                        });
            },
            focus: function (event, ui) {
                jq("#rcptName").val(ui.item.value.name);
                return false;
            },
            select: function (event, ui) {
                event.preventDefault();
                jQuery("#rcptName").val(ui.item.value.name);
                //set parent category
                var catId = ui.item.value.category.id;
                var drgId = ui.item.value.id;
            }
        });


    });//end of document ready

    function ReceiptsViewModel() {
        var self = this;
        self.availableReceipts = ko.observableArray([]);
    }

    function listImmunizationReceipts(rcptNames, fromDate, toDate) {
        receipts.availableReceipts.removeAll();
        var requestData = {
            rcptNames: rcptNames,
            fromDate: fromDate,
            toDate: toDate
        }
        jq.getJSON('${ ui.actionLink("mchapp", "storesReceipts", "listImmunizationReceipts") }', requestData)
                .success(function (data) {
                    jq.each(data, function(i, item) {
                        receipts.availableReceipts.push(item);
                        console.log(item);
                    });
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                }
        );
    }
</script>

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-folder-open"></i>

            <h3 class="name">VIEW RECEIPTS</h3>

            <div style="margin-top: -1px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label for="rcptNames">&nbsp; Name:</label>
                <input id="rcptNames" type="text" value="" name="rcptNames" placeholder="Vaccine/Diluent"
                       class="searchParams"
                       style="width: 240px">

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'rcptFrom', label: '', endDate: new Date(), useTime: false, defaultToday: false, classes: ['searchParams']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate', id: 'rcptDate', label: '', endDate: new Date(), useTime: false, defaultToday: false, classes: ['searchParams']])}
            </div>
        </div>
    </div>

</div>


<div id="receipts">
    <table id="receiptsList">
        <thead>
        <th>#</th>
        <th>DATE</th>
        <th>VACCINE/DILUENT</th>
        <th>QUANTITY</th>
        <th>VVM STAGE</th>
        <th>REMARKS</th>
        <th>ACTIONS</th>
        </thead>
        <tbody data-bind="foreach: availableReceipts">
        <tr>
            <td data-bind="text: \$index() + 1 "></td>
            <td data-bind="text: createdOn"></td>
            <td data-bind="text: storeDrug.inventoryDrug.name"></td>
            <td data-bind="text: quantity"></td>
            <td data-bind="text: vvmStage"></td>
            <td data-bind="text: remark"></td>
            <td><i class="icon-share small"></i></td>
        </tr>
        </tbody>
    </table>
</div>

<div id="receipts-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Add/Edit Receipts</h3>
    </div>

    <div class="dialog-content">
        <form id="receiptsForm">
            <ul>
                <li>
                    <label>Vaccine/Diluent</label>
                    <input id="rcptName" type="text">
                </li>
                <li>
                    <label>Quantity</label>
                    <input type="text" id="rcptQuantity">
                </li>

                <li>
                    <label>VVM Stage</label>
                    <select id="rcptStage">
                        <option value="0">Select Stage</option>
                        <option value="1">Stage 1</option>
                        <option value="2">Stage 2</option>
                        <option value="3">Stage 3</option>
                        <option value="4">Stage 4</option>
                    </select>
                </li>

                <li>
                    <label>Batch No.</label>
                    <input id="rcptBatchNo" type="text">
                </li>

                <li>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rcptExpiry', id: 'rcptExpiry', label: 'Expiry Date', startDate: new Date(),useTime: false, defaultToday: false])}
                </li>

                <li>
                    <label>Remarks</label>
                    <textarea id="rcptRemarks"></textarea>
                </li>
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Submit</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>