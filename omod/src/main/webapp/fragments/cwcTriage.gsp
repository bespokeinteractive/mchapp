<script>
    jq(function () {

        //submit data
        jq(".submit").on("click", function (event) {
            event.preventDefault();
            var data = jq("form#cwc-triage-form").serialize();

            jq.post(
                    '${ui.actionLink("mchapp", "cwcTriage", "saveCwcTriageInfo")}',
                    data,
                    function (data) {
                        if (data.status === "success") {
                            window.location = "${ui.pageLink("patientqueueapp", "mchTriageQueue")}"
                        } else if (data.status === "error") {
                            //show error message;
                            jq().toastmessage('showErrorToast', data.message);
                        }
                    },
                    "json");
        });
    });

</script>

<div>
    <div style="padding-top: 15px;" class="col15 clear">
        <ul id="left-menu" class="left-menu">
            <li class="menu-item selected" visitid="54">
                <span class="menu-date">
                    <i class="icon-time"></i>
                    <span id="vistdate">23 May 2016<br> &nbsp; &nbsp; (Active since 04:10 PM)</span>
                </span>

                <span class="menu-title" style="height: 25px;">
                    <i class="icon-stethoscope"></i>
                    Reviewed
                </span>

                <span class="arrow-border"></span>
                <span class="arrow"></span>
            </li>

            <li style="height: 30px;" class="menu-item" visitid="53">
            </li>
        </ul>
    </div>

    <div style="min-width: 78%" class="col16 dashboard">
        <div class="info-section">
            <form id="cwc-triage-form">
                <div class="profile-editor"></div>

                <div class="info-header">
                    <i class="icon-user-md"></i>

                    <h3>TRIAGE DETAILS</h3>
                </div>

                <div class="info-body">
                    <input type="hidden" name="patientId" value="${patientId}">
                    <input type="hidden" name="queueId" value="${queueId}">

                    <div>
                        <label for="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Weight</label>
                        <input type="text" id="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                               name="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
                        <span class="append-to-value">Kgs</span>
                    </div>

                    <div>
                        <label for="weightCategories">Weight Categories</label>
                        <select id="weightCategories">
                            <option value="normal">Normal Growth</option>
                            <option value="stunted">Stunted Growth</option>
                            <option value="Over Weight">Over Weight</option>
                            <option value="Under Weight">Under Weight</option>
                        </select>
                    </div>

                    <div>
                        <label for="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Height</label>
                        <input type="text" id="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
                               name="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
                        <span class="append-to-value">Cms</span>
                    </div>

                    <div>
                        <label for="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6">M.U.A.C</label>
                        <input id="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6" class="number numeric-range focused"
                               type="text"
                               max="999" min="0" maxlength="7" value=""
                               name="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6"
                               id="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6">
                        <span class="append-to-value">cm</span>
                    </div>

                    <div>
                        <label></label>
                        <label style="padding-left:0px; width: auto;">
                            <input type="checkbox" name="send_for_examination" value="yes">
                            Tick to Send to Examination Room
                        </label>
                    </div>
                </div>
            </form>

            <div>
                <span class="button submit confirm right" id="antenatalTriageFormSubmitButton"
                      style="margin-top: 10px; margin-right: 50px;">
                    <i class="icon-save"></i>
                    Save
                </span>
            </div>
        </div>
    </div>
</div>

<div class="container">
    <br style="clear: both">
</div>