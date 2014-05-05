$("#company_users tr.data-row").draggable
  helper: "clone"

$('#company_teams tr.data-row').droppable
  drop:(event, ui) ->
    team_row = $(this)
    $.ajax
      url: '/users/'+ui.draggable.data('user-id')+'/teams/create',
      data: {teams_users: {team_id: team_row.data('team-id')}},
      type: 'post',
      dataType: 'json',
      success:(data) ->
        if(Object.keys(data).indexOf('errors') == -1)
          team_row.find('.users-count').text(data.users_count).append('<span style="position: absolute;" class="badge badge-success">+1</span>')
          team_row.find('.users-count span').animate({"bottom":"50px"},200).animate({"bottom":"0px"}, ->
            $(this).animate({"opacity":"0"}, 1000, 'linear', ->
              $(this).remove()
            )
          )
        else
          team_row.popover(
            placement: 'top'
            content: data.errors.join(', ')
          ).popover('show')
          setTimeout(->
            team_row.popover('destroy')
          , 3000)