<%
    ui.decorateWith("appui", "standardEmrPage", [title: "Mother Child Health"])
    ui.includeJavascript("billingui", "moment.js")
    ui.includeJavascript("mchapp", "object-to-query-string.js")
    ui.includeJavascript("mchapp", "drugOrder.js")
	ui.includeJavascript("mchapp", "includes-polyfill.js")
    ui.includeCss("registration", "onepcssgrid.css")
%>
<script type="text/javascript">
    var successUrl = "${ui.pageLink('mchapp','main',[patientId: patient, queueId: queueId])}";
	
	var symptoms = [];
    var symptomsArray = [];
	
    function getReadableAge(dateOfBirth, fromDate) {
        var referenceDate;
        if (!fromDate) {
            referenceDate = moment();
        } else {
            referenceDate = moment(fromDate, 'DD/MM/YYYY');
        }
        var age = Math.floor(moment.duration(referenceDate.diff(moment(dateOfBirth))).asYears());
        var readableAge;
        if (age == 0){
            desc = (age === 1?' month':' months');
            if (age <= 0) {
                age = Math.floor(moment.duration(referenceDate.diff(moment(dateOfBirth))).asWeeks());
                desc = (age === 1?' week':' weeks');

                if (age <= 0) {
                    age = Math.floor(moment.duration(referenceDate.diff(moment(dateOfBirth))).asDays());
                    desc = (age === 1?' day':' days');

                    if (age <= 0) {
                        age = Math.floor(moment.duration(referenceDate.diff(moment(dateOfBirth))).asHours());
                        desc = (age === 1?' hour':' hours');
                    }
                }
            }
	
            readableAge = age + desc;
        } else {
            desc = (age === 1?' year':' years');
            readableAge = age + desc;
        }
        return readableAge;
    }

    function isValidDate(str) {
        var d = moment(str, 'D/M/YYYY');
        var dt = moment(str, 'D MMMM YY');
        if (d == null || (!d.isValid() && !dt.isValid())) return false;

        var result = str.indexOf(d.format('D/M/YYYY')) >= 0
                || str.indexOf(d.format('DD/MM/YYYY')) >= 0
                || str.indexOf(d.format('D/M/YY')) >= 0
                || str.indexOf(d.format('DD/MM/YY')) >= 0
                || str.indexOf(dt.format('D MMM YYYY')) >= 0
                || str.indexOf(dt.format('DD MMMM YYYY')) >= 0
                || str.indexOf(dt.format('D MMM YY')) >= 0
                || str.indexOf(dt.format('DD MMMM YY')) >= 0;
        return result;
    }
	
	function drugDialogVerified(){
		var error = 0;

		if (jq("#drugName").val().trim() == ''){
			jq("#drugName").addClass('red');
			error ++;
		}
		else {
			jq("#drugName").removeClass('red');
		}
		
		if (jq("#drugDosage").val().trim() == ''){
			jq("#drugDosage").addClass('red');
			error ++;
		}
		else {
			jq("#drugDosage").removeClass('red');
		}
		
		if (jq('#drugUnitsSelect :selected').text() == "Select Unit"){
			jq("#drugUnitsSelect").addClass('red');
			error ++;
		}
		else {
			jq("#drugUnitsSelect").removeClass('red');
		}
		
		if (jq('#formulationsSelect :selected').text() == "Select Formulation"){
			jq("#formulationsSelect").addClass('red');
			error ++;
		}
		else {
			jq("#formulationsSelect").removeClass('red');
		}
		
		if (jq('#frequencysSelect :selected').text() == "Select Frequency"){
			jq("#frequencysSelect").addClass('red');
			error ++;
		}
		else {
			jq("#frequencysSelect").removeClass('red');
		}
		
		if (jq("#numberOfDays").val().trim() == '0' || jq("#numberOfDays").val().trim() == ''){
			jq("#numberOfDays").addClass('red');
			error ++;
		}
		else {
			jq("#numberOfDays").removeClass('red');
		}

		if (error == 0){
			return true;
		} else{
			return false;
		}
	}
	
	jq(function() {
		jq(".mch-tabs").tabs();
		jq('#agename').text(getReadableAge('${patient.birthdate}') + ' (' +moment('${patient.birthdate}').format('DD/MM/YYYY')+')');
		
		jq("#cancelButton").on("click", function (e) {
			window.location = '${ui.pageLink("patientqueueapp", "mchClinicQueue")}';            
        });
		
		jq("#symptom").autocomplete({			
			source: function(request, response) {
				jq.getJSON('${ ui.actionLink("patientdashboardapp", "ClinicalNotes", "getSymptoms") }', {
					q: request.term
				}).success(function(data) {
					var results = [];
					for (var i in data) {
						var result = {
							label: data[i].name,
							value: data[i].uuid
						};
						results.push(result);
					}
					symptoms = results;
					response(results);
				});
			},			
			minLength: 3,
			select: function(event, ui) {
				event.preventDefault();
				
				var symptom = _.find(symptoms, function (sign) {
                    return sign.value === ui.item.value;
                });

                if (!symptomsArray.find(function (sign) {
                            return sign.value == symptom.value;
                        })) {
					
					var other_type = "hidden";
					var other_name = "";
					
					if (symptom.value == '00acdc90-a641-41de-ae3a-e9b8d7a71a0f'){
						other_name = "concept.417c40f1-edbf-457b-8ef1-580f26b699fc"
						other_type = "text";
					}			
					
					symptom.othername = other_name;
					symptom.othertype = other_type;
					
                    var signTemplate = _.template(jq("#symptoms-template").html());
                    jq("#symptoms-holder").append(signTemplate(symptom));
                    jq('#symptoms-set').val('SET');
                    jq('#task-symptom').show();

                    symptomsArray.push(symptom);
                    symptomsSummary();
                }
                else {
                    jq().toastmessage('showErrorToast', 'The symptom ' + symptom.label.toLowerCase() + ' has already been added.');
                }

                jq(this).val('');
                return false;
			},
			open: function() {
				jq(this).removeClass("ui-corner-all").addClass("ui-corner-top");
			},
			close: function() {
				jq(this).removeClass("ui-corner-top").addClass("ui-corner-all");
			}
		});
		
		jq("#symptoms-holder").on("click", ".icon-remove",function(){
            var symptomId = jq(this).parents('div.symptoms').find('input[type="hidden"]').attr("value");
            symptoms.splice(symptoms.indexOf(symptomId));

            symptomsArray = symptomsArray.filter(function(sign){
                return sign.value != symptomId;
            });

            symptomsSummary();

            jq(this).parents('div.symptoms').remove();
            if (jq(".symptoms").length == 0){
                jq('#symptoms-set').val('');
                jq('#task-symptom').hide();
            }
        });
		
		jq('.fp-administration input').change(function(){
			var output = '';
			
			if (jq('.fp-method').val() != ''){
				output += 'Method: ' + jq('.fp-method').val() + '<br/>';
			}
			
			if (jq('.ft-type input:checked').length > 0){
				output += 'FP Type: ' + jq('.ft-type input:checked').data('value') + '<br/>';
			}
			
			if (jq('#quantity-given').val() != ''){
				output += 'Quantity: ' + jq('#quantity-given').val() + '<br/>';
			}			
			
			if (output == ''){
				output += 'N/A';
			}
			
			jq('#summaryTable tr:eq(8) td:eq(1)').html(output);
		});
	});
	
	function symptomsSummary(){
		//does summary Here
		if (symptomsArray.length == 0) {
			jq('#summaryTable tr:eq(0) td:eq(1)').text('N/A');
		}
		else {
			var signs = '';
			symptomsArray.forEach(function (sign) {
				signs += sign.label + '<br/>'
			});
			jq('#summaryTable tr:eq(0) td:eq(1)').html(signs);
		}
	}
