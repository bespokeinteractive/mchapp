<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Stores"])
    ui.includeJavascript("billingui", "moment.js")
	
	ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
%>

<script>
	var eAction;
	
	var refreshInTable = function(resultData, dTable){
		var rowCount = resultData.length;
		if(rowCount == 0){
			receiptsTableObject.find('td.dataTables_empty').html("No Receipts in queue");
		}
		dTable.fnPageChange(0);
	};
	
	var isTableEmpty = function(resultData, dTable){
		if(resultData.length > 0){
			return false
		}
		return !dTable || dTable.fnGetNodes().length == 0;
	};
	
	jq(function () {
		jq("#tabs").tabs();		
		
		jq('#inline-tabs li').click(function(){
			var addBtn = jq('#adder a');
			
			if (jq('#receipts').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add Receipts');
            }
            else if (jq('#issues').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add Issues');
            }
            else if (jq('#returns').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add Returns');
            }
            else if (jq('#stockouts').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add StockOuts');
            }
            else if (jq('#equipments').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add Equipments');
            }
		}).click();
		
		jq('#adder a').click(function(){
			if (jq('#receipts').is(':visible')) {
				jq('#rcptName').val('');
				jq('#rcptQuantity').val('');
				jq('#rcptStage').val(0);				
				jq('#rcptBatchNo').val('');
				jq('#rcptRemarks').val('');

                receiptsDialog.show();
            }
            else if (jq('#issues').is(':visible')) {
                jq('#issueName').val('');
                jq('#issueQuantity').val('');
                jq('#issueStage').val(0);
                jq('#issueName').val('');
                jq('#issueName').val('');
                jq('#issueName').val('');
				
				issuesDialog.show();
            }
            else if (jq('#returns').is(':visible')) {
				jq('#rcptName').val('');
				
                returnsDialog.show();
            }
            else if (jq('#stockouts').is(':visible')) {
                stockoutsDialog.show();
            }
            else if (jq('#equipments').is(':visible')) {
                equipmentsDialog.show();
            }
        });

        var receiptsDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#receipts-dialog',
            actions: {
                confirm: function () {
                    //Code to save the receipt
                    var requestData = {
                        storeDrugName: jq("#rcptName").val(),
                        quantity: jq("#rcptQuantity").val(),
                        vvmStage: jq("#rcptStage").val(),
                        rcptBatchNo: jq("#rcptBatchNo").val(),
                        expiryDate: jq("#rcptExpiry-field").val(),
                        remarks: jq("#rcptRemarks").val(),
                    }
                    if (jq.trim(requestData.storeDrugName) == "" || jq.trim(requestData.quantity) == "" ||
                            jq.trim(requestData.vvmStage) == "" || jq.trim(requestData.rcptBatchNo) == "" || jq.trim(requestData.expiryDate) == "") {
                        jq().toastmessage('showErrorToast', "Check that the required fields have been filled");
                        return false;
                    }
                    jq.getJSON('${ ui.actionLink("mchapp", "storesReceipts", "saveImmunizationReceipts") }', requestData)
                            .success(function (data) {
                                if (data.status === "success") {
                                    jq().toastmessage('showSuccessToast', "Receipt Stored Successfully");
                                    receiptsDialog.close();
									getStoreReceipts();
								}else{
									jq().toastmessage('showErrorToast', "Error Saving Receipt");
								}
							}).error(function (xhr, status, err) {
								jq().toastmessage('showErrorToast', "AJAX error!" + err);
							}
					);
                },
                cancel: function () {
                    receiptsDialog.close();
                }
            }
        });

        var issuesDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#issues-dialog',
            actions: {
                confirm: function () {
                    //Code Here
                    var issueData = {
                        issueName: jq("#issueName").val(),
                        issueQuantity: jq("#issueQuantity").val(),
                        issueStage: jq("#issueStage").val(),
                        issueBatchNo: jq("#issueBatchNo option:selected").text(),
                        issueRemarks: jq("#issueRemarks").val(),
                        patientId: null
                    }
                    if (jq.trim(issueData.issueName) == "" || jq.trim(issueData.issueQuantity) == "" ||
                            jq.trim(issueData.issueStage) == "" || jq.trim(issueData.issueBatchNo) == "") {
                        jq().toastmessage('showErrorToast', "Check that the required fields have been filled");
                        return false;
                    }
                    jq.getJSON('${ ui.actionLink("mchapp", "storesIssues", "saveImmunizationIssues") }', issueData)
                            .success(function (data) {
                                if (data.status === "success") {
                                    jq().toastmessage('showSuccessToast', data.message);
									issuesDialog.close();
									getStoreIssues();
                                }else{
                                    jq().toastmessage('showErrorToast', data.message);
                                }
                            }).error(function (xhr, status, err) {
                                jq().toastmessage('showErrorToast', "AJAX error!" + err);
                            }
                    );
                },
                cancel: function () {
                    issuesDialog.close();
                }
            }
        });

        var returnsDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#returns-dialog',
            actions: {
                confirm: function () {
					var returnsData = {
						rtnsName: jq("#rtnsName").val(),
						rtnsQuantity: jq("#rtnsQuantity").val(),
						rtnsStage: jq("#rtnsStage").val(),
						rtnsBatchNo: jq("#rtnsBatchNo option:selected").text(),
						rtnsRemarks: jq("#rtnsRemarks").val(),
						patientId:null
					}
					jq.getJSON('${ ui.actionLink("mchapp", "storesReturns", "saveImmunizationReturns") }', returnsData)
						.success(function (data) {
							if(data.status === "success"){
								jq().toastmessage('showSuccessToast', data.message);
								returnsDialog.close();
								getStoreReturns();
							}else{
								jq().toastmessage('showErrorToast', data.message);
							}
						}).error(function (xhr, status, err) {
							jq().toastmessage('showErrorToast', "AJAX error!" + err);
						}
					);
                },
                cancel: function () {
                    returnsDialog.close();
                }
            }
        });


        var stockoutsDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#stockouts-dialog',
            actions: {
                confirm: function () {
                    //Code Here
                    var stockoutsData = {
                        outsName: jq("#outsName").val(),
                        depletionDate: jq("#outsExpiry-field").val(),
                        outsRemarks: jq("#outsRemarks").val()
                    }

                    if (jq.trim(stockoutsData.outsName) == "" || jq.trim(stockoutsData.depletionDate) == "") {
                        jq().toastmessage('showErrorToast', "Check that the required fields have been filled");
                        return false;
                    }
                    jq.getJSON('${ ui.actionLink("mchapp", "storesOuts", "saveImmunizationStockout") }', stockoutsData)
                            .success(function (data) {
                                if (data.status === "success") {
                                    jq().toastmessage('showSuccessToast', data.message);
                                    stockoutsDialog.close();
									getStoreStockouts();
                                } else {
                                    jq().toastmessage('showErrorToast', data.message);
                                }
                            }).error(function (xhr, status, err) {
                                jq().toastmessage('showErrorToast', "AJAX error!" + err);
                            }
                    );
                },
                cancel: function () {
                    stockoutsDialog.close();
                }
            }
        });

        var equipmentsDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#equipments-dialog',
            actions: {
                confirm: function () {
                    //Code Here
                    var equipmentData = {
                        equipementTypeName: jq("#equipementTypeName").val(),
                        equipementModel: jq("#equipementModel").val(),
                        dateManufactured: jq("#equipementManufactured-field").val(),
                        equipementRemarks: jq("#equipementRemarks").val(),
                        equipementStatus: jq("#equipementStatus").val(),
                        equipementEnergySource: jq("#equipementEnergySource").val()
                    }

                    if (jq.trim(equipmentData.equipementTypeName) == "" || jq.trim(equipmentData.equipementModel) == "" ||
                            jq.trim(equipmentData.dateManufactured) == "" || jq.trim(equipmentData.equipementEnergySource) == "") {
                        jq().toastmessage('showErrorToast', "Check that the required fields have been filled");
                        return false;
                    }

                    jq.getJSON('${ ui.actionLink("mchapp", "storesEquipments", "saveImmunizationEquipment") }', equipmentData)
                            .success(function (data) {
                                if (data.status === "success") {
                                    jq().toastmessage('showSuccessToast', data.message);
                                    equipmentsDialog.close();
									getStoreEquipment();
                                } else {
                                    jq().toastmessage('showErrorToast', data.message);
                                }
                            }).error(function (xhr, status, err) {
                                jq().toastmessage('showErrorToast', "AJAX error!" + err);
                            }
                    );
                },
                cancel: function () {
                    equipmentsDialog.close();
                }
            }
        });
    });

