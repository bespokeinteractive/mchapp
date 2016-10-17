<script>
	var transactionsTable;
	var transactionsTableObject;
	var transactionsResultsData = [];
	var transactionsHighlightedKeyboardRowIndex;
	
	var drugBatches;
	var drugBatchesReturns;

    function DrugBatchViewModel() {
        var self = this;
        self.availableDrugs = ko.observableArray([]);
        self.drugObject = ko.observable();
    }
	
	function DrugBatchReturnsViewModel() {
        var self = this;
        self.availableDrugs = ko.observableArray([]);
        self.drugObject = ko.observable();
    }
	
	var getStoreTransactions = function(){
		transactionsTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			transName: 	'',
			transType: 	jq('#transType').val(),
			fromDate:	jq('#rcptFrom-field').val(),
			toDate:		jq('#rcptDate-field').val()
		}
		
		jq.getJSON(emr.fragmentActionLink("mchapp", "storesTransactions", "listImmunizationTransactions"), requestData)
			.success(function (data) {
				updateTransactionsResults(data);
			}).error(function (xhr, status, err) {
				updateTransactionsResults([]);
			}
		);
	};
	
	var updateTransactionsResults = function(results){
		transactionsResultsData = results || [];
		var dataRows = [];
		_.each(transactionsResultsData, function(result){
			var drugName = '<a href="storesVaccines.page?drugId=' + result.storeDrug.inventoryDrug.id + '">' + result.storeDrug.inventoryDrug.name + '</a>';
			var remarks = 'N/A';
			var icons = '<a href="storesReceiptDetails.page?receiptId=' + result.id + '"><i class="icon-bar-chart small"></i>VIEW</a>';
			
			if (result.remark !== ''){
				remarks = result.remark;
			}
			
			dataRows.push([0, moment(result.createdOn, "DD.MMM.YYYY").format('DD/MM/YYYY'), result.transactionType.transactionType.toUpperCase(), drugName, result.quantity, result.vvmStage, remarks, icons]);
		});

		transactionsTable.api().clear();
		
		if(dataRows.length > 0) {
			transactionsTable.fnAddData(dataRows);
		}

		refreshInTable(transactionsResultsData, transactionsTable);
	}

    jq(function () {
		transactionsTableObject = jq("#transactionsList");
		
		drugBatches = new DrugBatchViewModel();
		drugBatchesReturns = new DrugBatchReturnsViewModel();
		
		transactionsTable = transactionsTableObject.dataTable({
			autoWidth: false,
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": 'Transactions',
				"sInfoEmpty": "",
				"sZeroRecords": "No Transactions Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(transactionsResultsData, transactionsTable)){
					//this should ensure that nothing happens when the use clicks the
					//row that contain the text that says 'No data available in table'
					return;
				}

				if(transactionsHighlightedKeyboardRowIndex != undefined && !isHighlightedRowOnVisiblePage()){
					unHighlightRow(transactionsTable.fnGetNodes(transactionsHighlightedKeyboardRowIndex));
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		transactionsTable.on( 'order.dt search.dt', function () {
			transactionsTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
        jq(".receiptParams").on('change', function () {			
            getStoreTransactions();
        });
		
		jq('#rcptNames').on('keyup', function () {
			transactionsTable.api().search( this.value ).draw();
		});

        jq("#rcptName").autocomplete({
            minLength: 3,
            source: function (request, response) {
                jq.getJSON('${ ui.actionLink("pharmacyapp", "addReceiptsToStore", "fetchDrugListByName") }', {
					searchPhrase: request.term
				}).success(function (data) {
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
				
				jq.getJSON('${ ui.actionLink("mchapp", "storesReceipts", "checkForUnclosedStockouts") }', {drugId : drgId}).success(function (data) {
					if (data == 1){
						jq('#closeStockouts').show(300);
					} else{
						jq('#closeStockouts input').attr('checked', false);
						jq('#closeStockouts').hide(300);
					}
				});
				
				
            }
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
                var drgName = ui.item.value.name;
                jQuery("#issueName").val(drgName);

                var catId = ui.item.value.category.id;
                var drgId = ui.item.value.id;
                checkBatchAvailability(drgId, drgName, 2);
            }
        });
		
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
                checkBatchAvailability(drgId, drgName, 3);
            }
        });
		
		getStoreTransactions();
		
		ko.applyBindings(drugBatches, jq("#issues-dialog")[0]);
		ko.applyBindings(drugBatchesReturns, jq("#returns-dialog")[0]);
    });
</script>

<style>
	#transactionsList{
		font-size: 12px;
	}
</style>

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-folder-open"></i>

            <h3 class="name">TRANSACTIONS</h3>

            <div style="margin-top: -3px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
				<input id="rcptNames" type="text" value="" name="rcptNames" placeholder="Filer Vaccine/Diluent" style="width: 190px">
                <label for="rcptNames">Type</label>
				<select id="transType" name="transType" class="receiptParams">
					<option value=0>All</option>
					<option value=1>Receipts</option>
					<option value=2>Issues</option>
					<option value=3>Returns</option>
					<option value=4>KEPI Returns</option>
				</select>

                <label>&nbsp;From</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'rcptFrom', label: '', endDate: new Date(), useTime: false, defaultToday: false, classes: ['receiptParams']])}
                <label>&nbsp;To</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate', id: 'rcptDate', label: '', endDate: new Date(), useTime: false, defaultToday: false, classes: ['receiptParams']])}
            </div>
        </div>
    </div>
</div>


<div id="receipts">
    <table id="transactionsList">
        <thead>
			<th style="width: 1px">#</th>
			<th>DATE</th>
			<th>TYPE</th>
			<th>VACCINE/DILUENT</th>
			<th>QNTY</th>
			<th>VVM STAGE</th>
			<th>REMARKS</th>
			<th>ACTIONS</th>
        </thead>
		
        <tbody>			
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
				
				<li id="closeStockouts">
                    <label>&nbsp;</label>
                    <label style="cursor:pointer; background: #fff799 none repeat scroll 0% 0%; padding: 5px; border: 1px solid #ddd; border-radius: 2px; width:248px;">
						<input type="checkbox" id="inputCloseStockouts" style="width: auto; margin-top: 4px" />
						Close Open Transactions
					</label>
                </li>
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Submit</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>

<div id="issues-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Add Issues</h3>
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
                    <input type="text" id="issueQuantity" class="quantityVal">
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
                    <select id="issueBatchNo"
                            data-bind="options: \$root.availableDrugs, value: drugObject, optionsValue: 'expiryDate', optionsText: 'batchNo'"
                            class="quantityVal"></select>
                </li>

                <li>
                    <label>Expiry Date:</label>
                    <input data-bind="value: \$root.drugObject" readonly="">
                </li>
				
				<li>
                    <label>Issue To:</label>
                    <select id="issueAccount">
                        <option value="">Select Destination</option>
                        <option>MCH Clinic</option>
                        <option>Community Health Worker</option>
                    </select>
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
                    <select id="rtnsBatchNo" data-bind="options: \$root.availableDrugs, value: drugObject, optionsValue: 'expiryDate', optionsText: 'batchNo'"></select>
                </li>

                <li>
                    <label>Expiry Date.</label>
					<input data-bind="value: \$root.drugObject" readonly="">
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