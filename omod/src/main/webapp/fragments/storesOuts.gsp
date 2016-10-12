<script>
	var stockoutTable;
	var stockoutTableObject;
	var stockoutResultsData = [];
	
	var getStoreStockouts = function(){
		stockoutTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			outsNames:	'',
			fromDate:	jq('#outsFrom-field').val(),
			toDate:		jq('#outsDate-field').val()
		}
		
		jq.getJSON('${ ui.actionLink("mchapp", "storesOuts", "listImmunizationStockouts") }', requestData)
			.success(function (data) {
				updateStockoutsResults(data);
			}).error(function (xhr, status, err) {
				updateStockoutsResults([]);
			}
		);
	};
	
	var updateStockoutsResults = function(results){
		stockoutResultsData = results || [];
		var dataRows = [];
		_.each(stockoutResultsData, function(result){
			var drugName = '<a href="storesVaccines.page?drugId=' + result.drug.id + '">' + result.drug.name + '</a>';
			var icons = '<a class="update-stockouts" title="Update Transaction"><i class="icon-file-text small"></i></a> <a title="View Transaction" href="stockoutsDetails.page?transactionId=' + result.id + '"><i class="icon-bar-chart small"></i></a>';
			var remarks = 'N/A';
			var depleted = '&mdash;';
			
			if (result.remarks !== ''){
				remarks = result.remarks;
			}
			
			if (result.dateRestocked){
				depleted = moment(result.dateRestocked, "DD.MMM.YYYY").format('DD/MM/YYYY');
			}
			
			dataRows.push([0, moment(result.createdOn, "DD.MMM.YYYY").format('DD/MM/YYYY'), drugName, moment(result.dateDepleted, "DD.MMM.YYYY").format('DD/MM/YYYY'), depleted, remarks, icons]);
		});

		stockoutTable.api().clear();
		
		if(dataRows.length > 0) {
			stockoutTable.fnAddData(dataRows);
		}

		refreshInTable(stockoutResultsData, stockoutTable);
	};

    jq(function () {
		stockoutTableObject = jq("#stockOutList");
		
		stockoutTable = stockoutTableObject.dataTable({
			autoWidth: false,
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "Transactions",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Transactions Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Transactions)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(stockoutResultsData, stockoutTable)){
					return;
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		stockoutTable.on( 'order.dt search.dt', function () {
			stockoutTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		jq('#outsNames').on('keyup', function () {
			stockoutTable.api().search( this.value ).draw();
		});
	
        jq(".stockoutParams").on('change', function () {
            getStoreStockouts();
        });
		
        jq("#outsName").autocomplete({
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
                jq("#outsName").val(ui.item.value.name);
                return false;
            },
            select: function (event, ui) {
                event.preventDefault();
                var drgName=ui.item.value.name;
                jQuery("#outsName").val(drgName);
                //set parent category
                var catId = ui.item.value.category.id;
                var drgId = ui.item.value.id;
            }
        });
		
		getStoreStockouts();
    });
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

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'outsFrom', label: '', useTime: false, defaultToday: false, classes: ['stockoutParams']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${  ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate',   id: 'outsDate', label: '', useTime: false, defaultToday: false, classes: ['stockoutParams']])}
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

    <tbody>    
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
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'outsExpiry', id: 'outsExpiry', label: 'Depleted On', endDate: new Date(),useTime: false, defaultToday: false])}
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