<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-folder-open"></i>
			<h3 class="name">EQUIPMENTS</h3>
			
			<div style="margin-top: 7px">
				<i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>				
				<label>&nbsp; Name:</label>
				<input id="equipmentName" type="text" value="" name="equipmentName" placeholder="Type / Model" style="width: 410px">
				<label>&nbsp; Type:</label>
				<select id="equipmentType" name="equipmentType" style="width: 180px">
					<option value="0">SELECT TYPE</option>
					<option value="1">FREEZER</option>
					<option value="2">REFRIGERATOR</option>
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
		<tr>
			<td></td>
			<td colspan="6">No Records Found</td>
		</tr>
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
                    <input id="equipementName" type="text">
                </li>
                <li>
                    <label>Model</label>
                    <input type="text" id="equipementModel">
                </li>

                <li>
                    <label>Energy Source</label>
                    <select id="equipementEnergySource" >
                        <option value="">Select Source</option>
                        <option value="Electricity">Electricity</option>
                        <option value="Generator">Generator</option>
                        <option value="Solar Power">Solar Power</option>
                    </select>
                </li>
				
				<li>
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'equipementManufactured', id: 'equipementManufactured', label: 'Manufactured', useTime: false, defaultToday: false])}
                </li>
				
                <li>
                    <label>Remarks</label>
                    <textarea id="equipementRemarks"></textarea>
                </li>
            </ul>
			
            <label class="button confirm" style="float: right; width: auto ! important; margin-right: 5px;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>