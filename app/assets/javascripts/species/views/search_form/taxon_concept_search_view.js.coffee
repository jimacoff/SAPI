Species.TaxonConceptSearchView = Em.View.extend
  templateName: 'species/taxon_concept_search'
  
  mousedOver: false

  mouseEnter: (event) ->
    @set('mousedOver', true)

  mouseLeave: (event) ->
    @set('mousedOver', false)

  hideDropdown: () ->
    $('.search fieldset').removeClass('parent-focus parent-active')

  showDropdown: () ->
    $('.search fieldset').addClass('parent-focus parent-active')

  actions:
    handleTaxonConceptSearchSelection: (autoCompleteTaxonConcept) ->
      @hideDropdown()
      # auto bubbling didn't seem to work, so bubble to controller manually for now
      @get('controller').send('handleTaxonConceptSearchSelection', autoCompleteTaxonConcept)
      false
