Species.SearchFormDropdowns = Ember.Mixin.create(

  click: (event) ->
    selected_popup = @.$().parent().find('.popup-clickable')
    selected_popup.toggle()
    $('.popup-clickable').not(selected_popup).hide()
)
