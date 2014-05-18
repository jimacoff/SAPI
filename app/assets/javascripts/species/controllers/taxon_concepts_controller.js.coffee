Species.TaxonConceptsController = Ember.ArrayController.extend Species.TaxonConceptPagination,
  needs: ['search', 'taxonConceptLink']

  taxonConceptsByHigherTaxon: ( ->
    return [] unless @get('content.meta.higher_taxa_headers')
    @get('content.meta.higher_taxa_headers').map (h) ->
      higher_taxon: h.higher_taxon
      ancestors_path: h.higher_taxon.ancestors_path.split(',')
      taxon_concepts: h.taxon_concept_ids.map (tc_id) ->
        Species.TaxonConcept.find(tc_id)
  ).property('content.meta.higher_taxa_headers')

  openTaxonPage: (taxonConceptId, redirected) ->
    if redirected != undefined && redirected == true
      @get('controllers.search').set('redirected', true)
    else
      @get('controllers.search').set('redirected', false)
    m = Species.TaxonConcept.find(taxonConceptId)
    @transitionToRoute('taxonConcept.legal', m, queryParams: false)

  actions:
    openTaxonPage: (taxonConceptId, redirected) ->
      @openTaxonPage(taxonConceptId, redirected)

    nextPage: ->
      @get("controllers.search").openSearchPage undefined, @get('page') + 1, @get('perPage')

    prevPage: ->
      @get("controllers.search").openSearchPage undefined, @get('page') - 1, @get('perPage')