</script>

<script id="symptoms-template" type="text/template">
  <div class="investigation symptoms">
	<span class="icon-remove selecticon"></span>
    <label style="margin-top: 2px; width: 95%;">{{=label}}
		<input type="hidden" name="concept.{{=value}}" value="{{=value}}"/>
		<input type="{{=othertype}}" name="{{=othername}}" value="" placeholder="Specify Others"/>
	</label>
  </div>
</script>

<style>
	.red{
		border: 1px solid #f00 !important;
	}
	#summaryTable tr:nth-child(2n),
	#summaryTable tr:nth-child(2n+1){
		background: none;
	}
	#summaryTable{
		margin: -5px 0 -6px 0px;
	}
	#summaryTable tr,
	#summaryTable th,
	#summaryTable td {
		border: 		1px none  #eee;
		border-bottom: 	1px solid #eee;
	}
	#summaryTable td:first-child{
		vertical-align: top;
		width: 170px;
	}
	input[type="text"], input[type="password"], select {
		border: 1px solid #aaa;
		border-radius: 2px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 38px !important;
		line-height: 18px !important;
		padding: 0 10px !important;
		width: 100% !important;
	}
	.toast-item {
		background-color: #222;
	}
	.name {
		color: #f26522;
	}
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}
	.new-patient-header .demographics .gender-age {
		font-size: 14px;
		margin-left: -55px;
		margin-top: 12px;
	}
	.new-patient-header .demographics .gender-age span {
		border-bottom: 1px none #ddd;
	}
	.new-patient-header .identifiers {
		margin-top: 5px;
	}
	.tag {
		padding: 2px 10px;
	}
	.tad {
		background: #666 none repeat scroll 0 0;
		border-radius: 1px;
		color: white;
		display: inline;
		font-size: 0.8em;
		padding: 2px 10px;
	}

	.status-container {
		padding: 5px 10px 5px 5px;
	}
	.catg {
		color: #363463;
		margin: 35px 10px 0 0;
	}
	.print-only {
		display: none;
	}
	.button-group {
		display: inline-block;
		position: relative;
		vertical-align: middle;
	}
	.button-group > .button:first-child:not(:last-child):not(.dropdown-toggle) {
		border-bottom-right-radius: 0;
		border-top-right-radius: 0;
	}
	.button-group > .button:first-child {
		margin-left: 0;
	}

	.button-group > .button:hover, .button-group > .button:focus, .button-group > .button:active, .button-group > .button.active {
		z-index: 2;
	}
	.button-group > .button {
		border-radius: 5px;
		float: left;
		position: relative;
	}
	.button.active, button.active, input.active[type="submit"], input.active[type="button"], input.active[type="submit"], a.button.active {
		background: #d8d8d8 none repeat scroll 0 0;
		border-color: #d0d0d0;
	}
	.button-group > .button:not(:first-child):not(:last-child) {
		border-radius: 0;
	}
	.button-group > .button {
		border-radius: 5px;
		float: left;
		position: relative;
	}
	.button-group > .button:last-child:not(:first-child) {
		border-bottom-left-radius: 0;
		border-top-left-radius: 0;
	}
	.button-group .button + .button, .button-group .button + .button-group, .button-group .button-group + .button, .button-group .button-group + .button-group {
		margin-left: -1px;
	}
	ul.left-menu {
		border-style: solid;
	}
	.col15 {
		display: inline-block;
		float: left;
		max-width: 22%;
		min-width: 22%;
	}
	.col16 {
		display: inline-block;
		float: left;
		width: 730px;
	}
	#date-enrolled label {
		display: none;
	}
	.add-on {
		color: #f26522;
	}
	.append-to-value {
		color: #999;
		float: right;
		left: auto;
		margin-left: -200px;
		margin-top: 13px;
		padding-right: 55px;
		position: relative;
	}
	.menu-title span {
		display: inline-block;
		width: 65px;
	}
	span a:hover {
		text-decoration: none;
	}
	form label,
	.form label {
		display: inline-block;
		padding-left: 10px;
		width: 140px;
	}
	form input,
	form textarea,
	.form input,
	.form textarea {
		display: inline-block;
		min-width: 1%!important;
	}
	form select,
	form ul.select,
	.form select,
	.form ul.select {
		display: inline-block;
		min-width: 3%;
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus {
		outline: 2px none #007fff;
		box-shadow: 0 0 1px 0 #ccc !important;
	}
	form input[type="checkbox"], .form input[type="checkbox"] {
		margin-top: 4px;
		cursor: pointer;
	}
	.dialog-content textarea {
		border: 1px solid #aaa !important;
		margin: 10px;
		width: 90% !important;
	}	
	.onerow {
		clear: both;
		padding: 0 10px;
	}
	.col4 {
		width: 31%;
	}
	.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
		float: left;
		margin: 0 3% 0 0;
	}
	.col1.last, .col2.last, .col3.last, .col4.last, .col5.last, .col6.last, .col7.last, .col8.last, .col9.last, .col10.last, .col11.last, .col12 {
		margin: 0;
	}
	#confirmation .confirm {
		float: right;
	}	
	.add-on {
		color: #f26522;
		cursor: pointer;
		float: right;
		left: auto;
		margin-left: -31px;
		margin-top: 10px;
		position: absolute;
	}
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4 !important;
	}	
	.ui-tabs .ui-tabs-panel {
		padding: 0 1px;
	}	
	.simple-form-ui section.focused, .simple-form-ui #confirmation.focused, .simple-form-ui form section.focused, .simple-form-ui form #confirmation.focused {
		min-height: 400px;
	}
	.header-template{
		 border-bottom: 1px solid #eee;
	}
	.header-template span{
		color: #f26522;
	}
	.header-template i{
		color: #666;
	}	
	#profile-items{
		margin-top: 10px;
	}
	#investigations-table{
		margin-top: 1px;
	}
	.title-label{
		color: #f26522;
		cursor: pointer;
		font-size: 1.3em;
		font-weight: normal;
	}
	.testbox {
		background-color: rgba(0, 0, 0, 0.01);
		border: 1px solid rgba(51, 51, 51, 0.1);
		min-height: 130px;
		margin: 0 0 15px 5px;
		width: 100%;
	}
	.testbox div {
		background: #5b57a6 none repeat scroll 0 0;
		border-bottom: 1px solid rgba(51, 51, 51, 0.1);
		color: #fff;
		margin: -1px;
		padding: 2px 15px;
	}
	.floating-controls{
		margin-top: 5px;
		padding: 0 !important;
	}	
	.floating-controls input{
		cursor: pointer;
		float: none!important;
	}
	.floating-controls label{
		cursor: pointer;
	}
	.floating-controls span{
		color: #f26522;
	}
	.floating-controls textarea{
		resize: none;
	}
	.info-header h3{
		color: #f26522;
	}
	#cancelButton{
		margin-left: 5px;
	}
	.fp-administration textarea,
	.fp-administration select,
	.fp-administration input[type="text"]{
		width: 75%!important;
	}
	.fp-administration input[type="radio"] {
		-webkit-appearance: checkbox;
		-moz-appearance: checkbox;
		-ms-appearance: checkbox;
		cursor: pointer;
	}
