<script>
    var drugReturns;
    var returnDrugBatches;

    function DrugReturnsViewModel() {
        var self = this;
        self.availableReturns = ko.observableArray([]);
    }

    function ReturnDrugBatchViewModel() {
        var self = this;
        self.availableDrugs = ko.observableArray([]);
        self.drugObject = ko.observable();
    }
    function checkReturnsBatchAvailability(drgId, drgName) {
        var requestData = {
            drgId: drgId,
            drgName: drgName
        }
        jq.getJSON('${ ui.actionLink("mchapp", "storesIssues", "getBatchesForSelectedDrug") }', requestData)
                .success(function (data) {
                    if (data.status === "success") {
                        jq(".confirm").show();
                        jq().toastmessage('showSuccessToast', data.message);
                    } else if (data.status === "fail") {
                        jq().toastmessage('showErrorToast', data.message);
                        jq(".confirm").hide();
                    }

                    returnDrugBatches.availableDrugs.removeAll();
                    jq.each(data.drugs, function (i, item) {
                        returnDrugBatches.availableDrugs.push(item);
                    });
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                }
        );
    }
    jq(function () {
        drugReturns = new DrugReturnsViewModel();
        returnDrugBatches = new ReturnDrugBatchViewModel();

        listImmunizationReturns();
        jq("#rtnsName").autocomplete({
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
                jq("#rtnsName").val(ui.item.value.name);
                return false;
            },
            select: function (event, ui) {
                event.preventDefault();
                var drgName = ui.item.value.name;
                jQuery("#rtnsName").val(drgName);
                //set parent category
                var catId = ui.item.value.category.id;
                var drgId = ui.item.value.id;
                checkReturnsBatchAvailability(drgId, drgName);
            }
        });

        ko.applyBindings(drugReturns, jq("#returnsList")[0]);
        ko.applyBindings(returnDrugBatches, jq("#returns-dialog")[0]);

    });//end of document ready function

    function listImmunizationReturns(returnNames, fromDate, toDate) {
        drugReturns.availableReturns.removeAll();
        var requestData = {
            returnNames: returnNames,
            fromDate: fromDate,
            toDate: toDate
        }
        jq.getJSON('${ ui.actionLink("mchapp", "storesReturns", "listImmunizationReturns") }', requestData)
                .success(function (data) {
                    jq.each(data, function (i, item) {
                        drugReturns.availableReturns.push(item);
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

            <h3 class="name">VIEW RETURNS</h3>

            <div style="margin-top: -3px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label for="returnNames">&nbsp; Name:</label>
                <input id="returnNames" type="text" value="" name="returnNames" placeholder="Vaccine/Diluent"
                       style="width: 240px">

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'returnFrom', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate', id: 'returnDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
            </div>
        </div>
    </div>
</div>

<table id="returnsList">
    <thead>
    <th>#</th>
    <th>DATE</th>
    <th>VACCINE/DILUENT</th>
    <th>RETURNED</th>
    <th>VVM STAGE</th>
    <th>REMARKS</th>
    <th>ACTIONS</th>
    </thead>

    <tbody data-bind="foreach: availableReturns">
    <tr>
    <tr>
        <td data-bind="text: \$index() + 1 "></td>
        <td data-bind="text: createdOn"></td>
        <td data-bind="text: storeDrug.inventoryDrug.name"></td>
        <td data-bind="text: quantity"></td>
        <td data-bind="text: vvmStage"></td>
        <td data-bind="text: remark"></td>
        <td><i class="icon-share small"></i></td>
    </tr>
    </tr>
    </tbody>
</table>

<div id="returns-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Add/Edit Returns</h3>
    </div>

    <div class="dialog-content">
        <form id="returnsForm">
            <ul>
                <li>
                    <label>Vaccine/Diluent</label>
                    <input id="rtnsName" type="text">
                </li>
                <li>
                    <label>Quantity</label>
                    <input type="text" id="rtnsQuantity">
                </li>

                <li>
                    <label>VVM Stage</label>
                    <select id="rtnsStage">
                        <option value="0">Select Stage</option>
                        <option value="1">Stage 1</option>
                        <option value="2">Stage 2</option>
                        <option value="3">Stage 3</option>
                        <option value="4">Stage 4</option>
                    </select>
                </li>

                <li>
                    <label>Batch No.</label>
                    <select id="rtnsBatchNo"
                            data-bind="options: \$root.availableDrugs, value: drugObject, optionsText: 'batchNo'"></select>
                </li>

                <li>
                    <label>Expiry Date.</label>
                    <span data-bind="text: \$root.drugObject"></span>
                </li>



                <li>
                    <label>Remarks</label>
                    <textarea id="rtnsRemarks"></textarea>
                </li>
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>