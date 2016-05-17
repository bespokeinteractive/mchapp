<script>
    jq(function(){

        jq("#availableReferral").on("change", function (){
            selectReferrals(jq( "#availableReferral" ).val());
        });
    });
    function selectReferrals(selectedReferral){
        //1 = internal referral
        //2 = external referral
        if(selectedReferral == 1){
            jq("#externalRefferalDiv").hide();
            jq("#internalRefferalDiv").show();
        }else if(selectedReferral == 2){
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").show();
        }
        else{
            jq("#internalRefferalDiv").hide();
            jq("#externalRefferalDiv").hide();
        }
    }
</script>



<div>
    <fieldset>
        <legend>Examinations</legend>

    </fieldset>
</div>
<br>

<h2> Prescribe Drugs</h2>

<table id="addDrugsTable">
    <thead>
    <tr>
        <th>Drug Name</th>
        <th>Dosage</th>
        <th>Formulation</th>
        <th>Frequency</th>
        <th>Days</th>
        <th>Comments</th>
        <th></th>
    </tr>
    </thead>
    <tbody ></tbody>
</table>

<div style="margin-top:5px">
    <input class="button confirm" type="button" id="Prescribe" name="Prescribe" value="Add">
</div>

<br>

<div>
    <h2> Patient Referral</h2>
    <select id="availableReferral" name="availableReferral">
        <option value="0">Select Option</option>
        <option value="1">Internal Referral</option>
        <option value="2">External Referral</option>
    </select>
</div>
<div id="internalRefferalDiv" style="display: none">
    <h2> Internal Referral</h2>
    <select id="internalRefferal" name="">
        <option value="0">Select Option</option>
        <% if (internalReferrals != null || internalReferrals != "") { %>
            <% internalReferrals.each { internalReferral -> %>
            <option ${internalReferral.id} >${internalReferral.label}</option>
            <% } %>
        <% } %>
    </select>
</div>

<div id="externalRefferalDiv" style="display: none">
    <h2> External Referral</h2>
    <select id="externalRefferal" name="">
        <option value="0">Select Option</option>
        <% if (externalReferrals != null || externalReferrals != "") { %>
            <% externalReferrals.each { externalReferral -> %>
                <option ${externalReferral.id} >${externalReferral.label}</option>
            <% } %>
        <% } %>
    </select>

    <h2>Facility</h2>
    <input type="text" id="referralFacility" name="">

    <h2>Referral Reason</h2>
    <select id="referralReason" name="">
        <option value="0">Select Option</option>
        <% if (referralReasons != null || referralReasons != "") { %>
            <% referralReasons.each { referralReason -> %>
                <option ${referralReason.id} >${referralReason.label}</option>
            <% } %>
        <% } %>
    </select>

    <h2>Comment</h2>
    <textarea></textarea>
</div>


<div id="prescription-dialog" class="dialog" style="display:none;">
    <div class="dialog-header">
        <i class="icon-folder-open"></i>

        <h3>Prescription</h3>
    </div>

    <div class="dialog-content">
        <ul>
            <li>
                <label>Drug</label>
                <input class="drug-name" type="text">
            </li>
            <li>
                <label>Dosage</label>
                <input type="text"  style="width: 60px!important;">
                <select id="dosage-unit" style="width: 191px!important;"></select>
            </li>

            <li>
                <label>Formulation</label>
                <select ></select>
            </li>
            <li>
                <label>Frequency</label>
                <select></select>
            </li>

            <li>
                <label>Number of Days</label>
                <input type="text">
            </li>
            <li>
                <label>Comment</label>
                <textarea></textarea>
            </li>
        </ul>

        <label class="button confirm right">Confirm</label>
        <label class="button cancel">Cancel</label>
    </div>
</div>

