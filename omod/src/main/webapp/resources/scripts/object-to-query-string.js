var objectToQueryString = (function() {
    return {
        convert: function convert(obj) {
            var parts = [];
            parts = parts.concat(toArray(obj));
            return parts.join("&");
        }
    }

    function toArray(obj, parentKey){
        var parts = [];
        var exclude = ["drug_name", "drug_id", "remove", "dosage_unit_label", "formulation_label", "frequency_label"]
        if (parentKey) {
            parentKey = parentKey + "."
        } else {
            parentKey = "";
        }
        for (var i in obj) {
            if (!exclude.includes(i)) {
                if (Array.isArray(obj[i])) {
                    obj[i].forEach(function (value){
                        parts = parts.concat(toArray(value, parentKey + i));
                    });
                } else if (typeof obj[i] === "object") {
                    parts = parts.concat(toArray(obj[i], parentKey + i));
                } else if (obj.hasOwnProperty(i)) {
                    parts.push(encodeURIComponent(parentKey + i) +
                        "=" + encodeURIComponent(obj[i]));
                }
            } 
        }
        return parts;
    }
})()

if (!Array.isArray) {
  Array.isArray = function(arg) {
    return Object.prototype.toString.call(arg) === '[object Array]';
  };
}