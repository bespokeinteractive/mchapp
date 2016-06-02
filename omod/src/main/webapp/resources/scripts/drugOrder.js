function DrugOrder(
	id, name, dosage, unit,
	formulation, frequency, numberOfDays, comment) {
	var drugOrder = {};
	var orderDetail = {
		"drug_id" : id,
		"drug_name" : name,
		"dosage" : dosage,
		"dosage_unit" : unit.id,
		"dosage_unit_label" : unit.text,
		"formulation" : formulation.id,
		"formulation_label" : formulation.text,
		"frequency" : frequency.id,
		"frequency_label" : frequency.text,
		"number_of_days" : numberOfDays,
		"comment" : comment
	};
	if (unit.id == 0) {
		orderDetail.dosage_unit = '';
		orderDetail.dosage_unit_label = '--';
	}
	if (formulation.id == 0) {
		orderDetail.formulation = '';
		orderDetail.formulation_label = '--';
	}
	if (frequency.id == 0) {
		orderDetail.frequency = '';
		orderDetail.frequency_label = '--';
	}
	drugOrder[id] = orderDetail;
	return drugOrder;
}

function DrugOrders() {
	return {
		"drug_orders": [],
		"remove": function (id) {
			this["drug_orders"] = this["drug_orders"].filter(function(order){
				return typeof order === "object" && !order.hasOwnProperty(id);
			});
		}
	}
}

function DisplayDrugOrders() {
	var drugOrders = new DrugOrders()
	var displayDrugOrders = {
		"display_drug_orders": ko.observableArray([]),
		"drug_orders": drugOrders,
		"addDrugOrder": function (drugId, drugOrder) {
			displayDrugOrders["display_drug_orders"].push(drugOrder[drugId]);
			displayDrugOrders["drug_orders"]["drug_orders"].push(drugOrder);
			jq('#prescriptions-set').val('SET');
			prescriptionSummary();
		},
		"remove": function (order) {
			console.log(order);
			var id = order.drug_id;
			displayDrugOrders["drug_orders"].remove(id);
			displayDrugOrders["display_drug_orders"].remove(order);
			if (displayDrugOrders["display_drug_orders"]().length == 0){
				jq('#prescriptions-set').val('');
			}
			prescriptionSummary();
		}
	}
	return displayDrugOrders;
}

function prescriptionSummary(){
	if (drugOrders.display_drug_orders().length == 0){
		jq('#summaryTable tr:eq(2) td:eq(1)').text('N/A');
	}
	else{
		var prescription = '';
		drugOrders.display_drug_orders().forEach(function(drug){
			prescription += drug.drug_name + ' ' + drug.formulation_label +'<br/>'
		});
		jq('#summaryTable tr:eq(2) td:eq(1)').html(prescription);
	}
}