function DrugOrder(
	id, name, dosage, unit,
	formulation, frequency, numberOfDays, comment) {
	var drugOrder = {};
	var orderDetail = {
		"drug_id" : id,
		"drug_name" : name,
		"dosage" : dosage,
		"dosage_unit" : unit,
		"formulation" : formulation,
		"frequency" : frequency,
		"number_of_days" : numberOfDays,
		"comment" : comment
	};
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
		},
		"remove": function (order) {
			console.log(order);
			var id = order.drug_id;
			displayDrugOrders["drug_orders"].remove(id);
			displayDrugOrders["display_drug_orders"].remove(order);
		}
	}
	return displayDrugOrders;
}