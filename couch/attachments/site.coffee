meta_tmpl = ""
msgs_tmpl = ""
data = {}

# function to handle putting up new messages
window.post = () ->
  content = $('#to-put').val()
  if content.length > 0
    hash = hex_md5(content)
    $('#to-put').val('')
    $.ajax
      type: "PUT"
      url: "../../#{hash}"
      contentType: "application/json"
      data: JSON.stringify
        content: content
        created_at: (new Date)
      complete: window.update

# function to update message list
window.update = () ->
  # ENTER on #to-put calls post()
  $('#to-put').keypress (e) ->
    post() if (e.which == 13)
  # get the templates
  $.get 'templates/meta.html',    (d) -> meta_tmpl = d
  $.get 'templates/message.html', (d) -> msgs_tmpl = d

  # get the data
  $.getJSON '_view/created_at', (d) -> $.extend(data, d)

  $(document).ajaxStop () ->
    $('#meta').html (Mustache.to_html meta_tmpl, data)
    $('#msgs').html (Mustache.to_html msgs_tmpl, data)

# perform the initial update
window.update()
