<script>
    var drugIssues;
    var drugBatches;

    function DrugBatchViewModel(){
        var self =this;
        self.availableDrugs = ko.observableArray([]);
        self.drugObject=ko.observable();
    }
    function checkBatchAvailability(drgId,drgName) {
        var requestData = {
            drgId: drgId,
            drgName: drgName
        }
        jq.getJSON('${ ui.actionLink("mchapp", "storesIssues", "getBatchesForSelectedDrug") }', requestData)
                .success(function (data) {
                    if(data.status ==="success"){
                        jq(".confirm").show();
                        jq().toastmessage('showSuccessToast', data.message);
                    }else if(data.status ==="fail"){
                        jq().toastmessage('showErrorToast', data.message);
                        jq(".confirm").hide();
                    }

                    drugBatches.availableDrugs.removeAll();
					
                    jq.each(data.drugs, function (i, item) {
                        drugBatches.availableDrugs.push(item);
                    });
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                }
        );

    }
    jq(function () {
        drugIssues = new IssuesViewModel();
        drugBatches = new DrugBatchViewModel();
        listImmunizationIssues();
        jq(".searchIssueParams").on('blur change', function () {
            var issueNames = jq("#issueNames").val();
            var fromDate = jq("#issueFrom-field").val();
            var toDate = jq("#issueDate-field").val();
            listImmunizationIssues(issueNames, fromDate, toDate);
        });

        jq("#issueName").autocomplete({
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
                jq("#issueName").val(ui.item.value.name);
                return false;
            },
            select: function (event, ui) {
                event.preventDefault();
                var drgName=ui.item.value.name;
                jQuery("#issueName").val(drgName);
                //set parent category
                var catId = ui.item.value.category.id;
                var drgId = ui.item.value.id;
                checkBatchAvailability(drgId,drgName);
            }
        });

        ko.applyBindings(drugIssues, jq("#issuesList")[0]);
        ko.applyBindings(drugBatches, jq("#issues-dialog")[0]);

    });//end of doc ready

    function IssuesViewModel() {
        var self = this;
        self.availableIssues = ko.observableArray([]);
    }

    function listImmunizationIssues(issueNames, fromDate, toDate) {
        drugIssues.availableIssues.removeAll();
        var requestData = {
            issueNames: issueNames,
            fromDate: fromDate,
            toDate: toDate
        }
        jq.getJSON('${ ui.actionLink("mchapp", "storesIssues", "listImmunizationIssues") }', requestData)
                .success(function (data) {
                    jq.each(data, function (i, item) {
                        drugIssues.availableIssues.push(item);
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

            <h3 class="name">VIEW ISSUES</h3>

            <div style="margin-top: -3px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label for="issueNames">&nbsp; Name:</label>
                <input id="issueNames" type="text" value="" name="issueNames" placeholder="Vaccine/Diluent"
                       style="width: 240px">

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'issueFrom', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate', id: 'issueDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
            </div>
        </div>
    </div>
</div>

<table id="issuesList">
    <thead>
    <th>#</th>
    <th>DATE</th>
    <th>VACCINE/DILUENT</th>
    <th>ISSUED</th>
    <th>VVM STAGE</th>
    <th>REMARKS</th>
    <th>ACTIONS</th>
    </thead>

    <tbody data-bind="foreach: availableIssues">

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

<div id="issues-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Add/Edit Issues</h3>
    </div>

    <div class="dialog-content">
        <form id="issuesForm">
            <ul>
                <li>
                    <label>Vaccine/Diluent</label>
                    <input id="issueName" type="text">
                </li>
				
                <li>
                    <label>Quantity</label>
                    <input type="text" id="issueQuantity">
                </li>

                <li>
                    <label>VVM Stage</label>
                    <select id="issueStage">
                        <option value="0">Select Stage</option>
                        <option value="1">Stage 1</option>
                        <option value="2">Stage 2</option>
                        <option value="3">Stage 3</option>
                        <option value="4">Stage 4</option>
                    </select>
                </li>

                <li>
                    <label>Batch No.</label>
                    <select id="issueBatchNo" data-bind="options: \$root.availableDrugs, value: drugObject, optionsText: 'batchNo'"></select>
                </li>

                <li>
                    <label>Expiry Date:</label>
                    <span data-bind="text: \$root.drugObject"></span>
                </li>

                <li>
                    <label>Remarks</label>
                    <textarea id="issueRemarks"></textarea>
                </li>
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Submit</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>