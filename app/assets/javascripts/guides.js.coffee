jQuery ->
  $('#guides tr').on 'ajax:success', (event) ->
    $target = $ event.target
    if $target.hasClass 'icon-trash'
      $(event.currentTarget).remove()

    if $target.hasClass 'icon-lock'
      $target.removeClass('icon-lock').addClass 'icon-unlock'
    else if $target.hasClass 'icon-unlock'
      $target.removeClass('icon-unlock').addClass 'icon-lock'

  $('.edit').editable($('.edit').attr('post-url'), {
    callback : (value, settings) ->
      console.log(value)
  })