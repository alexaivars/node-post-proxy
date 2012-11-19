http = require("http")
q = require("querystring")
url = require("url")
server_port = process.env.PORT || 9006
server = http.createServer().listen server_port

server.on "request", (req, res) ->
  params = url.parse(req.url, true).query
  callbackFn = "callback"
  console.log params
  if params.callback isnt undefined and params.callback isnt ""
    callbackFn = params.callback

  if params.url is undefined or params.url is ""
    res.write "#{callbackFn} (#{JSON.stringify { status: "ERROR", message : "missing url parameter" }})"
    res.end()
    return
 
  # console.log callbackFn
  requestUrl = url.parse(params.url)
  # console.log requestUrl
  
  post_data = JSON.stringify params

  options =
    host: requestUrl.hostname
    path: requestUrl.path
    method: "POST"
    headers:
      "Content-Length": post_data.length
      "Content-Type": "application/json"

  client = http.request(options)
  client.on "response", (response) ->
    data = ""
    response.setEncoding('utf8')
    response.on "data", (chunk) ->
      data += chunk
    response.on "end", () =>
      @emit("end",data)

  client.write(post_data)
  client.end()

  client.on "end", (data) ->
    console.log "parent end"
    console.log "#{callbackFn} (#{data})"
    res.write "#{callbackFn} (#{data})"
    res.end()

console.log "post proxy running on #{server_port}"
