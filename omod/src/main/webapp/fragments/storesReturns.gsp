<script>
    var returnDrugBatches;
	
	var returnsTable;
	var returnsTableObject;
	var issuesReturnsData = [];
	
	var getStoreReturns = function(){
		returnsTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			returnNames: '',
			fromDate:	 jq('#returnFrom-field').val(),
			toDate:		 jq('#returnDate-field').val()
		}
		
		jq.getJSON('${ ui.actionLink("mchapp", "storesReturns", "listImmunizationReturns") }', requestData)
			.success(function (data) {
				updateReturnsResults(data);
			}).error(function (xhr, status, err) {
				updateReturnsResults([]);
			}
		);
	};
	
	var updateReturnsResults = function(results){
		issuesReturnsData = results || [];
		var dataRows = [];
		_.each(issuesReturnsData, function(result){
			var drugName = '<a href="storesVaccines.page?drugId=' + result.storeDrug.inventoryDrug.id + '">' + result.storeDrug.inventoryDrug.name + '</a>';
			var remarks = 'N/A';
			var icons = '<a href="storesReturnDetails.page?returnId=' + result.id + '"><i class="icon-bar-chart small"></i>VIEW</a>';
			
			if (result.remark !== ''){
				remarks = result.remark;
			}
			
			dataRows.push([0, moment(result.createdOn, "DD.MMM.YYYY").format('DD/MM/YYYY'), drugName, result.quantity, result.vvmStage, remarks, icons]);
		});

		returnsTable.api().clear();
		
		if(dataRows.length > 0) {
			returnsTable.fnAddData(dataRows);
		}

		refreshInTable(issuesReturnsData, returnsTable);
	};

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
        returnDrugBatches = new ReturnDrugBatchViewModel();

		returnsTableObject = jq("#returnsList");
		
		returnsTable = returnsTableObject.dataTable({
			autoWidth: false,
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "Returns",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Issues Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Returns)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(issuesReturnsData, returnsTable)){
					return;
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		returnsTable.on( 'order.dt search.dt', function () {
			returnsTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		jq('#returnNames').on('keyup', function () {
			returnsTable.api().search( this.value ).draw();
		});
	
        jq(".returnsParams").on('change', function () {
            getStoreReturns();
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
                checkReturnsBatchAvailability(drgId, drgName);
            }
        });

        ko.applyBindings(returnDrugBatches, jq("#returns-dialog")[0]);
		
		getStoreReturns();
    });//end of document ready function
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

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'returnFrom', label: '', useTime: false, defaultToday: false, classes: ['returnsParams']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${  ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate',   id: 'returnDate', label: '', useTime: false, defaultToday: false, classes: ['returnsParams']])}
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

    <tbody>    
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
                            data-bind="options: \$root.availableDrugs, value: drugObject, optionsValue: 'expiryDate', optionsText: 'batchNo'"></select>
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