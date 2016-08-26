<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-folder-open"></i>
			<h3 class="name">VIEW STOCKOUTS</h3>
			
			<div style="margin-top: -1px">
				<i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>				
				<label for="outsNames">&nbsp; Name:</label>
				<input id="outsNames" type="text" value="" name="outsNames" placeholder="Vaccine/Diluent" style="width: 240px">
				
				<label>&nbsp;&nbsp;From&nbsp;</label>${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rFromDate', id: 'outsFrom', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
				<label>&nbsp;&nbsp;To&nbsp;</label  >${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'rToDate',   id: 'outsDate', label: '', useTime: false, defaultToday: false, class: ['newdtp']])}
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
		<tr>
			<td></td>
			<td colspan="6">No Records Found</td>
		</tr>
    </tbody>
</table>