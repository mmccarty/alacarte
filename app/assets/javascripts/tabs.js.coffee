jQuery ->
  $('.icon-question-sign').popover()

  sortable_post = (sortable, data) ->
    $.post sortable.attr('data-reorder'), data

  sortable_item_ids = (sortable) ->
    $.map sortable.sortable('toArray'), (item) -> item.match /\d+/

  $('#mods').sortable
    handle: '.icon-move'
    update: ->
      sortable = $('#mods')
      sortable_post sortable,
        resource_ids: sortable_item_ids sortable

  $('#left_mods').sortable
    handle: '.icon-move'
    connectWith: '#right_mods'
    update: ->
      left_sortable = $('#left_mods')
      right_sortable = $('#right_mods')
      sortable_post left_sortable,
        left_ids: sortable_item_ids left_sortable
        right_ids: sortable_item_ids right_sortable

  $('#right_mods').sortable
    handle: '.icon-move'
    connectWith: '#left_mods'

  $('#tabs').sortable
    handle: '.icon-move'
    update: ->
      sortable = $('#tabs')
      sortable_post sortable,
        tab_ids: sortable_item_ids sortable
