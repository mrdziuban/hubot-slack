apiKey = process.env.HUBOT_GOOGLE_PLACES_API_KEY

module.exports = (robot) ->
	robot.respond /(lunch me)(.*)/i, (msg) ->
		lunchMe msg, msg.match[2], (results) ->
			if results?.length > 0
				lunchSpot = msg.random results
				msg.send lunchSpot.name + " - " + lunchSpot.vicinity.replace /, Boston/, '' + " - " + "http://maps.google.com/maps?q=" + lunchSpot.geometry.location.lat + "%2C" + lunchSpot.geometry.location.lng + "&hl=en&sll=37.0625,-95.677068&sspn=73.579623,100.371094&vpsrc=0&hnear=" + lunchSpot.geometry.location.lat + "%2C" + lunchSpot.geometry.location.lng + "&t=m&z=11"
			else
				msg.send "No results found"

lunchMe = (msg, query, cb) ->
	lunchQuery = query or "lunch"
	msg.http("https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{apiKey}&location=42.36007439999999%2C-71.0540307&radius=800&sensor=false&types=food&keyword=" + escape(lunchQuery) + "&maxprice=1")
		.get() (err, res, body) ->
			lunchSpots = JSON.parse(body)
			results = lunchSpots.results
			if lunchSpots.next_page_token
				setTimeout ->
					msg.http("https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{apiKey}&sensor=false&pagetoken=#{lunchSpots.next_page_token}")
						.get() (err, res, body) ->
							lunchSpots2 = JSON.parse(body)
							results = results.concat lunchSpots2.results
							if lunchSpots2.next_page_token
								setTimeout ->
									msg.http("https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=#{apiKey}&sensor=false&pagetoken=#{lunchSpots.next_page_token}")
										.get() (err, res, body) ->
											lunchSpots3 = JSON.parse(body)
											results = results.concat lunchSpots3.results
											cb results
								, 1250
							else
								cb results
				, 1250
			else
				cb results