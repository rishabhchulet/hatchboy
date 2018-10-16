jQuery ->

  $('#jira-generate-consumer-key').click ->
    $('#jira_source_consumer_key').val(SecureRandom.hex(16))
    false

  $('#jira-generate-rsa-key').click ->
    $.getJSON '/jira_sources/generate_public_cert', (data) ->
      $('#jira_source_private_key').val(data.private_key)
      pk_block = $('#jira-public-key-block')
      pk_block.find('div.right').html(data.public_key)
      if !pk_block.is(':visible')
        pk_block.slideDown()
    false

SecureRandom = 
  hex:(n) ->
    n = n+1 || 17
    str = []
    while --n
      r = Math.floor(Math.random()*256).toString(16).substr(Math.floor(Math.random()*2),1) || String.fromCharCode(65+(Math.floor(Math.random()*8)))
      str.push(r)
    str.join('')