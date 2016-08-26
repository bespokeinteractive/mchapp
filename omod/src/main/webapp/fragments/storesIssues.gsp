<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-folder-open"></i>
			<h3 class="name">VIEW ISSUES</h3>
			
			<div style="margin-top: -1px">
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