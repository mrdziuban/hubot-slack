allowedScores = ['1','2','3','4']

module.exports = (robot) ->
  robot.respond /poker (play|start)/i, (msg) ->
    channel = msg.envelope.user.room
    console.log channel
    robot.brain.set 'poker', channel
    msg.send 'Poker begun. Estimate your task using the syntax "poker estimate 1|2|3|4'

  robot.respond /poker (estimate|bet|rank) (.)/i, (msg) ->
    estimate = msg.match[2]
    room = robot.brain.get 'poker'
    origin = msg.message
    envelope = room: room, user: {}, message: origin

    if room
      if allowedScores.indexOf estimate > -1
        robot.brain.set 'Poker scores: ' + origin.user.id, estimate
        console.log origin.user.id
        robot.adapter.send envelope, origin.user.name + ' has estimated'
        msg.send 'Thanks!'
      else
        msg.send estimate + " isn't acceptable"
        msg.send 'Please user either 1, 2, 3, or 4'
    else
      msg.send "There's no poker being played right now"

  robot.respond /poker (finish|end)/i, (msg) ->
    scores = []
    users = robot.brain.users()

    for id, user of users
      key = 'Poker scores: ' + id
      score = robot.brain.get(key)
      if score != null
        scores.push user.name + ' estimated ' + score
        robot.brain.remove(key)

    for score in scores
      msg.send score

    robot.brain.remove 'poker'