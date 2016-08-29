<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-folder-open"></i>
			<h3 class="name">VIEW ISSUES</h3>
			
			<div style="margin-top: -3px">
				<i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>				
				<label for="issueNames">&nbsp; Name:</label>
				<input id="issueNames" type="text" value="" name="issueNames" placeholder="Vaccine/Diluent" style="width: 240px">
				
				<label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'issueFrom', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
				<label>&nbsp;&nbsp;To&nbsp;</label  >${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate',   id: 'issueDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
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
	
    <tbody>
		<tr>
			<td></td>
			<td colspan="6">No Records Found</td>
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
                    <select id="issueStage" >
                        <option value="0">Select Stage</option>
                        <option value="1">Stage 1</option>
                        <option value="2">Stage 2</option>
                        <option value="3">Stage 3</option>
                        <option value="4">Stage 4</option>
                    </select>
                </li>

                <li>
                    <label>Batch No.</label>
                    <input id="issueBatchNo" type="text">
                </li>
				
				<li>
					${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'issueExpiry', id: 'issueExpiry', label: 'Expiry Date', useTime: false, defaultToday: false])}
                </li>
				
                <li>
                    <label>Remarks</label>
                    <textarea id="issueRemarks"></textarea>
                </li>
            </ul>
			
            <label class="button confirm" style="float: right; width: auto ! important; margin-right: 5px;">Confirm</label>
            <label class="button cancel" style="width: auto!important;">Cancel</label>
        </form>
    </div>
</div>