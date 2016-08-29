<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-folder-open"></i>
			<h3 class="name">VIEW RETURNS</h3>
			
			<div style="margin-top: -3px">
				<i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>				
				<label for="returnNames">&nbsp; Name:</label>
				<input id="returnNames" type="text" value="" name="returnNames" placeholder="Vaccine/Diluent" style="width: 240px">
				
				<label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'returnFrom', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
				<label>&nbsp;&nbsp;To&nbsp;</label  >${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate',   id: 'returnDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
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
		<tr>
			<td></td>
			<td colspan="6">No Records Found</td>
		</tr>
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
                    <select id="rtnsStage" >
                        <option value="0">Select Stage</option>
                        <option value="1">Stage 1</option>
                        <option value="2">Stage 2</option>
                        <option value="3">Stage 3</option>
                        <option value="4">Stage 4</option>
                    </select>
                </li>

                <li>
                    <label>Batch No.</label>
                    <input id="rtnsBatchNo" type="text">
                </li>
				
				<li>
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rtnsExpiry', id: 'rtnsExpiry', label: 'Expiry Date', useTime: false, defaultToday: false])}
                </li>
				
                <li>
                    <label>Remarks</label>
                    <textarea id="rtnsRemarks"></textarea>
                </li>
            </ul>
			
            <label class="button confirm" style="float: right; width: auto ! important; margin-right: 5px;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>