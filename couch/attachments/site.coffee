meta_tmpl = ""
msgs_tmpl = ""
data = {}

# get the templates
$.get 'templates/meta.html',    (d) -> meta_tmpl = d
$.get 'templates/message.html', (d) -> msgs_tmpl = d

# get the data
$.getJSON '_view/all', (d) -> $.extend(data, d)

$(document).ajaxStop () ->
  $('#meta').html (Mustache.to_html meta_tmpl, data)
  $('#msgs').html (Mustache.to_html msgs_tmpl, data)
