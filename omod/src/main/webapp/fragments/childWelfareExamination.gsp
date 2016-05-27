<style>
.col1, .col2, .col3, .col4, .col5, .col6, .col7, .col8, .col9, .col10, .col11, .col12 {
    color: #555;
    text-align: left;
}
</style>
<script>
    var currentWorkflowBeingEdited;
    var patientProgramForWorkflowEdited;

    var outcomeId;
    jq(function () {
        jq(".datepicker").datepicker({
            changeMonth: true,
            changeYear: true,
            dateFormat: 'yy-mm-dd'
        });
        var exitcwcdialog = emr.setupConfirmationDialog({
            selector: '#exitCwcDialog',
            actions: {
                confirm: function () {
                    var endDate = jq("#datepicker").val();
                    outcomeId = jq("#programOutcome").val();
                    var startDate = "${patientProgram.dateEnrolled}";

                    if (outcomeId == '' || outcomeId == "0") {
                        alert("Outcome Required");
                        return;
                    }
                    //&& startDate > endDate run test to ensure end date is not earlier than start start date

                    else if (!isEmpty(startDate) && !isEmpty(endDate)) {
                        var result = handleExitProgram(${patientProgram.patientProgramId}, "${patientProgram.dateEnrolled}",
                                endDate, outcomeId);

                    } else {
                        alert("invalid end date");
                        return;
                    }
                    exitcwcdialog.close();
                },
                cancel: function () {
                    exitcwcdialog.close();
                }
            }
        });
        jq("#programExit").on("click", function (e) {
            exitcwcdialog.show();
        });
    });//end of doc ready

    function showEditWorkflowPopup(wfName, patientProgramId, programWorkflowId) {
        var params = {
            patientProgramId: patientProgramId,
            programWorkflowId: programWorkflowId
        }
        jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "getPossibleNextStates") }', params)
                .success(function (data) {
                    //load drop down
                    console.log(data);
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });
        jq("#" + programWorkflowId).show();
        console.info(wfName + " - " + patientProgramId + " - " + programWorkflowId);
        currentWorkflowBeingEdited = programWorkflowId;
        patientProgramForWorkflowEdited = patientProgramId;
    }

    function handleChangeWorkflowState(c) {
        var stateId = jq("#changeToState").val();
        var onDate =jq("#datepicker_"+c+"").val()
        if (stateId == 0) {
            jq().toastmessage('showErrorToast', "Select State!");
            return;
        }else if(isEmpty(onDate)){
            jq().toastmessage('showErrorToast', "Select Date!");
            return;
        }else{
            jq().toastmessage('showNoticeToast', "Saving State...!");
            processHandleChangeWorkflowState(stateId,onDate);
        }

    }

    function processHandleChangeWorkflowState(stateId,onDateDMY) {
        var ppId = patientProgramForWorkflowEdited;
        var wfId = currentWorkflowBeingEdited;
        var lastStateStartDate = jq('#lastStateStartDate').val();
        var lastStateEndDate = jq('#lastStateEndDate').val();
        var lastState = jq('lastState').val();
        var stateData={
            patientProgramId:ppId,
            programWorkflowId:wfId,
            programWorkflowStateId:stateId,
            onDateDMY:onDateDMY
        }

        jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "changeToState") }', stateData)
                .success(function (data) {
                    jq().toastmessage('showNoticeToast', data.message);
                    return data.status;
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });
    }
    function hideLayer(divId) {
        jq("#" + divId).hide();
    }

    function isEmpty(o) {
        return o == null || o == '';
    }
    function handleExitProgram(programId, enrollmentDateYmd, completionDateYmd, outcomeId) {

        var updateData = {
            programId: programId,
            enrollmentDateYmd: enrollmentDateYmd,
            completionDateYmd: completionDateYmd,
            outcomeId: outcomeId
        }
        jq.getJSON('${ ui.actionLink("mchapp", "cwcTriage", "updatePatientProgram") }', updateData)
                .success(function (data) {
                    jq().toastmessage('showNoticeToast', data.message);
                    return data.status;
                }).error(function (xhr, status, err) {
                    jq().toastmessage('showErrorToast', "AJAX error!" + err);
                });

    }
</script>

