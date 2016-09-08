<div class="info-header">
    <i class="icon-user-md"></i>
    <h3>ANTENATAL DETAILS</h3>
</div>

<div class="info-body" style="margin-bottom: 20px; padding-bottom: 10px;">
    <div>
        <label for="parity">Parity</label>
        <input type="text" name="concept.1053AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="parity" />
        <span class="append-to-value">Pregnancies</span>
    </div>

    <div>
        <label for="gravidae">Gravida</label>
        <input type="text" name="concept.5624AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" id="gravida" />
        <span class="append-to-value">Pregnancies</span>
    </div>

    <div>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '1427AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: 'L.M.P', useTime: false, defaultToday: false, endDate: new Date(), class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
    </div>

    <div>
        ${ui.includeFragment("uicommons", "field/datetimepicker", [formFieldName: 'concept.5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', id: '5596AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', label: 'E.D.D', useTime: false, defaultToday: false, class: ['searchFieldChange', 'date-pick', 'searchFieldBlur']])}
    </div>

    <div>
        <label for="gestation">Gestation</label>
        <input type="text" id="gestation">
        <span class="append-to-value">Weeks</span>
    </div>
</div>