</style>

<div class="clear"></div>
<div>
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="${ui.pageLink('patientqueueapp', 'mchClinicQueue')}">Mother Child Health</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                ${title}
            </li>
        </ul>
    </div>
</div>

<div class="patient-header new-patient-header">
    <div class="demographics">
        <h1 class="name">
            <span id="surname">${patient.familyName},<em>surname</em></span>
            <span id="othname">${patient.givenName} ${patient.middleName ? patient.middleName : ''} &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <em>other names</em>
            </span>

            <span class="gender-age">
                <span>
                    ${gender}
                </span>
                <span id="agename"></span>

            </span>
        </h1>

        <br/>
		
		<div id="stacont" class="status-container">
				<span class="status active"></span>
				Visit Status
			</div>
		<div class="tag">Outpatient</div>
		<div class="tad">Last Visit: ${ui.formatDatePretty(previousVisit)}</div>

        <div class="tad" id="enrollmentDate">Enrolled: ${patientProgram?ui.formatDatePretty(patientProgram.dateEnrolled):"--"}</div>

        
    </div>

    <div class="identifiers">
        <em>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Patient ID</em>
        <span>${patient.getPatientIdentifier()}</span>
        <br>

        <div class="catg">
            <i class="icon-tags small" style="font-size: 16px"></i><small>Category:</small> ${patientCategory}
        </div>
    </div>
