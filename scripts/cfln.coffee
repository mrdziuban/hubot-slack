# Description:
#   Pull a random commit from Commit Logs From Last Night
#
# Dependencies:
#   jsdom
#
# Configuration:
#   None
#
# Commands:
#   hubot commit me
#
# Author:
#   Matt Dziuban

jsdom = require 'jsdom'

module.exports = (robot) ->
  robot.respond /commit( me)?/i, (msg) ->
    url = 'http://www.commitlogsfromlastnight.com/'
    msg.http(url).headers('User-Agent': 'hubot').get() (err, res, body) ->
      scrapeCfln msg, body, (commit) ->
        msg.send commit

scrapeCfln = (msg, body, cb) ->
  jsdom.env body, (errors, window) ->
    commits = []
    for commit in window.document.getElementsByClassName('commit')
      commits.push commit.textContent
    commitToPost = msg.random commits
    cb commitToPost
