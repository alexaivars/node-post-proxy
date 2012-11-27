http = require("http")
q = require("querystring")
url = require("url")
server_port = process.env.PORT || 9006
server = http.createServer().listen server_port

request = require('request')


server.on "request", (req, res) ->
  params = url.parse(req.url, true).query
  
  if params.callback isnt undefined and params.callback isnt ""
    callbackFn = params.callback
  else
    callbackFn = "callback"

  if params.url is undefined or params.url is ""
    res.write "#{callbackFn} (#{JSON.stringify { status: "ERROR", message : "missing url parameter" }});"
    res.end()
    return

  request.post
    uri: params.url
    json: params
  , (error, response, body) ->
    if response.statusCode is 201
      res.write "#{callbackFn} (#{JSON.stringify(body)});"
    else if response.statusCode is 400
      res.write "#{callbackFn} ({ 'error':'#{JSON.stringify(body)}', 'code': '#{response.statusCode}' });"
    else
      res.write "#{callbackFn} ({ 'error':'#{body}', 'code': '#{response.statusCode}' });"
    res.end()

console.log "post proxy running on #{server_port}"


