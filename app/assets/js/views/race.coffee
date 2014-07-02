ap.Views.race = XView.extend
	initialize: ->
		_.whenReady 'ranks', =>
			@options.out = _.template @options.out, ap.me.attributes
			@initRender()
		ap.bindResize('race', => @resize())
	rendered: ->
		_.whenReady 'tasks', =>
			@renderTasks()
	renderTasks: ->
		html = ''
		_.whenReady 'achievements', =>
			for task in ap.tasks
				task_class= ''
				if ap.me.achieved(task.racetask_id)
					task_class = ' achieved'
				html += '<a href="/task/'+task.slug+'" class="task-row">
					<div class="task-points'+task_class+'">'+task.points+'</div>
					<span class="task-title">'+task.task+'</span>
				</a>'
			$('#race-task-list').html(html)
			@setRowHeights()
	setRowHeights: ->
		$('.task-row').each ->
			$t = $(this)
			$t.css('height', '')
			$t.css('height', $t.outerHeight()+'px')
	resize: ->
		@setRowHeights()
	whenFinished: ->
		ap.unbindResize('race')

