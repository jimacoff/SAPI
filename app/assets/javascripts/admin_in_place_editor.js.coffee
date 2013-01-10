$(document).ready ->
  #editorClass = $('.editor').attr('id')
  window.adminInPlaceEditor = new AdminInPlaceEditor()
  window.adminInPlaceEditor.init()

class AdminInPlaceEditor
  init: () ->
    @initEditors()
    @initModals()

  initEditors: () ->
    $('#admin-in-place-editor .editable').editable
      placement: 'right'
      ajaxOptions:
        dataType: 'json'
        type: 'put'
      params: (params) ->
        #originally params contain pk, name and value
        newParams = id: params.pk
        newParams[$(@).attr('data-resource')] = {}
        newParams[$(@).attr('data-resource')][params.name] = params.value
        return newParams

    $('#admin-in-place-editor .editable-required').editable('option',
      validate: (v) ->
        return 'Required field!' if (v == '')
    )

    $('#admin-in-place-editor .editable-geo-entity-type').editable(
      'option', 'source', window.geoEntityTypes
    )

    $('#admin-in-place-editor .editable-geo-relationship-type').editable(
      'option', 'source', window.geoRelationshipTypes
    )

    $('#admin-in-place-editor .editable-geo-entity').editable(
      'option', 'source', window.geoEntities
    )

  initModals: () ->
    $('.modal .modal-footer .save-button').click () ->
      $(@).closest('.modal').find('form').submit()

    $('.modal').on 'hidden', () ->
      $(@).find('form')[0].reset()
      $(@).find('.alert').remove()

    $('.typeahead').typeahead
      source: (query, process) =>
        $('#taxon_concept_parent_id').attr('value', null)
        designation_id = $('#taxon_concept_designation_id').attr('value')
        rank_id = $('#taxon_concept_rank_id').attr('value')
        $.get('/admin/taxon_concepts/autocomplete',
        {
          scientific_name: query,
          designation_id: designation_id,
          rank_id: rank_id,
          limit: 25
        }, (data) =>
          @parentsMap = {}
          labels = []
          $.each(data, (i, item) =>
            label = item.designation_name + ' ' + item.full_name + ' ' + item.rank_name
            @parentsMap[label] = item.id
            labels.push(label)
          )
          return process(labels)
        )
      updater: (item) =>
        $('#taxon_concept_parent_id').attr('value', @parentsMap[item])
        return item

  alertSuccess: (txt) ->
    $('.alert').remove()

    alert = $('<div class="alert alert-success">')
    alert.append('<a class="close" href="#" data-dismiss="alert">x</a>')
    alert.append(txt)

    $(alert).insertBefore($('h1'))