</script>

<style>
	#breadcrumbs a, #breadcrumbs a:link, #breadcrumbs a:visited {
		text-decoration: none;
	}	
	.dashboard {
		border: 1px solid #eee;
		margin-bottom: 5px;
		padding: 2px 0 0;
	}	
	.dashboard .info-section {
        margin: 2px 5px 5px;
    }	
	.dashboard .info-header i {
		font-size: 2.5em !important;
		margin-right: 0;
		padding-right: 0;
	}	
	.info-header div {
		display: inline-block;
		float: right;
		margin-top: 7px;
	}	
	input[type="text"], select {
		border: 1px solid #aaa;
		border-radius: 2px !important;
		box-shadow: none !important;
		box-sizing: border-box !important;
		height: 32px;
		padding-left: 5px;
	}	
	.info-header span {
		cursor: pointer;
		display: inline-block;
		float: right;
		margin-top: -2px;
		padding-right: 5px;
	}
	.add-on {
		color: #f26522;
		float: right;
		font-size: 8px !important;
		left: auto;
		margin-left: -29px;
		margin-top: 5px !important;
		position: absolute;
	}	
	li .add-on {
		font-size: 16px !important;
	}
	#inline-tabs {
		background: #f9f9f9 none repeat scroll 0 0;
	}
	#outsDate, #outsFrom,
	#rcptDate, #rcptFrom,
	#issueDate, #issueFrom,
	#returnDate, #returnFrom {
		float: none;
		margin-bottom: -9px;
		margin-top: 12px;
		padding-right: 0;
	}
	#outsFrom-display, #outsDate-display,
	#rcptFrom-display, #rcptDate-display,
	#issueFrom-display, #issueDate-display,
	#returnFrom-display, #returnDate-display{
		width: 150px;
	}
	.name {
		color: #f26522;
	}	
	#adder {
		border: 1px none #88af28;
		color: #fff !important;
		float: right;
		margin-right: -10px;
		margin-top: 5px;
	}
	.dialog .dialog-content li {
		margin-bottom: 0px;
	}
	.dialog label {
		display: inline-block;
		width: 120px;
	}
	.dialog select option {
		font-size: 1.0em;
	}
	.dialog select {
		display: inline-block;
		margin: 4px 0 0;
		width: 260px;
		height: 38px;
	}
	.dialog input {
		display: inline-block;
		width: 260px;
		min-width: 10%;
		margin: 4px 0 0;
	}
	.dialog td input {
		width: 40px;
	}
	.dialog textarea {
		display: inline-block;
		width: 260px;
		min-width: 10%;
		resize: none
	}
	form input:focus, form select:focus, form textarea:focus, form ul.select:focus, .form input:focus, .form select:focus, .form textarea:focus, .form ul.select:focus {
		outline: 1px none #007fff;
	}
	#modal-overlay {
		background: #000 none repeat scroll 0 0;
		opacity: 0.4 !important;
	}
	.dialog ul {
		margin-bottom: 20px;
	}
	.ui-buttonset {
		margin-right: -6px;
	}
	.ui-widget-content a {
		color: #007fff;
	}
	.dataTables_info {
		width: 35%;
	}
	.paging_full_numbers .fg-button {
		margin: 1px;
	}
	.paging_full_numbers {
		width: 62% !important;
	}
	.toast-item {
        background-color: #222;
    }
