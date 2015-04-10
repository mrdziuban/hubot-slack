# Description:
#   Uses downforeveryoneorjustme.com to check if a site is up
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot is <domain> up? - Checks if <domain> is up
#
# Author:
#   jmhobbs

module.exports = (robot) ->
  robot.respond /is (the site|bostinno|dc|dc\s?inno|chicago|chicago\s?inno|la|la\s?inno|austin|austin\s?inno|seattle|seattle\s?inno) (up|down)(\?)?/i, (msg) ->
    isUp msg, msg.match[1], (domain) ->
      msg.send domain

isUp = (msg, domain, cb) ->
  if domain.toLowerCase() == 'bostinno' or domain.toLowerCase() == 'the site'
    domain = 'bostinno.streetwise.co'
  else
    domain = domain.toLowerCase().replace(/\s+/, '')
    if domain.substring(2) != 'inno'
      domain = domain+'inno'
    domain = domain+'.streetwise.co'
  msg.http("http://isitup.org/#{domain}.json")
    .header('User-Agent', 'Hubot')
    .get() (err, res, body) ->
      response = JSON.parse(body)
      if response.status_code is 1
        cb "#{response.domain} looks UP from here."
      else if response.status_code is 2
        cb "#{response.domain} looks DOWN from here."
      else if response.status_code is 3
        cb "Are you sure '#{response.domain}' is a valid domain?"
      else
        msg.send "Not sure, #{response.domain} returned an error."
