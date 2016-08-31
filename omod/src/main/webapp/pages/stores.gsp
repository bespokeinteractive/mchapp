<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Stores"])
    ui.includeJavascript("billingui", "moment.js")
%>

<script>
	var eAction
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

                receiptsDialog.show();
            }
            else if (jq('#issues').is(':visible')) {
                issuesDialog.show();
            }
            else if (jq('#returns').is(':visible')) {
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
					jq.getJSON('${ ui.actionLink("mchapp", "storesReceipts", "saveImmunizationReceipts") }', requestData)
							.success(function (data) {
								if(data.status === "success"){
									jq().toastmessage('showSuccessToast', "Receipt Stored Successfully");
                                    receiptsDialog.close();
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
                        issueBatchNo: jq("#issueBatchNo").val(),
                        issueRemarks: jq("#issueRemarks").val(),
                    }
                    jq.getJSON('${ ui.actionLink("mchapp", "storesReceipts", "saveImmunizationReceipts") }', issueData)
                            .success(function (data) {
                                if(data.status === "success"){
                                    jq().toastmessage('showSuccessToast', "Receipt Stored Successfully");
                                    receiptsDialog.close();
                                }else{
                                    jq().toastmessage('showErrorToast', "Error Saving Receipt");
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
                    //Code Here
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
				${ ui.includeFragment("mchapp", "storesReceipts") }
            </div>

            <div id="issues">
				${ ui.includeFragment("mchapp", "storesIssues") }
            </div>

            <div id="returns">
				${ ui.includeFragment("mchapp", "storesReturns") }
            </div>
			
			<div id="stockouts">
				${ ui.includeFragment("mchapp", "storesOuts") }
            </div>
			
			<div id="equipments">
				${ ui.includeFragment("mchapp", "storesEquipments") }
            </div>
        </div>

    </div>
</div>