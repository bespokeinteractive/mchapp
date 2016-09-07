<script>
	var equipmentTable;
	var equipmentTableObject;
	var equipmentResultsData = [];
	
	var getStoreEquipment = function(){
		equipmentTableObject.find('td.dataTables_empty').html('<span><img class="search-spinner" src="'+emr.resourceLink('uicommons', 'images/spinner.gif')+'" /></span>');
		var requestData = {
			equipmentName: '',
            equipmentType: jq('#equipmentType').val()
		}
		
		jq.getJSON('${ ui.actionLink("mchapp", "storesEquipments", "listImmunizationEquipment") }', requestData)
			.success(function (data) {			
				updateEquipmentResults(data);
			}).error(function (xhr, status, err) {
				updateEquipmentResults([]);
			}
		);
	};
	
	var updateEquipmentResults = function(results){
		equipmentResultsData = results || [];
		var dataRows = [];
		_.each(equipmentResultsData, function(result){
			var icons = '<a href="storesReturns.page?returnId=' + result.id + '"><i class="icon-pencil small"></i>EDIT</a>';
			var status = "Working"
			
			console.log(result);
			
			if (result.workingStatus !== true){
				status= "Not Working";
			}
			
			dataRows.push([0, result.equipmentType, result.model, status, result.energySource, result.ageInYears, icons]);
		});

		equipmentTable.api().clear();
		
		if(dataRows.length > 0) {
			equipmentTable.fnAddData(dataRows);
		}

		refreshInTable(equipmentResultsData, equipmentTable);
	};
	
    jq(function () {
		equipmentTableObject = jq("#equipmentList");
		
		equipmentTable = equipmentTableObject.dataTable({
			autoWidth: false,
			bFilter: true,
			bJQueryUI: true,
			bLengthChange: false,
			iDisplayLength: 25,
			sPaginationType: "full_numbers",
			bSort: false,
			sDom: 't<"fg-toolbar ui-toolbar ui-corner-bl ui-corner-br ui-helper-clearfix datatables-info-and-pg"ip>',
			oLanguage: {
				"sInfo": "Equipments",
				"sInfoEmpty": " ",
				"sZeroRecords": "No Equipments Found",
				"sInfoFiltered": "(Showing _TOTAL_ of _MAX_ Equipments)",
				"oPaginate": {
					"sFirst": "First",
					"sPrevious": "Previous",
					"sNext": "Next",
					"sLast": "Last"
				}
			},

			fnDrawCallback : function(oSettings){
				if(isTableEmpty(equipmentResultsData, equipmentTable)){
					return;
				}
				
				equipmentTableObject.find('tbody tr').unbind('click');
				equipmentTableObject.find('tbody tr').unbind('hover');

				equipmentTableObject.find('tbody tr').click(
					function(){
						highlightedMouseRowIndex = equipmentTable.fnGetPosition(this);
						selectRow(highlightedMouseRowIndex);
					}
				);
			},
			
			fnRowCallback : function (nRow, aData, index){
				return nRow;
			}
		});
		
		equipmentTable.on( 'order.dt search.dt', function () {
			equipmentTable.api().column(0, {search:'applied', order:'applied'}).nodes().each( function (cell, i) {
				cell.innerHTML = i+1;
			} );
		}).api().draw();
		
		jq('#equipmentName').on('keyup', function () {
			equipmentTable.api().search( this.value ).draw();
		});
	
        jq("#equipmentType").on('change', function () {
            getStoreEquipment();
        });
		
		getStoreEquipment();
    });
	
    
</script>

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-folder-open"></i>

            <h3 class="name">EQUIPMENTS</h3>

            <div style="margin-top: 7px">
                <i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>
                <label>&nbsp; Name:</label>
                <input id="equipmentName" type="text" value="" name="equipmentName" placeholder="Type / Model"
                       style="width: 410px">
                <label>&nbsp; Type:</label>
                <select id="equipmentType" name="equipmentType" style="width: 180px">
                    <option value="">SELECT TYPE</option>
                    <option value="FREEZER">FREEZER</option>
                    <option value="REFRIGERATOR">REFRIGERATOR</option>
                </select>
            </div>
        </div>
    </div>
</div>

<table id="equipmentList">
    <thead>
		<th>#</th>
		<th>TYPE</th>
		<th>MODEL</th>
		<th>STATUS</th>
		<th>ENERGY SOURCE</th>
		<th>AGE</th>
		<th>ACTIONS</th>
    </thead>

    <tbody>
    </tbody>
</table>

<div id="equipments-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Add/Edit Equipments</h3>
    </div>

    <div class="dialog-content">
        <form id="receiptsForm">
            <ul>
                <li>
                    <label>Type</label>
                    <select id="equipementTypeName" name="equipmentType">
                        <option value="0">SELECT TYPE</option>
                        <option value="FREEZER">FREEZER</option>
                        <option value="REFRIGERATOR">REFRIGERATOR</option>
                    </select>
                </li>
				
                <li>
                    <label>Model</label>
                    <input type="text" id="equipementModel">
                </li>

                <li>
                    <label>Energy Source</label>
                    <select id="equipementEnergySource">
                        <option value="">Select Source</option>
                        <option value="Electricity">Electricity</option>
                        <option value="Generator">Generator</option>
                        <option value="Solar Power">Solar Power</option>
                    </select>
                </li>

                <li>
                    ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'equipementManufactured', id: 'equipementManufactured', label: 'Manufactured', useTime: false, endDate: new Date(), defaultToday: false])}
                </li>
				
				<li>
                    <label>Working Status</label>
                    <select id="equipementStatus">
                        <option value="">Select Status</option>
                        <option value="1">Working</option>
                        <option value="0">Not Working</option>
                    </select>
                </li>

                <li>
                    <label>Remarks</label>
                    <textarea id="equipementRemarks"></textarea>
                </li>
            </ul>

            <label class="button confirm"
                   style="float: right; width: auto ! important; margin-right: 5px;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>