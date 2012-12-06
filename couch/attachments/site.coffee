author_len = 13
window.msg_tmpl = ""
window.conn = null

# get the message template
$.get 'templates/message.html', (d) -> window.msg_tmpl = d

# add a message to the page
clean_author = (author) ->
  author = author or 'anonymous'
  if author.length > author_len
    return author[0..(author_len-3)].concat '...'
  else
    return "              "[(author.length)..].concat author

window.add_message = (msg) ->
  $('#msgs').append (Mustache.to_html window.msg_tmpl,
    author: clean_author msg.author
    content: msg.content)
  $('#msgs').scrollTop($('#msgs').height())

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
      url: "api/#{packed.hash}"
      contentType: "application/json"
      data: JSON.stringify packed

# Continuous DB connection listening for new messages
window.start_poll = () ->
  last = 0
  window.conn = (new XMLHttpRequest())
  window.conn.open("GET", "api/_changes?feed=continuous&filter=app/chats")
  window.conn.send(null)
  window.conn.onreadystatechange = () ->
    latest = window.conn.responseText.substring(last)
    last = window.conn.responseText.length
    if latest.length > 0
      array = ((a) -> if a.length > 20 then a[20..] else a) latest.split("\n")
      lines = (JSON.parse line for line in array when line.length > 0)
      for line in lines
        if line.last_seq
          $('meta[name=last-msg]').attr 'content', line.last_seq
        else
          $.ajax
            type: "GET"
            url: "api/#{line.id}"
            dataType: "json"
            async: false
            success: window.add_message
    window.start_poll if window.conn.readyState == window.conn.DONE

# Show connection state
conn_state = () ->
  switch window.conn.readyState
    when 0 then "UNSENT"
    when 1 then "OPENED"
    when 2 then "HEADERS_RECIEVED"
    when 3 then "LOADING"
    when 4 then "DONE"

# Close and restart the connection
conn_reconnect = () ->
  window.conn.abort()
  window.start_poll()

# Final page setup
$('#to-who').val('anonymous')
$('#to-put').keypress (e) -> put() if (e.which == 13)
$('#state').click () -> alert "connection: #{conn_state()}"
$('#reconnect').click conn_reconnect
window.start_poll()
