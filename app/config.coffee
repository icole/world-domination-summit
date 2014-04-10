# Configuration
config = (app, express, RedisStore, mysql) ->
	app.configure ->
		app.set('views', __dirname + '/views')
		app.set('view engine', 'jade')
		app.set('view options', { pretty: true });
		app.set('twitter_consumer_key', process.env.TWIT_KEY)
		app.set('twitter_consumer_secret', process.env.TWIT_SEC)
		app.set('uploadDir', '/tmp')

		app.use(express.cookieParser())
		app.use express.session
			secret: process.env.SESS_SEC
			store: new RedisStore
		app.use(express.bodyParser({uploadDir:'/tmp_uploads', keepExtensions: true}))
		app.use(express.methodOverride())
		app.use require('connect-assets')(
			src: 'app/assets'
			build: false
		)
		app.use(app.router)
		app.use(express.static(__dirname + '/public'));

	

	app.configure 'development', ->
		app.set('port', 6767);
		app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
		app.set 'db', 
            client: 'mysql'
            connection:
            	host: process.env.DB_HOST
            	user: process.env.DB_USER
            	password: process.env.DB_PW
            	database: process.env.DB
            	charset: 'utf8'
            debug: false

	app.configure 'production', ->
		app.set('port', 7676);
		app.use(express.errorHandler());
		app.set 'db', 
            client: 'mysql'
            connection:
            	host: process.env.DB_HOST
            	user: process.env.DB_USER
            	password: process.env.DB_PW
            	database: process.env.DB
            	charset: 'utf8'

module.exports = config
