Trade.AnnualReportUploadController = Ember.ObjectController.extend
  needs: ['geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  visibleShipments: []
  currentShipment: null
  currentCountryOfOriginId: null
  filtersSelected: false

  columns: [
    'appendix', 'speciesName',
    'termCode', 'quantity',  'unitCode',
    'tradingPartner', 'countryOfOrigin',
    'importPermit', 'exportPermit', 'originPermit',
    'purposeCode', 'sourceCode', 'year'
  ]
  codeMappings: {}
  allAppendices: [
    Ember.Object.create({id: 'I', name: 'Appendix I'}),
    Ember.Object.create({id: 'II', name: 'Appendix II'}),
    Ember.Object.create({id: 'III', name: 'Appendix III'})
  ]
  allReporterTypeValues: ['E', 'I']

  #sandboxShipmentsController: null

  #tableController: Ember.computed ->
  #  controller = Ember.get('Trade.SandboxShipmentsTable.TableController').create()
  #  controller.set('annualReportUploadController', @)
  #  controller
  #.property('sandboxShipmentsLoaded')

  sandboxShipmentsDidLoad: ( ->
    @set('visibleShipments', @get('content.sandboxShipments'))
    @set('sandboxShipmentsLoaded', true)
    #@sandboxShipmentsController = Ember.get('Trade.SandboxShipmentsController').create()
    #@sandboxShipmentsController.set('visibleShipments', @get('visibleShipments'))
  ).observes('content.sanboxShipments.@each.didLoad')

  #currentShipmentIsEdited: ( ->
  #  console.log 'JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ'
  #  @set('visibleShipments', @get('content.sandboxShipments'))
  #).observes('currentShipment')

  sandboxShipmentsSaving: ( ->
    @get('content.isSaving')
  ).property('content.isSaving')
  sandboxShipmentsSubmitting: false

  unsavedChanges: (->
    @get('changedRowsCount') > 0
  ).property('changedRowsCount')

  changedRowsCount: (->
    @get('content.sandboxShipments').filterBy('_modified', true).length
  ).property('content.sandboxShipments.@each._modified')

  visibleShipmentsCount: (->
    @get('visibleShipments.length')
  ).property('visibleShipments')

  allValuesFor: (attr) ->
    @get('content.sandboxShipments').mapBy(attr).compact().uniq()

  allAppendixValues: (->
    @allValuesFor('appendix')
  ).property('content.sandboxShipments.@each.appendix')
  selectedAppendixValues: []
  blankAppendix: false
  allSpeciesNameValues: (->
    @allValuesFor('speciesName')
  ).property('content.sandboxShipments.@each.speciesName')
  selectedSpeciesNameValues: []
  blankSpeciesName: false
  allTermCodeValues: (->
    @allValuesFor('termCode')
  ).property('content.sandboxShipments.@each.termCode')
  selectedTermCodeValues: []
  blankTermCode: false
  allQuantityValues: (->
    @allValuesFor('quantity')
  ).property('content.sandboxShipments.@each.quantity')
  selectedQuantityValues: []
  blankQuantity: false
  allUnitCodeValues: (->
    @allValuesFor('unitCode')
  ).property('content.sandboxShipments.@each.unitCode')
  selectedUnitCodeValues: []
  blankUnitCode: false
  allTradingPartnerValues: (->
    @allValuesFor('tradingPartner')
  ).property('content.sandboxShipments.@each.tradingPartner')
  selectedTradingPartnerValues: []
  blankTradingPartner: false
  allCountryOfOriginValues: (->
    @allValuesFor('countryOfOrigin')
  ).property('content.sandboxShipments.@each.countryOfOrigin')
  selectedCountryOfOriginValues: []
  blankCountryOfOrigin: false
  allImportPermitValues: (->
    @allValuesFor('importPermit')
  ).property('content.sandboxShipments.@each.importPermit')
  selectedImportPermitValues: []
  blankImportPermit: false
  allExportPermitValues: (->
    @allValuesFor('exportPermit')
  ).property('content.sandboxShipments.@each.exportPermit')
  selectedExportPermitValues: []
  blankExportPermit: false
  allOriginPermitValues: (->
    @allValuesFor('originPermit')
  ).property('content.sandboxShipments.@each.originPermit')
  selectedOriginPermitValues: []
  blankOriginPermit: false
  allPurposeCodeValues: (->
    @allValuesFor('purposeCode')
  ).property('content.sandboxShipments.@each.purposeCode')
  selectedPurposeCodeValues: []
  blankPurposeCode: false
  allSourceCodeValues: (->
    @allValuesFor('sourceCode')
  ).property('content.sandboxShipments.@each.sourceCode')
  selectedSourceCodeValues: []
  blankSourceCode: false
  allYearValues: (->
    @allValuesFor('year')
  ).property('content.sandboxShipments.@each.year')
  selectedYearValues: []
  blankYear: false

  filtersVisible: true
  updatesVisible: ( ->
    !@get('filtersVisible')
  ).property('filtersVisible')

  selectedAppendixChanged: ( ->
    @applyFilter('appendix')
  ).observes('selectedAppendixValues.@each', 'blankAppendix')

  selectedSpeciesNameChanged: ( ->
    @applyFilter('speciesName')
  ).observes('selectedSpeciesNameValues.@each', 'blankSpeciesName')

  selectedTermCodeChanged: ( ->
    @applyFilter('termCode')
  ).observes('selectedTermCodeValues.@each', 'blankTermCode')

  selectedQuantityChanged: ( ->
    @applyFilter('quantity')
  ).observes('selectedQuantityValues.@each', 'blankQuantity')

  selectedUnitCodeChanged: ( ->
    @applyFilter('unitCode')
  ).observes('selectedUnitCodeValues.@each', 'blankUnitCode')

  selectedTradingPartnerChanged: ( ->
    @applyFilter('tradingPartner')
  ).observes('selectedTradingPartnerValues.@each', 'blankTradingPartner')

  selectedCountryOfOriginChanged: ( ->
    @applyFilter('countryOfOrigin')
  ).observes('selectedCountryOfOriginValues.@each', 'blankCountryOfOrigin')

  selectedImportPermitChanged: ( ->
    @applyFilter('importPermit')
  ).observes('selectedImportPermitValues.@each', 'blankImportPermit')

  selectedExportPermitChanged: ( ->
    @applyFilter('exportPermit')
  ).observes('selectedExportPermitValues.@each', 'blankExportPermit')

  selectedOriginPermitChanged: ( ->
    @applyFilter('originPermit')
  ).observes('selectedOriginPermitValues.@each', 'blankOriginPermit')

  selectedPurposeCodeChanged: ( ->
    @applyFilter('purposeCode')
  ).observes('selectedPurposeCodeValues.@each', 'blankPurposeCode')

  selectedSourceCodeChanged: ( ->
    @applyFilter('sourceCode')
  ).observes('selectedSourceCodeValues.@each', 'blankSourceCode')

  selectedYearChanged: ( ->
    @applyFilter('year')
  ).observes('selectedYearValues.@each', 'blankYear')

  applyFilter: (columnName) ->
    capitalisedColumnName = @capitaliseFirstLetter(columnName)
    selectedValuesName = 'selected' + capitalisedColumnName + 'Values'
    blankValue = 'blank' + capitalisedColumnName
    if @get(selectedValuesName + '.length') > 0 || @get(blankValue)
      @set('filtersSelected', true)
      shipments = @get('visibleShipments').filter((element) =>
        value = element.get(columnName)
        return @get(selectedValuesName).contains(value) ||
          # check if null, undefined or blank
          @get(blankValue) && (!value || /^\s*$/.test(value))
      )
      @set('visibleShipments', shipments)

  # used
  resetFilters: ->
    @beginPropertyChanges()
    @get('columns').forEach (columnName) =>
      selectedValuesName = 'selected' + @capitaliseFirstLetter(columnName) + 'Values'
      @set(selectedValuesName, [])
      blankValueName = 'blank' + @capitaliseFirstLetter(columnName)
      @set(blankValueName, false)
    @set('visibleShipments', @get('content.sandboxShipments'))
    @set('filtersSelected', false)
    @endPropertyChanges()

  capitaliseFirstLetter: (string) ->
    string.charAt(0).toUpperCase() + string.slice(1)

  clearModifiedFlags: ->
    @beginPropertyChanges()
    @get('content.sandboxShipments').forEach (shipment) ->
      shipment.set('_modified', false)
    @endPropertyChanges()

  columnNames: ( ->
    @get('tableController.columnNames')
  ).property('tableController.columnNames')

  actions:

    editShipment: (shipment) ->
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    updateShipment: (shipment) ->
      $('.shipment-form-modal').modal('hide')


    cancelShipment: ->


    submitShipments: ()->
      if @get('content.isDirty')
        alert "You have unsaved changes, please save those before submitting your shipments"
      else if @get('content.hasPrimaryErrors')
        alert "Primary errors detected, cannot submit shipments"
      else
        @set('sandboxShipmentsSubmitting', true)
        $.post '/trade/annual_report_uploads/'+@get('id')+'/submit', {}, (data) ->
          'json'
        .success( =>
          @set('sandboxShipmentsSubmitting', false)
          @transitionToRoute('shipments', {queryParams:
            page: 1
          })
        )
        .error( (xhr, msg, error) =>
          @set('sandboxShipmentsSubmitting', false)
          console.log "bad luck: ", xhr.responseText
        )

    setFiltersFromErrorSelector: (errorSelector) ->
      @resetFilters()
      @beginPropertyChanges()
      for errorColumn, errorValue of errorSelector
        capitalisedColumnName = (errorColumn.split(/_/).map (word) -> word[0].toUpperCase() + word[1..-1].toLowerCase()).join ''
        selectedValuesName = 'selected' + capitalisedColumnName + 'Values'
        if errorValue == null
          blankValueName = 'blank'  + capitalisedColumnName
          @set(blankValueName, true)
        else if typeof errorValue == 'object'
          @set(selectedValuesName, errorValue)
        else
          @set(selectedValuesName, [errorValue])
      @set('filtersVisible', false)
      @endPropertyChanges()

    saveChanges: () ->
      @get('store').commit()
      @transitionToRoute('annual_report_upload', @get('content'))
      @clearModifiedFlags()
      @resetFilters()

    cancelChanges: () ->
      if (!@get('content').get('isSaving'))
        @get('content').get('transaction').rollback()
        @clearModifiedFlags()

    resetFilters: () ->
      @resetFilters()

    deleteSelection: () ->
      @beginPropertyChanges()
      @get('visibleShipments').forEach (shipment) ->
        shipment.setProperties({'_destroyed': true, '_modified': true})
      @endPropertyChanges()
      @resetFilters()

    updateSelection: () ->
      valuesToUpdate = {'_modified': true}
      @get('columnNames').forEach (columnName) =>
        el = $('.sandbox-form').find('input[type=text][name=' + columnName + ']')
        blank = $('.sandbox-form').find('input[type=checkbox][name=' + columnName + ']:checked')
        valuesToUpdate[columnName] = el.val() if el && el.val()
        valuesToUpdate[columnName] = null if blank.length > 0
      @beginPropertyChanges()
      @get('visibleShipments').forEach (shipment) ->
        shipment.setProperties(valuesToUpdate)
      @endPropertyChanges()
      $('.sandbox-form').find('input[type=text]').val('')
      $('.sandbox-form').find('input[type=checkbox]').attr('checked', false)
      @resetFilters()

    selectForUpdate: () ->
      @set('filtersVisible', false)

    cancelSelectForUpdate: () ->
      $('.sandbox-form').find('input[type=text]').val(null)
      @set('filtersVisible', true)
