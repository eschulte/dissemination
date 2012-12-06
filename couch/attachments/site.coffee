meta_tmpl = ""
msgs_tmpl = ""
limit = 20
window.data = {}

# PUT a new messages to the server
window.put = () ->
  content = $('#to-put').val()
  if content.length > 0
    $('#to-put').val('')
    packed = window.pack
        content: content
        author: $('#to-who').val()
        created_at: (new Date)
    $.ajax
      type: "PUT"
      url: "../../#{packed.hash}"
      contentType: "application/json"
      data: JSON.stringify packed
      complete: window.update

# Update the full message list
window.update = () ->
  # get the templates
  $.get 'templates/meta.html',    (d) -> meta_tmpl = d
  $.get 'templates/message.html', (d) -> msgs_tmpl = d

  # get the data
  $.getJSON("_view/created_at?descending=true&limit=#{limit}",
            (d) -> $.extend(window.data, d))

  $(document).ajaxStop () ->
    range =
      start: window.data.total_rows - limit
      end: window.data.total_rows
    $('#meta').html (Mustache.to_html meta_tmpl, range)
    temp = rows: []
    for msg in window.data.rows
      msg.value.author = msg.value.author or 'anonymous'
      temp.rows = [msg].concat temp.rows
    $('#msgs').html (Mustache.to_html msgs_tmpl, temp)

# Initial page setup
window.update()
$('#to-who').val('anonymous')
# ENTER on #to-put calls put()
$('#to-put').keypress (e) ->
  put() if (e.which == 13)
