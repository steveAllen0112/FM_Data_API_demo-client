form = document.getElementById 'contactForm'
nameField = document.getElementById 'name'
emailField = document.getElementById 'email'
submitBtn = document.getElementById 'submitBtn'
submitBtnRegularText = document.getElementById 'submitBtnRegularText'
submitBtnSubmittingText = document.getElementById 'submitBtnSubmittingText'

errorMessage = document.getElementById 'errorMessage'

setError = (message)->
	console.log 'setting error', message, errorMessage
	errorMessage.innerHTML = message
	if message
		errorMessage.classList.remove 'hide'
	else
		errorMessage.classList.add 'hide'
	console.log 'error set', errorMessage.classList.contains('hide')
		

toggleClass = (el, cls)->
	if el.classList.contains cls
		el.classList.remove cls
	else
		el.classList.add cls
		
toggleSubmitButtonEnabled = ->
	toggleClass(submitBtnRegularText, 'hide')
	toggleClass(submitBtnSubmittingText, 'hide')
	toggleClass(submitBtn, 'btn-success')
	toggleClass(submitBtn, 'btn-light')
	submitBtn.disabled = !submitBtn.disabled

fieldIsValid = (field)->
	if field.value.length is 0
		field.classList.add 'is-invalid'
		return false
	else
		field.classList.remove 'is-invalid'
		return true

api =
	base_uri: 'https://dbw05.atrcc.com/FM17_Data_API_demo-middleman/public/index.php'

app =
	project: 'FM17_REST_DEMO'
	environment: 'DEV-LOCAL'
	version: 'v1.0.0'

contact =
	name:
		first: ''
		last: ''
		set: (nameField)->
			nameArr = nameField.value.split ' '
			if nameArr.length > 1
				this.last = nameArr.splice(-1).join()
			this.first = nameArr.join ' '
	email: ''
	add: ->
		payload = 
			"name_first": this.name.first
			"name_last": this.name.last
			"email": this.email
		
		payloadStr = JSON.stringify payload

		p = fetch api.base_uri + '/contacts',
				method: 'POST'
				headers: new Headers([
					['Content-Type', 'application/json']
					['X-RCC-PROJECT', app.project ]
					['X-RCC-ENVIRONMENT', app.environment ]
					['X-RCC-VERSION', app.version ]
				])
				body: payloadStr
				cache: 'no-cache'
		return p

onSubmit = (event)->
	nameValid = fieldIsValid(nameField)
	emailValid = fieldIsValid(emailField)

	if not nameValid or not emailValid
		if event
			event.preventDefault()
		return false

	toggleSubmitButtonEnabled()

	# prep the entered data
	contact.email = emailField.value
	contact.name.set nameField

	# Do ajaxy stuff
	contact.add()
		.then((response)->
			if not response.ok
				throw Error response.status + ' ' + response.statusText
			return response
		)
		.then((response)->
			window.location = './thanks.html'
		)
		.catch((error)->
			console.log 'error', error
			toggleSubmitButtonEnabled()
			setError error
		)
	if event
		event.preventDefault()
	return false

form.addEventListener 'submit', onSubmit, false