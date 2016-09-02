<script>
    var drugStockouts;

    jq(function () {
        drugStockouts = new DrugStockoutsViewModel();
        listImmunizationStockouts();

        ko.applyBindings(drugStockouts, jq("#stockOutList")[0]);
    }); //end of doc ready function

    function DrugStockoutsViewModel() {
        var self = this;
        self.availableStockouts = ko.observableArray([]);
    }

    function listImmunizationStockouts(outsNames, fromDate, toDate) {
        drugStockouts.availableStockouts.removeAll();
        var stockoutData = {
            outsNames: outsNames,
            fromDate: fromDate,
            toDate: toDate
        }
        jq.getJSON('${ ui.actionLink("mchapp", "storesOuts", "listImmunizationStockouts") }', stockoutData)
                .success(function (data) {
                    jq.each(data, function (i, item) {
                        console.log(item);
                        drugStockouts.availableStockouts.push(item);
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

            <h3 class="name">VIEW STOCKOUTS</h3>

            <div style="margin-top: -3px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label for="outsNames">&nbsp; Name:</label>
                <input id="outsNames" type="text" value="" name="outsNames" placeholder="Vaccine/Diluent"
                       style="width: 240px">

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'outsFrom', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate', id: 'outsDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
            </div>
        </div>
    </div>
</div>

<table id="stockOutList">
    <thead>
    <th>#</th>
    <th>DATE</th>
    <th>VACCINE/DILUENT</th>
    <th>DEPLETED</th>
    <th>RESTOCKED</th>
    <th>REMARKS</th>
    <th>ACTIONS</th>
    </thead>

    <tbody data-bind="foreach: availableStockouts">
    <tr>
        <td data-bind="text: \$index() + 1 "></td>
        <td data-bind="text: createdOn"></td>
        <td data-bind="text: drug.name"></td>
        <td data-bind="text: dateDepleted"></td>
        <td data-bind="text: dateRestocked"></td>
        <td data-bind="text: remarks"></td>
        <td><i class="icon-share small"></i></td>
    </tr>
    </tbody>
</table>

<div id="stockouts-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Record Stock-Outs</h3>
    </div>

    <div class="dialog-content">
        <form id="receiptsForm">
            <ul>
                <li>
                    <label>Vaccine/Diluent</label>
                    <input id="outsName" type="text">
                </li>

                <li>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'outsExpiry', id: 'outsExpiry', label: 'Depleted On', useTime: false, defaultToday: false])}
                </li>

                <li>
                    <label>Remarks</label>
                    <textarea id="outsRemarks"></textarea>
                </li>
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>