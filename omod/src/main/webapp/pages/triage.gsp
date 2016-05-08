<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH"])
%>

<% if (enrolledInAnc){ %>
	${ui.includeFragment("mchapp","antenatalTriage")}
<% } else if (enrolledInPnc) { %>
	${ui.includeFragment("mchapp","postnatalTriage")}
<% } else if (enrolledInCwc) { %>
	${ui.includeFragment("mchapp","cwcTriage")}
<% } else { %>
	${ui.includeFragment("mchapp","programSelection")}
<% } %>