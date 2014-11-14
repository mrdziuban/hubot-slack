# Description: 
#   Generates help commands for Hubot.
#
# Commands:
#   hubot help - Displays all of the help commands that Hubot knows about.
#   hubot help <query> - Displays all help commands that match <query>.
#
# URLS:
#   /hubot/help
#
# Notes:
#   These commands are grabbed from comment blocks at the top of each file.

helpContents = (name, commands) ->

  """
<html>
  <head>
  <title>#{name} Help</title>
  <style type="text/css">
    body {
      background: #d3d6d9;
      color: #636c75;
      text-shadow: 0 1px 1px rgba(255, 255, 255, .5);
      font-family: Helvetica, Arial, sans-serif;
    }
    h1 {
      margin: 8px 0;
      padding: 0;
    }
    .commands {
      font-size: 13px;
    }
    p {
      border-bottom: 1px solid #eee;
      margin: 6px 0 0 0;
      padding-bottom: 5px;
    }
    p:last-child {
      border: 0;
    }
  </style>
  </head>
  <body>
    <h1>#{name} Help</h1>
    <div class="commands">
      #{commands}
    </div>
  </body>
</html>
  """

module.exports = (robot) ->
  robot.respond /help\s*(.*)?$/i, (msg) ->
    cmds = robot.helpCommands()

    if msg.match[1]
      cmds = cmds.filter (cmd) ->
        cmd.match new RegExp(msg.match[1], 'i')

    emit = cmds.join "\n"

    unless robot.name.toLowerCase() is 'hubot'
      emit = emit.replace /hubot/ig, robot.name

    msg.send emit

  robot.router.get '/hubot/help', (req, res) ->
    cmds = robot.helpCommands()
    emit = "<p>#{cmds.join '</p><p>'}</p>"

    emit = emit.replace /hubot/ig, "<b>#{robot.name}</b>"

    res.setHeader 'content-type', 'text/html'
    res.end helpContents robot.name, emit

  robot.respond /gist help/i, (msg) ->
    msg.send "Type one of the following commands to update the Gist with a new language hack:\n>#languagehacks <hack text> -- this will update the 'General' file\n#csshacks <hack text> -- this will update the 'CSS' file\n#jshacks / #javascripthacks <hack text> -- this will update the 'JavaScript' file\n#phphacks <hack text> -- this will update the 'PHP' file\n\nUse the following syntax to format your text in the Gist:\n>Format code by putting backticks (`) around text\nMake text italics by putting asterisks (*) around it\nMake text bold by putting two asterisks (**) around it\n"
