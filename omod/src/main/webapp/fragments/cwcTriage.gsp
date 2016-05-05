<script>
    jq(function(){
        jq('#availableReferral').change(function(){
            if (jq(this).val() == 0){
                jq('#internalReferral').hide();
                jq('#externalReferral').hide();
            }
            else if (jq(this).val() == 1){
                jq('#internalReferral').show();
                jq('#externalReferral').hide();
            }
            else {
                jq('#internalReferral').hide();
                jq('#externalReferral').show();
            }
        }).change();
    });

</script>

<form>
    <div>
        <label for="Weight">Weight</label>
        <input type="text" id="Weight" />
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
        <label for="Height">Height</label>
        <input type="text" id="Height" />
    </div>
    <div>
        <label for="Stunted">Stunted</label>
        <select id="Stunted">
            <option value="Yes">Yes</option>
            <option value="No">No</option>
        </select>
    </div>

    <div>
        <label for="muac-field">M.U.A.C</label>
        <p>
            <input id="muac-field" class="number numeric-range focused" type="text" max="999" min="0" maxlength="7" value="" name="triagePatientData.mua">
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
            <select id="toWhere" name="toWhere"  style="margin-top: 5px;">
                <% if (internalReferralSources != null || internalReferralSources != "") { %>
                    <% internalReferralSources.each { referTo -> %>
                         <option>${referTo.label}</option>
                    <% } %>
                <% } %>
            </select>
        </div>
    </div>
    <div>
        <input type="button" value="Submit" class="button confirm" id="cwcTriageButton">
    </div>

</form>