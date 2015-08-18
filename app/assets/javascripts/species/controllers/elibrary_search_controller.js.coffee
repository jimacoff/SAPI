Species.ElibrarySearchController = Ember.Controller.extend Species.Spinner, Species.SearchContext, Species.TaxonConceptAutoCompleteLookup, Species.GeoEntityAutoCompleteLookup,
  needs: ['geoEntities', 'taxonConcepts', 'events']
  searchContext: 'documents'
  autoCompleteTaxonConcept: null
  selectedEventType: null
  selectedEvent: null

  setFilters: (filtersHash) ->
    if filtersHash.taxon_concept_query == ''
      filtersHash.taxon_concept_query = null
    @set('taxonConceptQueryForDisplay', filtersHash.taxon_concept_query)
    @set('taxonConceptQuery', filtersHash.taxon_concept_query)
    @set('selectedGeoEntitiesIds', filtersHash.geo_entities_ids || [])
    if filtersHash.title_query == ''
      filtersHash.title_query = null
    @set('titleQuery', filtersHash.title_query)

  filteredEvents: ( ->
    if @get('selectedEventType')
      @get('controllers.events.content').filterBy('type', @get('selectedEventType.id'))
    else
      []
  ).property('selectedEventType.id')

  eventsDropdownVisible: ( ->
    @get('selectedEventType') != null
  ).property('selectedEventType.id')

  actions:
    openSearchPage:->
      if @get('autoCompleteTaxonConcept') && @get('autoCompleteTaxonConcept.fullName') == @get('taxonConceptQueryForDisplay')
        query = @get('autoCompleteTaxonConcept.fullName')
      else
        query = @get('taxonConceptQueryForDisplay')
      @transitionToRoute('documents', {queryParams: {
        taxon_concept_query: query,
        geo_entities_ids: @get('selectedGeoEntities').mapProperty('id'),
        title_query: @get('titleQuery')
      }})

    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      @set('autoCompleteTaxonConcept', autoCompleteTaxonConcept)
      @set('taxonConceptQueryForDisplay', autoCompleteTaxonConcept.get('fullName'))

    handleEventTypeSelection: (eventType) ->
      @set('selectedEventType', eventType)

    handleEventTypeDeselection: (eventType) ->
      @set('selectedEventType', null)

    handleEventSelection: (event) ->
      @set('selectedEvent', event)

    handleEventDeselection: (event) ->
      @set('selectedEvent', null)
