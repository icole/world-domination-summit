https = require 'https'
http = require 'http'
crypto = require 'crypto'
Twit = require 'twit'
redis = require 'redis'
async = require 'async'
rds = redis.createClient()


#

[Feed, Feeds] = require('../models/feeds')
[User, Users] = require('../models/users')

shell = (app, db) ->
	twit = new Twit
		consumer_key: app.settings.twitter_consumer_key
		consumer_secret: app.settings.twitter_consumer_secret
		access_token: app.settings.twitter_token
		access_token_secret: app.settings.twitter_token_secret

	grab = ->
		grabs = 
			tweet: ->
				rds.get 'feed_twitter_since', (err, since_id) ->

					if not since_id
						since_id = '0'
					tk since_id

					tk 'Start tweet feed...'
					twit.get 'search/tweets', {q: '#wds2014', since_id: since_id, result_type:'recent', count:'100'}, (err, twts) ->
						if twts.statuses?.length
							last_id = false
							async.each twts.statuses, (twt, cb) ->
								data =
									tweet: twt.text
									tweeter: twt.user.screen_name
								hash = crypto.createHash('md5').update(twt.id_str+twt.text).digest('hex')
								last_id = twt.id_str
								User.forge({twitter: twt.user.screen_name})
								.fetch()
								.then (login) ->
									if login
										user_id = login.get('user_id')
										add(user_id, hash, twt.text, 0, 'twitter') 
									cb()
							, ->
								if last_id
									rds.set 'feed_twitter_since', last_id, ->
										rds.expire 'feed_twitter_since', 1000000
						else
							tk 'No new tweets.'
				
		for type, fnc of grabs
			fnc()

		setTimeout ->
			grab()
		, 60000

	###
		Add feed content
	###
	add = (user_id, hash, content, channel_id, channel_type) ->
		Feed.forge({hash: hash})
		.fetch()
		.then (existing) ->
			unless existing
				new_feed = Feed.forge
					user_id: user_id
					hash: hash
					content: content
					channel_id: channel_id
					channel_type: channel_type
				new_feed.save()
				.then (row) ->
					cb row
				, (err) ->
					err

	###
		Start Grabber
	####
	grab()

module.exports = shell