<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Stores"])
    ui.includeJavascript("billingui", "moment.js")

    ui.includeCss("uicommons", "datatables/dataTables_jui.css")
    ui.includeJavascript("patientqueueapp", "jquery.dataTables.min.js")
%>

<script>
    var eAction;

    var refreshInTable = function (resultData, dTable) {
        var rowCount = resultData.length;
        if (rowCount == 0) {
            dTable.find('td.dataTables_empty').html("No Records Found");
        }
        dTable.fnPageChange(0);
    };

    var isTableEmpty = function (resultData, dTable) {
        if (resultData.length > 0) {
            return false
        }
        return !dTable || dTable.fnGetNodes().length == 0;
    };
	
	var checkBatchAvailability = function (drgId, drgName, testingFor) {
        var requestData = {
            drgId: drgId,
            drgName: drgName
        }

        jq.getJSON('${ ui.actionLink("mchapp", "storesIssues", "getBatchesForSelectedDrug") }', requestData)
			.success(function (data) {
				if (data.status === "success") {
				} else if (data.status === "fail") {
					jq().toastmessage('showErrorToast', data.message);
				}
				
				drugBatches.availableDrugs.removeAll();
				drugBatchesReturns.availableDrugs.removeAll();
				
				if (testingFor == 2){
					jq.each(data.drugs, function (i, item) {
						drugBatches.availableDrugs.push(item);
					});
				} else if (testingFor == 3){
					jq.each(data.drugs, function (i, item) {
						drugBatchesReturns.availableDrugs.push(item);
					});
				}

			}).error(function (xhr, status, err) {
				jq().toastmessage('showErrorToast', "AJAX error!" + err);
			}
        );
    }

    jq(function () {
        jq("#tabs").tabs();
		
		jq('.dropdown').on('mouseenter', function() {
			jq('#adder div ul li a').show();
		});

        jq('#inline-tabs li').click(function () {
            var addBtn = jq('#adder a.button');
            var addDiv = jq('#adder div');

            if (jq('#drugStock').is(':visible')) {
                addBtn.hide(300);
                addDiv.hide();
            }
            else if (jq('#transactions').is(':visible')) {
				addBtn.hide(300);
				addDiv.show();
            }
            else if (jq('#stockouts').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add StockOuts');
				addDiv.hide();
				addBtn.show(300);
            }
            else if (jq('#equipments').is(':visible')) {
                addBtn.html('<i class="icon-refresh"></i> Add Equipments');
				addDiv.hide();
				addBtn.show(300);
            }
        }).click();

        jq('#adder a').click(function () {
            if (jq('#transactions').is(':visible')) {
				var value = jq(this).data('value');
				
				if (value == 1){
					jq('#rcptName').val('');
					jq('#rcptQuantity').val('');
					jq('#rcptStage').val(0);
					jq('#rcptBatchNo').val('');
					jq('#rcptRemarks').val('');
					
					jq('#closeStockouts input').attr('checked', false);
					jq('#closeStockouts').hide();
					
					receiptsDialog.show();
				}
				else if (value == 2){
					jq('#issueName').val('');
					jq('#issueQuantity').val('');
					jq('#issueStage').val(0);
					jq('#issueRemarks').val('');					
					
					issuesDialog.show();					
				}
				else if (value == 3){
					jq('#rtnsName').val('');
					jq('#rtnsQuantity').val('');
					jq('#rtnsStage').val(0);
					jq('#rtnsRemarks').val('');
				
					returnsDialog.show();					
				}
				else {
					jq().toastmessage('showErrorToast', 'This feature is currently un-available in this release');
					return false;
				}
            }
            else if (jq('#stockouts').is(':visible')) {
                jq('#outsName').val('');
                jq('#outsRemarks').val('');

                stockoutsDialog.show();
            }
            else if (jq('#equipments').is(':visible')) {
                jq('#equipementTypeName').val('');
                jq('#equipementModel').val('');
                jq('#equipementEnergySource').val('');
                jq('#equipementStatus').val('');
                jq('#equipementRemarks').val('');

                equipmentsDialog.show();
            }
        });

        jq('.date input').dblclick(function () {
            var fieldName = jq(this).attr('id').replace("display", "field");

            jq('#' + fieldName).val('');
            jq(this).val('').change();
        });
		
		jq('#stockOutList').on("click", ".update-stockouts", function(){
			var idnt = jq(this).data('idnt');
			
			jq.getJSON('${ ui.actionLink("mchapp", "storesOuts", "getImmunizationStockoutTransaction") }', {transactionId: idnt})
				.success(function (data) {
					var depletedDate = data.depletedOn;
					
					jq('#outsEditId').val(idnt);
					jq('#outsEditName').val(data.name);
					jq('#outsEditRemarks').val(data.remarks);
					
					jq('#outsEditExpiry-field').val(moment(depletedDate).format('YYYY-MM-DD'));
					jq('#outsEditExpiry-display').val(moment(depletedDate).format('DD MMM YYYY'));
					
					stockoutsEditDialog.show();					
				}
			);
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
                        closeStockouts: jq('#inputCloseStockouts:checked').length
                    }
                    if (jq.trim(requestData.storeDrugName) == "" || jq.trim(requestData.quantity) == "" ||
                            jq.trim(requestData.vvmStage) == "" || jq.trim(requestData.rcptBatchNo) == "" || jq.trim(requestData.expiryDate) == "") {
                        jq().toastmessage('showErrorToast', "Check that the required fields have been filled");
                        return false;
                    }
                    jq.getJSON('${ ui.actionLink("mchapp", "storesReceipts", "saveImmunizationReceipts") }', requestData)
						.success(function (data) {
							if (data.status === "success") {
								jq().toastmessage('showSuccessToast', "Receipt Added Successfully");
								receiptsDialog.close();
								
								getStoreDrugStock();
								getStoreTransactions();
								
								if (requestData.closeStockouts == 1){
									getStoreStockouts();
								}
							} else {
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
									
									getStoreDrugStock();
                                    getStoreTransactions();
                                } else {
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
                    if (!jq("#rtnsName").val()) {
                        jq("#rtnsName").addClass("loaderror");
                        jq().toastmessage('showErrorToast', 'Ensure you have filled the drug name')
                        return false;
                    } else if (!jq("#rtnsQuantity").val() || !jq.isNumeric(jq("#rtnsQuantity").val())) {
                        jq("#rtnsQuantity").addClass("loaderror");
                        jq().toastmessage('showErrorToast', 'Ensure you have entered the correct quantity')
                        return false;
                    } else if (jq("#rtnsStage").val() == "0") {
                        jq("#rtnsStage").addClass("loaderror");
                        jq().toastmessage('showErrorToast', 'Ensure you have selected the VMM Stage')
                        return false;
                    } else if (jq("#rtnsBatchNo").val() == "") {
                        jq("#rtnsBatchNo").addClass("loaderror");
                        jq().toastmessage('showErrorToast', 'Ensure you have selected a drug to view batches')
                        return false;
                    }

                    var returnsData = {
                        rtnsName: jq("#rtnsName").val(),
                        rtnsQuantity: jq("#rtnsQuantity").val(),
                        rtnsStage: jq("#rtnsStage").val(),
                        rtnsBatchNo: jq("#rtnsBatchNo option:selected").text(),
                        rtnsRemarks: jq("#rtnsRemarks").val(),
                        patientId: null
                    }
                    jq.getJSON('${ ui.actionLink("mchapp", "storesReturns", "saveImmunizationReturns") }', returnsData)
                            .success(function (data) {
                                if (data.status === "success") {
                                    jq().toastmessage('showSuccessToast', data.message);
                                    returnsDialog.close();
									
									getStoreDrugStock();
                                    getStoreTransactions();
                                } else {
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
		
		var stockoutsEditDialog = emr.setupConfirmationDialog({
            dialogOpts: {
                overlayClose: false,
                close: true
            },
            selector: '#stockouts-dialog-edit',
            actions: {
                confirm: function () {
                    //Code Here
                    var stockoutsData = {
                        outsIdnt: jq("#outsEditId").val(),
                        depletionDate: jq("#outsEditExpiry-field").val(),
                        dateRestocked: jq("#outsEditRestocked-field").val(),
                        outsRemarks: jq("#outsEditRemarks").val()
                    }

                    if (jq.trim(stockoutsData.depletionDate) == "") {
                        jq().toastmessage('showErrorToast', "Check to ensure that Date Depleted been filled");
                        return false;
                    }
					
                    jq.getJSON('${ ui.actionLink("mchapp", "storesOuts", "updateImmunizationStockout") }', stockoutsData)
						.success(function (data) {
							if (data.status === "success") {
								jq().toastmessage('showSuccessToast', data.message);
								stockoutsEditDialog.close();
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
                    stockoutsEditDialog.close();
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
	.loaderror {
		border: 1px solid red !important;
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
	#returnFrom-display, #returnDate-display {
		width: 130px;
	}
	.name {
		color: #f26522;
	}
	#adder {
		border: 1px none #88af28;
		box-shadow: none;
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
		cursor: pointer;
	}
	.ui-widget-content a:hover {
		color: #000fff;
		text-decoration: none;
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
	.dropdown ul {
		position: absolute;
		right: 0;
		
		background: none;
		border: none;
		border-radius: 0;
		color:auto;
		z-index: 99;
	}
	.dropdown ul li {
		background: white none repeat scroll 0 0 !important;
		border-color: #ccc #ccc -moz-use-text-color !important;
		border-image: none;
		border-style: solid solid none !important;
		border-width: 1px 1px medium !important;
		box-shadow: none !important;
		margin: 0 !important;
		padding: 5px!important;
		right: 5px;
		text-align: left;
		top: 8px !important;
		width: 200px;
		cursor: pointer;
	}
	.dropdown ul li:hover {
		background: #007fff none repeat scroll 0 0!important;
	}
	.dropdown ul li:hover a, .dropdown ul li:hover i {
		color: white!important;
		text-decoration: none;
	}
	.dropdown ul li:last-child {
		border-bottom: 1px solid #ccc!important;
	}
	.dropdown ul li a {
		color: #007fff!important;
		padding: 3px!important;
	}
	#stockOutList,
	#drugStockList{
		font-size: 14px;
	}
	#drugStockList tr td:nth-child(4),
	#drugStockList tr td:nth-child(5){
		text-align: right;
	}
	#drugStockList tr td:last-child{
		text-align: center;
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
                <li><a href="#drugStock">Drugs Stock</a></li>
                <li><a href="#transactions">Transactions</a></li>
                <li><a href="#stockouts">Stock Outs</a></li>
                <li><a href="#equipments">Equipments</a></li>

                <li id="adder" class="ui-state-default">
                    <a class="button confirm" style="color:#fff; display: none;">
                        <i class="icon-plus"></i>
                        Add Receipts
                    </a>
					
					<div>
						<div style="position: static" class="dropdown">
							<span class="dropdown-name"><i class="icon-cog"></i>Actions<i class="icon-sort-down"></i></span>
							<ul style="z-index: 99">
								<li><a data-value="1"><i class="icon-file-text"></i>Add Receipts</a></li>
								<li><a data-value="2"><i class="icon-reply"></i>Add Issues</a></li>
								<li><a data-value="3"><i class="icon-retweet"></i>Add Returns</a></li>
								<li><a data-value="4"><i class="icon-reply"></i>Issue To Account</a></li>
								<li><a data-value="5"><i class="icon-thumbs-down"></i>Return To Supplier</a></li>
							</ul>
						</div>
					</div>					
                </li>
            </ul>

            <div id="drugStock">
                ${ui.includeFragment("mchapp", "storesDrugStock")}
            </div>
			
			<div id="transactions">
                ${ui.includeFragment("mchapp", "storesTransactions")}
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