<script>
	var receiptsTable;
	var receiptsTableObject;
	var receiptsResultsData = [];
	var receiptshighlightedKeyboardRowIndex;
	
	var getStoreReceipts = function(){
		receiptsTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			rcptNames: '',
			fromDate:	jq('#rcptFrom-field').val(),
			toDate:		jq('#rcptDate-field').val()
		}
		
		jq.getJSON(emr.fragmentActionLink("mchapp", "storesReceipts", "listImmunizationReceipts"), requestData)
			.success(function (data) {
				updateReceiptResults(data);
			}).error(function (xhr, status, err) {
				updateReceiptResults([]);
			}
		);
	};
	
	var updateReceiptResults = function(results){
		receiptsResultsData = results || [];
		var dataRows = [];
		_.each(receiptsResultsData, function(result){
			var drugName = '<a href="storesVaccinesReceipts.page?drugId=' + result.storeDrug.inventoryDrug.id + '">' + result.storeDrug.inventoryDrug.name + '</a>';
			var remarks = 'N/A';
			var icons = '<a href="storesReceipts.page?receiptId=' + result.id + '"><i class="icon-bar-chart small"></i>VIEW</a>';
			
			if (result.remark !== ''){
				remarks = result.remark;
			}
			
			dataRows.push([0, moment(result.createdOn, "DD.MMM.YYYY").format('DD/MM/YYYY'), drugName, result.quantity, result.vvmStage, remarks, icons]);
		});

		receiptsTable.api().clear();
		
		if(dataRows.length > 0) {
			receiptsTable.fnAddData(dataRows);
		}

		refreshInTable(receiptsResultsData, receiptsTable);
	}

    jq(function () {
		receiptsTableObject = jq("#receiptsList");
		
		receiptsTable = receiptsTableObject.dataTable({
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "Receipts",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Receipts Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Receipts)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(receiptsResultsData, receiptsTable)){
					//this should ensure that nothing happens when the use clicks the
					//row that contain the text that says 'No data available in table'
					return;
				}

				if(receiptshighlightedKeyboardRowIndex != undefined && !isHighlightedRowOnVisiblePage()){
					unHighlightRow(receiptsTable.fnGetNodes(receiptshighlightedKeyboardRowIndex));
				}
				
				receiptsTableObject.find('tbody tr').unbind('click');
				receiptsTableObject.find('tbody tr').unbind('hover');

				receiptsTableObject.find('tbody tr').click(
					function(){
						highlightedMouseRowIndex = receiptsTable.fnGetPosition(this);
						selectRow(highlightedMouseRowIndex);
					}
				);
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		receiptsTable.on( 'order.dt search.dt', function () {
			receiptsTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
        jq(".receiptParams").on('change', function () {			
            getStoreReceipts();
        });
		
		jq('#rcptNames').on('keyup', function () {
			receiptsTable.api().search( this.value ).draw();
		});

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
		
		getStoreReceipts();
    });
</script>

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-folder-open"></i>

            <h3 class="name">VIEW RECEIPTS</h3>

            <div style="margin-top: -3px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label for="rcptNames">&nbsp; Name:</label>
				<input id="rcptNames" type="text" value="" name="rcptNames" placeholder="Vaccine/Diluent" style="width: 240px">

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'rcptFrom', label: '', endDate: new Date(), useTime: false, defaultToday: false, classes: ['receiptParams']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate', id: 'rcptDate', label: '', endDate: new Date(), useTime: false, defaultToday: false, classes: ['receiptParams']])}
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
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Submit</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>