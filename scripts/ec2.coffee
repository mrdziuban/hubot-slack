# Description:
#   Find the IP address of your EC2s
#
# Dependencies:
#   "aws-sdk": "^2.1.18"
#
# Configuration:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
#
# Commands:
#   hubot what's the ip/IP of <ec2 name>?
#   hubot what is the ip/IP of <ec2 name>?
#
# Author:
#   Matt Dziuban (mrdziuban)
#

AWS = require('aws-sdk')
AWS.config.update region: 'us-east-1'
ec2 = new (AWS.EC2)

ec2Names = dev: 'dev_m1_medium', stage: 'stage_m1_4', qa: 'qa_m1_medium'

queryEc2 = (msg, name) ->
  if not ec2Names[name.toLowerCase()]
    return msg.send 'Sorry, I\'m not programmed to check that EC2'
  ec2.describeInstances {Filters: [{
    Name: 'tag:Name'
    Values: [ec2Names[name.toLowerCase()]]
  }]}, (err, data) ->
    if err
      return console.log err, err.stack
    if not data.Reservations
      return msg.send 'Amazon returned no EC2 data'
    msg.send "The IP of #{name} is #{data.Reservations[0].Instances[0].PublicIpAddress}"


module.exports = (robot) ->
  robot.respond /what(\'s| is) the ip of ([^\?]+)\??$/i, (msg) ->
    queryEc2 msg, msg.match[2]

  robot.respond /what(\'s| is) ([a-zA-Z]+)(\'s)? ip/i, (msg) ->
    queryEc2 msg, msg.match[2]
