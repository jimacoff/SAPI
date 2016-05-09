Species.DocumentLoader = Ember.Mixin.create
  euSrgDocuments: {}
  citesCopProposalsDocuments: {}
  citesAcDocuments: {}
  citesPcDocuments: {}
  otherDocuments: {}

  euSrgDocsIsLoading: true
  citesCopProposalsDocsIsLoading: true
  citesAcDocsIsLoading: true
  citesPcDocsIsLoading: true
  otherDocsIsLoading: true

  euSrgDocsTotal: ( ->
    @get('euSrgDocuments.meta.total')
  ).property('euSrgDocuments.meta.total')
  euSrgDocsPresent: ( ->
    @get('euSrgDocsTotal') > 0
  ).property('euSrgDocsTotal')
  euSrgDocsLoadMore: ( ->
    @get('euSrgDocuments.docs.length') < @get('euSrgDocsTotal')
  ).property('euSrgDocuments.docs.length', 'euSrgDocsTotal')

  citesCopProposalsDocsTotal: ( ->
    @get('citesCopProposalsDocuments.meta.total')
  ).property('citesCopProposalsDocuments.meta.total')
  citesCopProposalsDocsPresent: ( ->
    @get('citesCopProposalsDocsTotal') > 0
  ).property('citesCopProposalsDocsTotal')
  citesCopProposalsDocsLoadMore: ( ->
    @get('citesCopProposalsDocuments.docs.length') < @get('citesCopProposalsDocsTotal')
  ).property('citesCopProposalsDocuments.docs.length', 'citesCopProposalsDocsTotal')

  citesAcDocsTotal: ( ->
    @get('citesAcDocuments.meta.total')
  ).property('citesAcDocuments.meta.total')
  citesAcDocsPresent: ( ->
    @get('citesAcDocsTotal') > 0
  ).property('citesAcDocsTotal')
  citesAcDocsLoadMore: ( ->
    @get('citesAcDocuments.docs.length') < @get('citesAcDocsTotal')
  ).property('citesAcDocuments.docs.length', 'citesAcDocsTotal')

  citesPcDocsTotal: ( ->
    @get('citesPcDocuments.meta.total')
  ).property('citesPcDocuments.meta.total')
  citesPcDocsPresent: ( ->
    @get('citesPcDocsTotal') > 0
  ).property('citesPcDocsTotal')
  citesPcDocsLoadMore: ( ->
    @get('citesPcDocuments.docs.length') < @get('citesPcDocsTotal')
  ).property('citesPcDocuments.docs.length', 'citesPcDocsTotal')

  otherDocsTotal: ( ->
    @get('otherDocuments.meta.total')
  ).property('otherDocuments.meta.total')
  otherDocsPresent: ( ->
    @get('otherDocsTotal') > 0
  ).property('otherDocsTotal')
  otherDocsLoadMore: ( ->
    @get('otherDocuments.docs.length') < @get('otherDocsTotal')
  ).property('otherDocuments.docs.length', 'otherDocsTotal')

  euSrgDocsObserver: ( ->
    @set('euSrgDocsIsLoading', false)
  ).observes('euSrgDocuments.docs.@each.didLoad')

  citesCopProposalsDocsObserver: ( ->
    @set('citesCopProposalsDocsIsLoading', false)
  ).observes('citesCopProposalsDocuments.docs.@each.didLoad')

  citesAcDocsObserver: ( ->
    @set('citesAcDocsIsLoading', false)
  ).observes('citesAcDocuments.docs.@each.didLoad')

  citesPcDocsObserver: ( ->
    @set('citesPcDocsIsLoading', false)
  ).observes('citesPcDocuments.docs.@each.didLoad')

  citesOtherDocsObserver: ( ->
    @set('otherDocsIsLoading', false)
  ).observes('otherDocuments.docs.@each.didLoad')

  loadDocuments: (params, onSuccess) =>
    $.ajax(
      url: "/api/v1/documents",
      data: params,
      success: (data) ->
        tmp = {
          docs: data.documents,
          meta: data.meta
        }
        onSuccess.call @, tmp
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("AJAX Error:" + textStatus)
    )

  getSearchParams: (eventType) ->
    if @get('searchContext') == 'documents'
      params = @get('controllers.elibrarySearch').getFilters()
    else
      params = {
        taxon_concepts_ids: [@get('controllers.taxonConcept.id')],
      }
    params['event_type'] = eventType
    params

  getEventTypeKey: (eventType) ->
    key = switch eventType
      when 'CitesCop' then 'CitesCopProposals'
      when 'CitesAc', 'CitesTc', 'CitesAc,CitesTc' then 'CitesAc'
      when 'CitesPc' then 'CitesPc'
      when 'EcSrg' then 'EuSrg'
      else 'Other'

  actions:
    loadMoreDocuments: (eventType) ->
      params = @getSearchParams(eventType)
      contextKey = @getEventTypeKey(eventType).camelize() + 'Documents'
      params['page'] = @get(contextKey + '.meta.page') + 1
      @loadDocuments(params, (documents) =>
        docsKey = contextKey + '.docs'
        docs = @get(docsKey).pushObjects(documents.docs)
        metaKey = contextKey + '.meta'
        @set(metaKey, documents.meta)
      )
