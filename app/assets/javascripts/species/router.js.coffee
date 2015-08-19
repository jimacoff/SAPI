Species.Router.map (match) ->
  @resource 'taxonConcepts', {
    path: "/taxon_concepts"
    queryParams: ['taxonomy', 'taxon_concept_query', 'geo_entities_ids', 'geo_entity_scope', 'page']
    }, () ->
  @resource 'taxonConcept', { path: "/taxon_concepts/:taxon_concept_id" }, () ->
    @route 'legal'
    @route 'names'
    @route 'distribution'
    @route 'references'
    @route 'documents'
  @route 'elibrary'
  @resource 'documents', {
    queryParams: [
      'taxon_concept_query', 'geo_entities_ids', 'title_query',
      'event_type', 'event_id', 'document_type',
      'proposal_outcome_id', 'review_phase_id'
    ]
  }
  @route 'about'

Species.Router.reopen
  didTransition: (infos) ->
    @_super(infos);

    if window.ga
      Em.run.next ->
        ga('send', 'pageview', {
           'page': window.location.hash,
           'title': window.location.hash
        })
    return unless window._gaq
    Em.run.next ->
      _gaq.push(['_trackPageview', window.location.hash])
