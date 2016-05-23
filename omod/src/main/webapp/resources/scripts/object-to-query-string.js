var objectToQueryString = {
  convert: function (obj) {
      var parts = [];
      parts = parts.concat(toArray(obj));
      return parts.join("&");
  }

  function toArray(obj, parentKey) {
      var parts = [];
      if (parentKey) {
          parentKey = parentKey + "."
      } else {
          parentKey = "";
      }
      for (var i in obj) {
          if (typeof obj[i] === "object") {
              parts = parts.concat(toArray(obj[i], parentKey + i));
          } else if (obj.hasOwnProperty(i)) {
              parts.push(encodeURIComponent(parentKey + i) + 
                  "=" + encodeURIComponent(obj[i]));
          }
      }
      return parts;
  }
}