</style>

<div class="clear"></div>

<div class="container">
    <div class="example">
        <ul id="breadcrumbs">
            <li>
                <a href="${ui.pageLink('referenceapplication', 'home')}">
                    <i class="icon-home small"></i></a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                <a href="">MCH</a>
            </li>

            <li>
                <i class="icon-chevron-right link"></i>
                Manage Stores
            </li>
        </ul>
    </div>

    <div class="patient-header new-patient-header">
        <div class="demographics">
            <h1 class="name" style="border-bottom: 1px solid #ddd;">
                <span>MCH STORES &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</span>
            </h1>
        </div>

        <div id="show-icon">
            &nbsp;
        </div>

        <div id="tabs" style="margin-top: 20px!important;">
            <ul id="inline-tabs">
                <li><a href="#receipts">Receipts</a></li>
                <li><a href="#issues">Issues</a></li>
                <li><a href="#returns">Returns</a></li>
                <li><a href="#stockouts">Stock Outs</a></li>
                <li><a href="#equipments">Equipments</a></li>

                <li id="adder" class="ui-state-default">
                    <a style="color:#fff" class="button confirm">
                        <i class="icon-plus"></i>
                        Add Receipts
                    </a>
                </li>
            </ul>

            <div id="receipts">
                ${ui.includeFragment("mchapp", "storesReceipts")}
            </div>

            <div id="issues">
                ${ui.includeFragment("mchapp", "storesIssues")}
            </div>

            <div id="returns">
                ${ui.includeFragment("mchapp", "storesReturns")}
            </div>

            <div id="stockouts">
                ${ui.includeFragment("mchapp", "storesOuts")}
            </div>

            <div id="equipments">
                ${ui.includeFragment("mchapp", "storesEquipments")}
            </div>
        </div>

    </div>
</div>