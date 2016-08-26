<div class="dashboard clear">
	<div class="info-section">
		<div class="info-header">
			<i class="icon-folder-open"></i>
			<h3 class="name">EQUIPMENTS</h3>
			
			<div style="margin-top: 7px">
				<i class="icon-filter" style="font-size: 26px!important; color: #5b57a6"></i>				
				<label for="outsNames">&nbsp; Name:</label>
				<input id="outsNames" type="text" value="" name="outsNames" placeholder="Type / Model" style="width: 410px">
				<label for="outsNames">&nbsp; Type:</label>
				<select id="outsType" name="investigation" style="width: 180px">
					<option value="0">SELECT TYPE</option>
					<option value="1">FREEZER</option>
					<option value="2">REFRIGERATOR</option>
				</select>
			</div>			
		</div>
	</div>
</div>

<table id="stockOutList">
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