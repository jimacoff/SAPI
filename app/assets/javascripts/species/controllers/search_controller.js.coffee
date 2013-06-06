Species.locations = [Ember.Object.create(
  name: "Africa"
  id: 1
), Ember.Object.create(
  name: "Europe"
  id: 2
)]


Species.SearchController = Ember.Controller.extend
  taxonomy: 'cites_eu'
  scientificName: null
  location: null

  loadTaxonConcepts: ->
    #TODO handle locations
    @transitionToRoute('search', {
      taxonomy: @get('taxonomy'),
      scientific_name: @get('scientificName')
    })
