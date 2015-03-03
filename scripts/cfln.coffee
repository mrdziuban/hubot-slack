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

  # robot.respond /gif( me)? (.*)/i (msg) ->
  #   url = "http://giphy.com/search/#{encodeURIComponent(msg.match[2])}"
  #   msg.http(url).get() (err, res, body) ->
  #     scrapeGiphy msg, body, (gif) ->
  #       msg.send gif

scrapeCfln = (msg, body, cb) ->
  jsdom.env body, (errors, window) ->
    commits = []
    for commit in window.document.getElementsByClassName('commit')
      commits.push commit.textContent
    commitToPost = msg.random commits
    cb commitToPost

# scrapeGiphy = (msg, body, cb) ->
#   jsdom.env body, (errors, window) ->
#     urls = []
#     for img in document.querySelectorAll('.hoverable img')
#       urls.push img.src
#     gif = msg.random urls
#     cb gif