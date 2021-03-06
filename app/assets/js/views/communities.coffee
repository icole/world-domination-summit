ap.Views.communities = XView.extend
	initialize: ->
		_.whenReady 'assets', =>
			@initRender()
	rendered: ->
		yours = ap.me.get('interests')
		yours_html = ''
		others_html = ''
		for interest in ap.interests
			button = '
				<a href="/community/'+_.slugify(interest.interest)+'" class="interest-button">'+interest.interest+'</a>
			'
			if yours.indexOf(interest.interest_id) > -1
				yours_html += button
			else
				others_html += button
		$('#attendee-communities').html yours_html
		$('#other-communities').html others_html

