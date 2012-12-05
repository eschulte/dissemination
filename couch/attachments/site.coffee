data =
  msgs: [
    { id: 'foo', content: 'bar' }
    { id: 'baz', content: 'qux' }
  ]

$('#msgs').html (Mustache.to_html "<ul>{{#msgs}}<li><b>{{id}}</b> {{content}}</li>{{/msgs}}</ul>", data)
