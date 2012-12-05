meta_tmpl = ""
msgs_tmpl = ""
window.data = {}

# function to handle putting up new messages
window.post = () ->
  content = $('#to-put').val()
  if content.length > 0
    $('#to-put').val('')
    packed = window.pack
        content: content
        author: window.who
        created_at: (new Date)
    $.ajax
      type: "PUT"
      url: "../../#{packed.hash}"
      contentType: "application/json"
      data: JSON.stringify packed
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
  $.getJSON '_view/created_at', (d) -> $.extend(window.data, d)

  $(document).ajaxStop () ->
    $('#meta').html (Mustache.to_html meta_tmpl, window.data)
    window.data.rows = for msg in window.data.rows
      msg.value.author = msg.value.author or 'anonymous'
      msg
    $('#msgs').html (Mustache.to_html msgs_tmpl, window.data)

# perform the initial update
window.update()

# lets get a username
window.who = "eschulte"
