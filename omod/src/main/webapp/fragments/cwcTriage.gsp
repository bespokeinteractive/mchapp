<script>
    jq(function () {
        jq('#availableReferral').change(function () {
            if (jq(this).val() == 0) {
                jq('#internalReferral').hide();
                jq('#externalReferral').hide();
            }
            else if (jq(this).val() == 1) {
                jq('#internalReferral').show();
                jq('#externalReferral').hide();
            }
            else {
                jq('#internalReferral').hide();
                jq('#externalReferral').show();
            }
        }).change();


        //submit data
        jq(".submit").on("click", function (event) {
            event.preventDefault();
            var data = jq("form#cwc-triage-form").serialize();

            jq.post(
                    '${ui.actionLink("mchapp", "cwcTriage", "saveCwcTriageInfo")}',
                    data,
                    function (data) {
                        if (data.status === "success") {
                            //show success message
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

<div class="dashboard clear">
    <div class="info-section">
        <div class="info-header">
            <i class="icon-calendar"></i>

            <h3>CHILD WELFARE CLINIC PROGRAM</h3>
        </div>
    </div>
</div>

<form id="cwc-triage-form">
    <input type="hidden" name="patientId" value="${patientId}" >
    <div>
        <label for="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Weight</label>
        <input type="text" id="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
               name="concept.5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
    </div>

    <div>
        <label for="weightCategories">Weight Categories</label>
        <select id="weightCategories">
            <option value="stunted">stunted</option>
            <option value="Over Weight">Over Weight</option>
            <option value="Under Weight">Under Weight</option>
        </select>
    </div>

    <div>
        <label for="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA">Height</label>
        <input type="text" id="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
               name="concept.5090AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"/>
    </div>

    <div>
        <label for="Stunted">Stunted</label>
        <select id="Stunted">
            <option value="Yes">Yes</option>
            <option value="No">No</option>
        </select>
    </div>

    <div>
        <label for="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6">M.U.A.C</label>

        <p>
            <input id="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6" class="number numeric-range focused" type="text"
                   max="999" min="0" maxlength="7" value="" name="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6"
                   id="concept.b7112b6c-de10-42ee-b54d-2e1be98cd2d6">
            <span class="append-to-value">cm</span>
            <span id="fr801" class="field-error" style="display: none"></span>
        </p>
    </div>

    <div class="onerow">
        <div class="col4">
            <div class="input-position-class">
                <select id="availableReferral" name="availableReferral">
                    <option value="0">Select Option</option>
                    <option value="1">Internal Referral</option>
                </select>
            </div>
        </div>
    </div>

    <div class="onerow" style="padding-top:2px;" id="internalReferral">
        <div class="col4">
            <select id="toWhere" name="toWhere" style="margin-top: 5px;">
                <% if (internalReferralSources != null || internalReferralSources != "") { %>
                <% internalReferralSources.each { referTo -> %>
                <option>${referTo.label}</option>
                <% } %>
                <% } %>
            </select>
        </div>
    </div>

    <div>
        <input type="button" value="Submit" class="button submit confirm" id="cwcTriageButton">
    </div>

</form>