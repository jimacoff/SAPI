$(document).ready ->
  defaultTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '300px'
    minimumInputLength: 3
    quietMillis: 500
    allowClear: true
    initSelection: (element, callback) =>
      id = $(element).val()
      if (id != null && id != '')
        callback({id: id, text: $(element).attr('data-name') + ' ' + $(element).attr('data-name-status')})

    ajax:
      url: '/admin/taxon_concepts/autocomplete'
      dataType: 'json'
      data: (query, page) ->
        search_params:
          scientific_name: query
          name_status: this.data('name-status-filter')
          taxonomy:
            id: this.data('taxonomy-id')
        per_page: 25
        page: 1
      results: (data, page) => # parse the results into the format expected by Select2.
        formatted_taxon_concepts = data.map (tc) =>
          id: tc.id
          text: tc.full_name + ' ' + tc.name_status
        results: formatted_taxon_concepts
  }
  $('.taxon-concept').select2(defaultTaxonSelect2Options)
  $('.taxon-concept').on('change', (event) ->
    return false unless event.val
    $.when($.ajax( '/admin/taxon_concepts/' + event.val + '.json' ) ).then(( data, textStatus, jqXHR ) =>
      $(this).attr('data-name', data.full_name)
      $(this).attr('data-name-status', data.name_status)
      if $(this).hasClass('status-change')
        # reload the name status dropdown based on selection
        statusDropdown = $(this).closest('.fields').find('select')
        statusFrom = data.name_status
        $(statusDropdown).find('option').attr('disabled', true)
        statusMap =
          'A': ['S']
          'N': ['A', 'S']
          'S': ['A']
          'T': ['A', 'S']
        $(statusDropdown).find('option[value=' + statusFrom + ']').removeAttr('selected')
        defaultStatus = statusMap[statusFrom][0]
        $(statusDropdown).find('option[value=' + defaultStatus + ']').attr('selected', true)
        $.each(statusMap[statusFrom], (i, status) ->
          $(statusDropdown).find('option[value=' + status + ']').removeAttr('disabled')
        )
    )
    if $(this).hasClass('clear-others')
      # reset selection in other taxon concept select2 instances
      $('input.taxon-concept').not($(this)).each((i, ac) ->
        $(ac).select2('val', '')
        $(ac).removeAttr('data-name')
        $(ac).removeAttr('data-name-status')
      )
  )

  $(document).on('nested:fieldAdded', (event) ->
    # this field was just inserted into your form
    field = event.field
    # it's a jQuery object already
    taxonField = field.find('.taxon-concept')
    # and activate select2
    taxonField.select2(defaultTaxonSelect2Options)
  )

  simpleTaxonSelect2Options = {
    placeholder: 'Start typing scientific name'
    width: '200px'
  }
  $('.simple-taxon-concept').select2(simpleTaxonSelect2Options)

  $('.select-all-checkbox').click (e) ->
      checkboxElement = $(e.target)
      selectElement = checkboxElement.parent().find('select')
      if checkboxElement.is(':checked')
        selectElement.find('option').prop("selected","selected")
      else
        selectElement.find('option').removeAttr("selected")
      selectElement.trigger("change")
