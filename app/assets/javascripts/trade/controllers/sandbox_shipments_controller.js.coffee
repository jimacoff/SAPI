Trade.SandboxShipmentsController = Ember.ArrayController.extend Trade.ShipmentPagination,
  needs: ['annualReportUpload', 'geoEntities', 'terms', 'units', 'sources', 'purposes']
  content: null
  updatesVisible: false
  currentShipment: null
  errorParams: null
  sandboxShipmentsSaving: false # FIXME

  columns: [
    'appendix', 'speciesName',
    'termCode', 'quantity',  'unitCode',
    'tradingPartner', 'countryOfOrigin',
    'importPermit', 'exportPermit', 'originPermit',
    'purposeCode', 'sourceCode', 'year'
  ]

  allAppendices: [
    Ember.Object.create({id: 'I', name: 'I'}),
    Ember.Object.create({id: 'II', name: 'II'}),
    Ember.Object.create({id: 'III', name: 'III'}),
    Ember.Object.create({id: 'N', name: 'N'})
  ]

  # FIXME !!!
  #sandboxShipmentsSaving: ( ->
  #  @get('content.isSaving')
  #).property('content.isSaving')

  transitionToPage: (forward) ->
    page = if forward
      parseInt(@get('page')) + 1
    else
      parseInt(@get('page')) - 1
    @openShipmentsPage {page: page}

  openShipmentsPage: (params) ->
    queryParams = $.extend({}, @errorParams, params)
    @transitionToRoute('sandbox_shipments', 'queryParams': queryParams)

  clearModifiedFlags: ->
    @beginPropertyChanges()
    @get('content').forEach (shipment) ->
      shipment.set('_modified', false)
    @endPropertyChanges()

  actions:

    toggleUpdatesVisible: ->
      @toggleProperty 'updatesVisible'
      # not returning false here would cause the action to bubble 
      # to the parent controller up the nested routing!
      false

    # Batch edits on the selected error
    updateSelection: () ->
      valuesToUpdate = {}
      annualReportUploadId = @get('controllers.annualReportUpload.id')
      @get('columns').forEach (columnName) =>
        el = $('.sandbox-form').find("input[type=text][name=#{columnName}]")
        blank = $('.sandbox-form')
          .find("input[type=checkbox][name=#{columnName}]:checked")
        valuesToUpdate[columnName] = el.val() if el && el.val()
        valuesToUpdate[columnName] = null if blank.length > 0 
      $.when($.ajax({
        url: "trade/annual_report_uploads/#{annualReportUploadId}/sandbox_shipments"
        type: "PUT"
        data: {filters: @errorParams, updates: valuesToUpdate}
      })).then( 
        @transitionToRoute('annual_report_upload', annualReportUploadId), 
        console.log arguments
      )

    cancelSelectForUpdate: () ->
      $('.sandbox-form').find('input[type=text]').val(null)

    #### Save and cancel changes made on shipments table ####

    saveChanges: () ->
      @get('store').commit()
      @clearModifiedFlags()

    cancelChanges: () ->
      @get('store').get('currentTransaction').rollback()
      @clearModifiedFlags()

    #### Single shipment related ####

    editShipment: (shipment) ->
      @set('currentShipment', shipment)
      $('.shipment-form-modal').modal('show')

    updateShipment: (shipment) ->
      shipment.setProperties({'_modified': true})
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')

    deleteShipment: (shipment) ->
      shipment.setProperties({'_destroyed': true, '_modified': true})

    cancelShipmentEdit: (shipment) ->
      shipment.setProperties(shipment.get('data'))
      @set('currentShipment', null)
      $('.shipment-form-modal').modal('hide')

  
