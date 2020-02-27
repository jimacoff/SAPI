Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner,
  Species.SearchContext,
  Species.TaxonConceptAutoCompleteLookup,
  Species.GeoEntityAutoCompleteLookup,
  Species.EventLookup,
  Species.DocumentTagLookup,
  Species.SignedInStatus,
  needs: ['documentGeoEntities', 'taxonConcepts', 'events', 'documentTags']
  geoEntities: Ember.computed.alias("controllers.documentGeoEntities")
  searchContext: 'documents'
  autoCompleteTaxonConcept: null
  selectedEventType: null
  selectedGeneralSubType: null
  locationsDropdownVisible: true

  setFilters: (filtersHash) ->
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])
    if filtersHash.title_query == ''
      filtersHash.title_query = null
    @set('titleQuery', filtersHash.title_query)

    allEventTypes = @get('controllers.events.eventTypes')
    allEventTypes.push(@get('controllers.events.idMaterialsEvent')) 

    @set('selectedEventType', allEventTypes.findBy('id', filtersHash.event_type))
    @set('selectedEventsIds', filtersHash.events_ids || [])

    allDocumentTypes = @get('controllers.events.documentTypes')
      .concat @get('controllers.events.interSessionalDocumentTypes')
      .concat @get('controllers.events.identificationDocumentTypes')
    
    @set('selectedDocumentType', allDocumentTypes.findBy('id', filtersHash.document_type))
    @set('selectedDocumentType', allDocumentTypes.findBy('id', filtersHash.document_type))

    @set('selectedGeneralSubType', 
      @get('controllers.events.generalSubTypes')
        .findBy('id', if filtersHash.general_subtype == 'true' then 'general' else 'parts'))

    @set('selectedReviewPhaseId', filtersHash.review_phase_id)

  getFilters: ->
    if @get('taxonConceptQueryForDisplay') && @get('taxonConceptQueryForDisplay').length > 0
      taxonConceptQuery = @get('taxonConceptQueryForDisplay')
    if @get('titleQuery') && @get('titleQuery').length > 0
      titleQuery = @get('titleQuery')
    if @get('selectedGeneralSubType')
      isGeneralSubType = (@get('selectedGeneralSubType.id') == 'general').toString()
    {
      taxon_concept_query: taxonConceptQuery,
      geo_entities_ids: @get('selectedGeoEntities').mapProperty('id'),
      title_query: titleQuery,
      event_type: @get('selectedEventType.id'),
      events_ids: @get('selectedEvents').mapProperty('id'),
      document_type: @get('selectedDocumentType.id'),
      proposal_outcome_id: @get('selectedProposalOutcome.id'),
      general_subtype: isGeneralSubType
    }

  filteredDocumentTypes: ( ->
    if @get('selectedEventType')
      @get('controllers.events.documentTypes').filter (dt) =>
        return false unless dt.eventTypes
        dt.eventTypes.indexOf(@get('selectedEventType.id')) >= 0
    else
      @get('controllers.events.documentTypes')
  ).property('selectedEventType.id')

  interSessionalDocumentTypes: ( ->
    nonPublicTypes = @get('controllers.events.interSessionalNonPublicDocumentTypes')
    publicTypes = @get('controllers.events.interSessionalDocumentTypes')
    if @get('isSignedIn')
      nonPublicTypes.pushObjects(publicTypes)
    else
      publicTypes
  ).property('isSignedIn')

  identificationDocumentTypes: ( ->
    @get('controllers.events.identificationDocumentTypes')
    ).property()

  generalSubTypes: ( ->
    @get('controllers.events.generalSubTypes')
  ).property()

  documentTypeDropdownVisible: ( ->
    @get('selectedEventType.id') == 'EcSrg'
  ).property('selectedEventType')

  meetingDocTypeDropdownVisible: ( ->
    @containsDocTypeOrDocTypeUnselected(@get('filteredDocumentTypes'))
  ).property('selectedDocumentType', 'filteredDocumentTypes')

  interSessionalDocTypeDropdownVisible: ( ->
    !@get('selectedEventType.id')? && @get('isDocTypeUnselectedOrIntersessional')
  ).property('selectedEventType', 'isDocTypeUnselectedOrIntersessional')

  identificationDocTypeDropdownVisible: ( ->
    @get('isEventTypeIdMaterials') || (!@get('selectedEventType')? && @get('isDocTypeUnselectedOrIdentification'))
  ).property('selectedEventType', 'isDocTypeUnselectedOrIdentification', 'isEventTypeIdMaterials')

  isDocTypeUnselectedOrIdentification: ( ->
    @containsDocTypeOrDocTypeUnselected(@get('identificationDocumentTypes'))
  ).property('selectedDocumentType', 'identificationDocumentTypes')

  isDocTypeUnselectedOrIntersessional: ( ->
    @containsDocTypeOrDocTypeUnselected(@get('interSessionalDocumentTypes'))
  ).property('selectedDocumentType', 'interSessionalDocumentTypes')

  containsDocTypeOrDocTypeUnselected: ((docTypes) ->
    selectedDocTypeId = @get('selectedDocumentType.id')

    if !selectedDocTypeId?
      return true

    contains = false
    docTypes.forEach((docType) -> 
      if (docType.id == selectedDocTypeId)
        contains = true
    )
    return contains
  )

  actions:
    openSearchPage:->
      @transitionToRoute('documents', {queryParams: @getFilters()})

    handleDocumentTypeSelection: (documentType) ->
      @set('selectedDocumentType', documentType)
      if @containsDocTypeOrDocTypeUnselected(@get('identificationDocumentTypes'))
        @handleEventTypeSelection(@get('controllers.events.idMaterialsEvent'))
        @set('locationsDropdownVisible', false)
        @set('selectedGeoEntities', [])
        @set('selectedGeoEntitiesIds', [])

    handleDocumentTypeDeselection: ->
      if @get('isEventTypeIdMaterials')
        @handleEventTypeDeselection(@get('controllers.events.idMaterialsEvent'))
      @set('selectedGeneralSubType', null)
      @set('selectedDocumentType', null)
      @set('locationsDropdownVisible', true)

    handleGeneralSubTypeSelection: (type) ->
      @set('selectedGeneralSubType', type)

    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)
      @set('taxonConceptQueryForDisplay', autoCompleteTaxonConcept.get('fullName'))

    clearSearch: ->
      @set('taxonConceptQueryForDisplay', '')
      @set('taxonConceptQuery', '')
      @set('selectedGeoEntities', [])
      @set('selectedGeoEntitiesIds', [])
      @set('titleQuery', '')
      @set('selectedEventType', null)
      @set('selectedEvents', [])
      @set('selectedEventsIds', [])
      @set('selectedDocumentType', null)
      @set('selectedInterSessionalDocType', null)
      @set('selectedProposalOutcome', null)
      @set('selectedGeneralSubType', null)
