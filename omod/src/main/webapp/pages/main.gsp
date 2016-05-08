<%
    ui.decorateWith("appui", "standardEmrPage", [title: "MCH Module"])
%>
<% if (enrolledInAnc){ %>
	${ui.includeFragment("mchapp","antenatalExamination")}
<% } else if (enrolledInPnc) { %>
	${ui.includeFragment("mchapp","postnatalExamination")}
<% } else if (enrolledInCwc) { %>
	${ui.includeFragment("mchapp","childWelfareExamination")}
<% } else { %>
	${ui.includeFragment("mchapp","programSelection")}
<% } %>
