<script>
	var issuesTable;
	var issuesTableObject;
	var issuesResultsData = [];
	
	var drugBatches;
	
	function DrugBatchViewModel(){
        var self =this;
        self.availableDrugs = ko.observableArray([]);
        self.drugObject=ko.observable();
    }
	
	var getStoreIssues = function(){
		issuesTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			issueNames: '',
			fromDate:	jq('#issueFrom-field').val(),
			toDate:		jq('#issueDate-field').val()
		}
		
		jq.getJSON('${ ui.actionLink("mchapp", "storesIssues", "listImmunizationIssues") }', requestData)
			.success(function (data) {
				updateIssuesResults(data);
			}).error(function (xhr, status, err) {
				updateIssuesResults([]);
			}
		);
	};
	
	var updateIssuesResults = function(results){
		issuesResultsData = results || [];
		var dataRows = [];
		_.each(issuesResultsData, function(result){
			var drugName = '<a href="storesVaccines.page?drugId=' + result.storeDrug.inventoryDrug.id + '">' + result.storeDrug.inventoryDrug.name + '</a>';
			var remarks = 'N/A';
			var icons = '<a href="storesIssues.page?issueId=' + result.id + '"><i class="icon-bar-chart small"></i>VIEW</a>';
			
			if (result.remark !== ''){
				remarks = result.remark;
			}
			
			dataRows.push([0, moment(result.createdOn, "DD.MMM.YYYY").format('DD/MM/YYYY'), drugName, result.quantity, result.vvmStage, remarks, icons]);
		});

		issuesTable.api().clear();
		
		if(dataRows.length > 0) {
			issuesTable.fnAddData(dataRows);
		}

		refreshInTable(issuesResultsData, issuesTable);
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
		drugBatches = new DrugBatchViewModel();
		
		issuesTableObject = jq("#issuesList");
		
		issuesTable = issuesTableObject.dataTable({
			autoWidth: false,
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "Issues",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Issues Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Issues)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(issuesResultsData, issuesTable)){
					return;
				}
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		issuesTable.on( 'order.dt search.dt', function () {
			issuesTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		jq('#issueNames').on('keyup', function () {
			issuesTable.api().search( this.value ).draw();
		});
	
        jq(".issuesParams").on('change', function () {
            getStoreIssues();
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
                
                var catId = ui.item.value.category.id;
                var drgId = ui.item.value.id;
                checkBatchAvailability(drgId,drgName);
            }
        });
		
		ko.applyBindings(drugBatches, jq("#issues-dialog")[0]);
		
		getStoreIssues();
    });
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

                <label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'issueFrom', label: '', useTime: false, defaultToday: false, classes: ['issuesParams']])}
                <label>&nbsp;&nbsp;To&nbsp;</label>${  ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate'  , id: 'issueDate', label: '', useTime: false, defaultToday: false, classes: ['issuesParams']])}
            </div>
        </div>
    </div>
</div>

<table id="issuesList">
    <thead>
		<th>#</th>
		<th style="width: 100px!important">DATE</th>
		<th>VACCINE/DILUENT</th>
		<th style="width: 100px!important">ISSUED</th>
		<th style="width: 100px!important">VVM STAGE</th>
		<th>REMARKS</th>
		<th>ACTIONS</th>
    </thead>

    <tbody>
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