<div>
    <div style="padding-top: 15px;" class="col15 clear">
        <ul id="left-menu" class="left-menu">
            <li class="menu-item selected" visitid="54">
                <span class="menu-date">
                    <i class="icon-time"></i>
                    <span id="vistdate">Immunizations</span>
                </span>

                <div class="patient-profile">

                </div>
                <span class="arrow-border"></span>
                <span class="arrow"></span>
            </li>

            <li style="height: 30px;" class="menu-item" visitid="53">
            </li>
        </ul>
    </div>


    <div style="min-width: 78%" class="col16 dashboard">
        <table width="100%">
            <% patientProgram.program.workflows.each { workflow -> %>
            <% def stateId; def stateStart;def stateName; %>
            <tr>
                <td style="" valign="top">
                    <div class="info-section">
                        <form id="bcg-form">
                            <div class="profile-editor"></div>

                            <div class="info-header">
                                <i class="icon-diagnosis"></i>

                                <h3><small>${workflow.concept.name}:</small></h3>
                            </div>

                            <div class="info-body">
                                <% patientProgram.states.each { state -> %>
                                <% if (!state.voided && state.state.programWorkflow.programWorkflowId == workflow.programWorkflowId && state.active) {
                                    stateId = state.state.concept.conceptId;
                                    stateName = state.state.concept.name;
                                    stateStart = state.startDate;
                                } %>
                                <% } %>

                                <div id="${workflow.programWorkflowId}" style="display: none;">

                                    <table id="workflowTable_${workflow.programWorkflowId}">
                                    </table>
                                    <input type="hidden" id="lastStateStartDate" value=""/>
                                    <input type="hidden" id="lastStateEndDate" value=""/>
                                    <input type="hidden" id="lastState" value=""/>

                                    <div class="onerow">
                                        <div class="col2">Change to</div>

                                        <div class="col2">
                                            <select name="changeToState" id="changeToState">
                                                <option value="0">Select a State</option>
                                                <% if (workflow.states != null || workflow.states != "") { %>
                                                <% workflow.states.each { state -> %>
                                                <option id="${state.id}"
                                                        value="${state.id}">${state.concept.name}</option>
                                                <% } %>
                                                <% } %>
                                            </select>

                                        </div>

                                        <div class="col2">on</div>

                                        <div class="col2">
                                            <input type="text" id="datepicker_${workflow.programWorkflowId}"
                                                   class="datepicker">
                                        </div>

                                        <div class="col2"><input type="button" value="Change"
                                                                 onClick="handleChangeWorkflowState(${workflow.programWorkflowId})"/></div>

                                        <div class="col2 last">
                                            <input type="button" value="Cancel"
                                                   onClick="currentWorkflowBeingEdited = null;
                                                   hideLayer(${workflow.programWorkflowId})"/>
                                        </div>

                                    </div>

                                </div>

                                <% if (stateId != null) { %>
                                <b>${stateName}</b>
                                <em>(Date Given : ${stateStart})</em>
                                <% } else { %>
                                <em>(None)</em>
                                <% } %>

                                <a href="#"
                                   onclick="showEditWorkflowPopup('${workflow.concept.name}', ${patientProgram.patientProgramId},
                                           ${workflow.programWorkflowId})">[View/Edit]</a>

                            </div>
                        </form>
                    </div>
                </td>
            </tr>
            <% } %>
        </table>

    </div>

    <span id="programExit" class="button cancel">Exit From Program</span>

</div>

<div id="exitCwcDialog" class="dialog" style="display: none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Exit From Program</h3>
    </div>

    <div class="dialog-content">
        <ul>
            <li>
                <label for="datepicker">Completion Date</label>
                <input type="text" id="datepicker" class="datepicker">
            </li>
            <li>
                <label for="programOutcome">Outcome</label>
                <select name="programOutcome" id="programOutcome">
                    <option value="0">Choose Outcome</option>
                    <% if (possibleProgramOutcomes != null || possibleProgramOutcomes != "") { %>
                    <% possibleProgramOutcomes.each { outcome -> %>
                    <option id="${outcome.id}" value="${outcome.id}">${outcome.name}</option>
                    <% } %>
                    <% } %>
                </select>
            </li>
            <button class="button confirm right" id="processProgramExit">Save</button>
            <span class="button cancel">Cancel</span>
        </ul>
    </div>
</div>