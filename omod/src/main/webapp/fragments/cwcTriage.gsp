<script>
    jq(function () {
        //submit data
        jq(".submit").on("click", function (event) {

            var wcat = jq("form #weightCategories").val();
            var gcat = jq("form #growthMonitor").val();
            if (wcat == "0") {
                jq().toastmessage('showErrorToast', "Select a Weight Category!");
                return false;
            }

            if (gcat == "0") {
                jq().toastmessage('showErrorToast', "Select Growth Status!");
                return false;
            }
            if (wcat === '123814AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' || wcat === 'f7cdbe84-fb91-4968-b886-ceb00a07d7ca') {
                if (gcat !== 'b11de40f-5516-490c-bf92-9d4e69430247' || gcat !== 'b11de40f-5516-490c-bf92-9d4e69430247') {
                    jq().toastmessage('showErrorToast', "Check Weight and Growth Status Combinations!");
                    return false;
                }
            }

            if (wcat === '114413AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' || wcat === '115115AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA') {
                if (gcat === 'ab430762-6c89-4a9c-8c2d-bb6d6d3843e5') {
                    jq().toastmessage('showErrorToast', "Check Weight and Growth Status Combinations!");
                    return false;
                }
            }

            //validate weight, height and muac to ensure they are provided
            var wValue = jq('#weight').val();
            var hValue = jq('#height').val();
            var muacValue = jq('.muacs').val();

            if(!(parseInt(wValue) > 0) || !(parseInt(hValue) > 0) || !(parseInt(muacValue) > 0) ){
                jq().toastmessage('showErrorToast', "Check values for height, weight and muac!");
                return false;
            }
			
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
                    "json"
            );
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
                    <input type="hidden" name="patientEnrollmentDate"
                           value="${patientProgram ? patientProgram.dateEnrolled : "--"}">

                    <div>
                        <label for="weight">Weight</label>
                        <input type="text" id="weight"
                               name="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
                        <span class="append-to-value">Kgs</span>
                    </div>

                    <div>
                        <label for="weightCategories">Weight Categories</label>
                        <select id="weightCategories" name="concept.1854AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">
                            <option value="0">Select Category</option>
                            <% weightCategories.each { category -> %>
                            <option value="${category.uuid}">${category.label}</option>
                            <% } %>
                        </select>
                    </div>

                    <div>
                        <label for="height">Height</label>
                        <input type="text" id="height"
                               name="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
                        <span class="append-to-value">Cms</span>
                    </div>

                    <div>
                        <label for="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6">M.U.A.C</label>
                        <input id="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6" name="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6" class="muacs number numeric-range focused"
                               type="text"
                               max="999" min="0" maxlength="7" value=""
                               >
                        <span class="append-to-value">Cms</span>
                    </div>
					
                    <div>
                        <label for="growthMonitor">Growth Status</label>
                        <select id="growthMonitor" name="concept.562a6c3e-519b-4a50-81be-76ca67b5d5ec">
                            <option value="0">Select Category</option>
                            <% growthCategories.each { category -> %>
                            <option value="${category.uuid}">${category.label}</option>
                            <% } %>
                        </select>
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