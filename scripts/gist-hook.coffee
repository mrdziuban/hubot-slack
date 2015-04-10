# Description:
#   Update Gists using the GitHub API based on certain hashtags
#
# Configuration:
#   HUBOT_GIST_API_KEY
#
# Commands:
#   #languagehacks <hack text>
#   #csshacks <hack text>
#   #phphacks <hack text>
#   #jshacks <hack text>
#   #javascripthacks <hack text>
#
# Author:
#   Matt Dziuban (mrdziuban)
#

XMLHttpRequest = require 'xhr2'
gistKey = process.env.HUBOT_GIST_API_KEY
gistId = 'eaad5445f7e23cedae98'

module.exports = (robot) ->
	robot.hear /#languagehacks\s+(.+)/i, (msg) ->
    sendToGist msg, 'General', (responseText) ->
      msg.send responseText

  robot.hear /#csshacks\s+(.+)/i, (msg) ->
    sendToGist msg, 'CSS', (responseText) ->
      msg.send responseText

  robot.hear /#phphacks\s+(.+)/i, (msg) ->
    sendToGist msg, 'PHP', (responseText) ->
      msg.send responseText

  robot.hear /#ja?v?a?sc?r?i?p?t?hacks\s+(.+)/i, (msg) ->
    sendToGist msg, 'JavaScript', (responseText) ->
      msg.send responseText

  robot.hear /^#languagehacks$/i, (msg) ->
    sendToGist msg, 'General', (responseText) ->
      msg.send responseText
    , true

  robot.hear /^#csshacks$/i, (msg) ->
    sendToGist msg, 'CSS', (responseText) ->
      msg.send responseText
    , true

  robot.hear /^#ja?v?a?sc?r?i?p?t?hacks$/i, (msg) ->
    sendToGist msg, 'JavaScript', (responseText) ->
      msg.send responseText
    , true

  robot.hear /^#phphacks$/i, (msg) ->
    sendToGist msg, 'PHP', (responseText) ->
      msg.send responseText
    , true

sendToGist = (msg, fileName, cb, getOnly) ->
  text = msg.match[1]
  fileName = fileName+'.md'
  msg.http('https://api.github.com/gists/'+gistId).headers('Authorization': 'token '+gistKey).get() (err, res, body) ->
    gist = JSON.parse(body)
    if not gist or not gist.files or not gist.files[fileName]
      return cb 'Failed to pull Gist'
    fileContents = gist.files[fileName].content
    return cb 'Gist located at: https://gist.github.com/streetwise-stager/'+gistId+'#file-'+fileName.toLowerCase().replace('.', '-')+"\n\nFile contents (formatting may not look good in Slack): \n\n"+fileContents if getOnly
    patchData = {files:{}}
    patchData.files[fileName] = {
      content: fileContents+"\n- "+text
    }
    request = new XMLHttpRequest()
    request.open('PATCH', 'https://api.github.com/gists/'+gistId, true)
    request.setRequestHeader('Authorization', 'token '+gistKey)
    request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded')
    request.onreadystatechange = () ->
      if (request.readyState == 4 and request.status == 200)
        cb 'Gist updated. View it at https://gist.github.com/streetwise-stager/'+gistId
      else if (request.readyState == 4)
        cb 'Failed to update Gist. Error code: '+request.status
    request.send(JSON.stringify(patchData))
