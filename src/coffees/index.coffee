form = document.getElementById 'contactForm'
nameField = document.getElementById 'name'
emailField = document.getElementById 'email'
submitBtn = document.getElementById 'submitBtn'
submitBtnRegularText = document.getElementById 'submitBtnRegularText'
submitBtnSubmittingText = document.getElementById 'submitBtnSubmittingText'

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

onSubmit = (event)->
	nameValid = fieldIsValid(nameField)
	emailValid = fieldIsValid(emailField)

	if not nameValid or not emailValid
		if event
			event.preventDefault()
		return false

	toggleSubmitButtonEnabled()

	# Do ajaxy stuff
	

	toggleSubmitButtonEnabled()
	return false;

form.addEventListener 'submit', onSubmit, false
apiRoot = '/fmi/data/v1/databases/'
fm =
	host: 'https://rccbox.fmi-beta.filemaker-cloud.com',
	application: 'FMSP_5_English'
	auth:
		username: ''
		password: ''
		token:
			value: ''
			obtained: null
			isExpired: ->
				return yes if not this.obtained

				keepsFor = 1000 * 60 * 15
				now = new Date()
				age = now - this.obtained

				return yes if age >= keepsFor
				return no
			obtain: ->
				if this.isExpired()
					p = fetch this.host + apiRoot + this.application + '/sessions',
						method: 'POST'
						headers: new Headers([
							['Authorization', 'Bearer ' + btoa([fm.auth.username, fm.auth.password].join(':'))],
							['Content-Type', 'application/json']
						])
						body: '{}'
						cache: 'no-cache'
					.then((response)->
						if not response.ok
							throw response
						return response.json()
					)
					.then((result) ->
						this.token.obtained = new Date()
						this.token.value = result.response.token

						return result.response.token
					)
					.catch((error)->
						console.log error
					)
					return p
				else
					return Response.Response(
						this.token.value
					)
			destroy: ->
				return yes if this.isExpired() 
				p = fetch this.host + apiRoot + this.application + '/sessions',
						method: 'DELETE'
						headers: new Headers([
							['Authorization', 'Bearer ' + this.value ],
							['Content-Type', 'application/json']
						])
						body: '{}'
						cache: 'no-cache'
	layouts:
		contacts: ''
	
	contact:
		add: ->
			p = fetch this.host + apiRoot + this.application + '/sessions',
	addNewContact: ->
		this.token.obtain()
		.then((token)->
			p = fetch this.host + apiRoot + this.application + '/layouts/' + this.layouts.contacts,
					method: 'POST'
					headers: new Headers([
						['Authorization', 'Bearer ' + token ],
						['Content-Type', 'application/json']
					])
					body: '{}'
					cache: 'no-cache'
		)
			