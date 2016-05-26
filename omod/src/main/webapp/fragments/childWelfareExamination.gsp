<script>

    var outcomeId;
    jq(function () {
        jq("#datepicker").datepicker({
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
        <div class="info-section">
            <form id="bcg-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>BCG Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

        <div class="info-section">
            <form id="polio-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>Oral Polio Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

        <div class="info-section">
            <form id="tdp-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>Diphtheria Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

        <div class="info-section">
            <form id="pneumococcal-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>Pneumococcal Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

        <div class="info-section">
            <form id="rotarix-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>Rota Virus Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

        <div class="info-section">
            <form id="measles-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>Measles Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

        <div class="info-section">
            <form id="yellowfever-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-diagnosis"></i>

                    <h3>Yellow Fever Vaccine</h3>
                </div>

                <div class="info-body">

                </div>
            </form>
        </div>

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
                <input type="text" id="datepicker">
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