</div>

${ui.includeFragment("mchapp","mchProfile")}

<div class="mch-tabs" style="margin-top:5px!important;">
	<ul>
		<li id="cn"><a href="#clinical-notes">
			<% if (opdConcept.equalsIgnoreCase("MCH CLINIC")) { %>
				<span class="title">Clinical Notes</span>
			<% } else if (opdConcept.equalsIgnoreCase("MCH IMMUNIZATION")){ %>
				<span class="title">Immunizations</span>
			<% } %>
		</a></li>
		<li id="ti"><a href="#triage-info">Triage Information</a></li>
		<li id="cs"><a href="#clinical-summary">Clinical History</a></li>
		<li id="lr"><a href="#investigations">Lab Reports</a></li>
	</ul>
	
	<div id="clinical-notes">
		<% if (enrolledInAnc){ %>
			${ui.includeFragment("mchapp","antenatalExamination", [patientId: patient.patientId, queueId: queueId])}
		<% } else if (enrolledInPnc) { %>
			${ui.includeFragment("mchapp","postnatalExamination", [patientId: patient.patientId, queueId: queueId])}
		<% } else if (enrolledInCwc) { %>
			${ui.includeFragment("mchapp","childWelfareExamination", [patientId: patient.patientId, queueId: queueId])}
		<% } else { %>
			${ui.includeFragment("mchapp","programSelection", [patientId: patient.patientId, queueId: queueId])}
		<% } %>
	</div>

	<div id="triage-info">
		${ ui.includeFragment("mchapp", "triageSummary", [patientId: patientId]) }
	</div>
	
	<div id="clinical-summary">
		${ ui.includeFragment("mchapp", "visitSummary", [patientId: patientId]) }
	</div>
	
	<div id="investigations">
		${ ui.includeFragment("patientdashboardapp", "investigations", [patientId: patientId]) }
	</div>
</div>