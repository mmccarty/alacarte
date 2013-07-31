jQuery ->
  $('#acts_pagey tr').on 'ajax:success', (event) ->
    $target = $ event.target
    if $target.hasClass 'icon-trash'
      $(event.currentTarget).remove()

    if $target.hasClass 'icon-lock'
      $target.removeClass('icon-lock').addClass 'icon-unlock'
    else if $target.hasClass 'icon-unlock'
      $target.removeClass('icon-unlock').addClass 'icon-lock'

    if $target.hasClass 'icon-check'
      $target.removeClass('icon-check').addClass 'icon-check-empty'
    else if $target.hasClass 'icon-check-empty'
      $target.removeClass('icon-check-empty').addClass 'icon-check'

  $('.edit').editable($('.edit').attr('post-url'))