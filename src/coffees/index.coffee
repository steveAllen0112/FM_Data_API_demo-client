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

	# prep the entered data
	fm.contact.email = emailField.value
	fm.contact.name.set nameField

	# Do ajaxy stuff
	fm.contact.add()
		.then((response)->
			window.location = './thanks.html'
		)
		.catch((error)->
			console.log('error', error)
			toggleSubmitButtonEnabled()
			alert "Error.  See console log in debug mode."
		)
	if event
		event.preventDefault()
	return false

form.addEventListener 'submit', onSubmit, false
apiRoot = '/fmi/data/v1/databases/'
fm =
	host: 'https://rccbox.fmi-beta.filemaker-cloud.com',
	application: 'FMSP_5_English'
	base: ->
		this.host + apiRoot + this.application + '/'
	auth:
		username: 'web_create_contact_only'
		password: '12345'
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
					authString = btoa([fm.auth.username, fm.auth.password].join(':'))
					console.log('created authString for token request', authString)
					headers =
						'Authorization': 'Bearer ' + authString
						'Content-Type': 'application/json'
					headerObj = new Headers(headers)
					console.log('created headers for token request', headers, [...headerObj.entries()])
					p = fetch fm.base() + 'sessions',
						method: 'POST'
						headers: headerObj
						body: '{}'
						cache: 'no-cache'
						credentials: 'include'
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
				p = fetch fm.host + apiRoot + fm.application + '/sessions',
						method: 'DELETE'
						headers: new Headers([
							['Authorization', 'Bearer ' + this.value ],
							['Content-Type', 'application/json']
						])
						body: '{}'
						cache: 'no-cache'
						mode: 'no-cors'
	layouts:
		contacts: 'L40_CONTACTS_Data_Entry'
	
	contact:
		name:
			first: ''
			last: ''
			set: (nameField)->
				nameArr = nameField.value.split ' '
				if nameArr.lengh > 1
					this.last = nameArr.splice(-1)
				this.first = nameArr.join ' '
		email: ''
		add: ->
			fm.auth.token.obtain()
				.then((token)->
					payload = JSON.stringify(
							"Name_First": fm.contact.first
							"Name_Last": fm.contact.last
							"Email": fm.contact.email
						, true)
					p = fetch fm.base() + 'layouts/' + fm.layouts.contacts + '/records',
							method: 'POST'
							headers: new Headers([
								['Authorization', 'Bearer ' + token ],
								['Content-Type', 'application/json']
							])
							body: payload
							cache: 'no-cache'
							mode: 'no-cors'
					
					fm.auth.token.destroy()

					return p
				)