Species.IndexRoute = Ember.Route.extend

  renderTemplate: ->
    # Render the `index` template into
    # the default outlet, and display the `index`
    # controller.
    @render('index', {
      into: 'application',
      outlet: 'main',
      controller: @controllerFor('index')
    })
    # Render the `search_form` template into
    # the outlet `search`, and display the `search`
    # controller.
    @render('searchForm', {
      into: 'index',
      outlet: 'search',
      controller: @controllerFor('search')
    })

    @render('downloads', {
      into: 'application',
      outlet: 'downloads',
      controller: @controllerFor('downloads')
    })
    @render('downloadsButton', {
      into: 'index',
      outlet: 'downloadsButton',
      controller: @controllerFor('downloads')
    })

  events:
    ensureGeoEntitiesLoaded: ->
      @controllerFor('geoEntities').load()

    ensureHigherTaxaLoaded: ->
      @controllerFor('higherTaxaCitesEu').load()
      @controllerFor('higherTaxaCms').load()
