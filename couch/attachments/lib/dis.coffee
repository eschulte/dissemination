window.pack = (data) ->
  # TODO: hash should depend on all data, not just content
  data.hash = hex_md5("\"content\" #{content.length} #{data.content}")
  data
