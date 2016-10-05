<script>
	var drugStockTable;
	var drugStockTableObject;
	var drugStockResultsData = [];
	
	var getStoreDrugStock = function(){
		drugStockTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		
		var requestData = {
			outsNames:	'',
			fromDate:	jq('#outsFrom-field').val(),
			toDate:		jq('#outsDate-field').val()
		}
		
		jq.getJSON('${ ui.actionLink("mchapp", "storesOuts", "listImmunizationStockouts") }', requestData)
			.success(function (data) {
				//updateDrugStockResults(data);
				updateDrugStockResults([]);
			}).error(function (xhr, status, err) {
				updateDrugStockResults([]);
			}
		);
	};
	
	var updateDrugStockResults = function(results){
		drugStockResultsData = results || [];
		var dataRows = [];
		_.each(drugStockResultsData, function(result){
			var drugName = '<a href="storesVaccines.page?drugId=' + result.drug.id + '">' + result.drug.name + '</a>';
			var icons = '<a href="storesReturns.page?returnId=' + result.id + '"><i class="icon-bar-chart small"></i>VIEW</a>';
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

		drugStockTable.api().clear();
		
		if(dataRows.length > 0) {
			drugStockTable.fnAddData(dataRows);
		}

		refreshInTable(drugStockResultsData, drugStockTable);
	};

    jq(function () {
		drugStockTableObject = jq("#drugStockList");
		
		drugStockTable = drugStockTableObject.dataTable({
			autoWidth: false,
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "Stock Items",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Drugs Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Transactions)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(drugStockResultsData, drugStockTable)){
					return;
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		drugStockTable.on( 'order.dt search.dt', function () {
			drugStockTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		jq('#outsNames').on('keyup', function () {
			drugStockTable.api().search( this.value ).draw();
		});
	
        jq(".stockoutParams").on('change', function () {
            getStoreDrugStock();
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
		
		getStoreDrugStock();
    });
</script>

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-folder-open"></i>

            <h3 class="name">DRUG STOCK</h3>

            <div style="margin-top: -3px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label for="drugName">&nbsp; Name:</label>
                <input id="drugName" type="text" value="" name="drugName" placeholder="Vaccine/Diluent"
                       style="width: 240px">

                
            </div>
        </div>
    </div>
</div>

<table id="drugStockList">
    <thead>
		<th>#</th>
		<th>NAME</th>
		<th>CATEGORY</th>
		<th>FORMULATION</th>
		<th>QUANTITY</th>
		<th>REORDER</th>
		<th>ATTRIBUTE</th>
    </thead>

    <tbody>    
    </tbody>
</table>