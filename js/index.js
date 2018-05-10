var apiRoot, emailField, fieldIsValid, fm, form, nameField, onSubmit, submitBtn, submitBtnRegularText, submitBtnSubmittingText, toggleClass, toggleSubmitButtonEnabled;

form = document.getElementById('contactForm');

nameField = document.getElementById('name');

emailField = document.getElementById('email');

submitBtn = document.getElementById('submitBtn');

submitBtnRegularText = document.getElementById('submitBtnRegularText');

submitBtnSubmittingText = document.getElementById('submitBtnSubmittingText');

toggleClass = function(el, cls) {
  if (el.classList.contains(cls)) {
    return el.classList.remove(cls);
  } else {
    return el.classList.add(cls);
  }
};

toggleSubmitButtonEnabled = function() {
  toggleClass(submitBtnRegularText, 'hide');
  toggleClass(submitBtnSubmittingText, 'hide');
  toggleClass(submitBtn, 'btn-success');
  toggleClass(submitBtn, 'btn-light');
  return submitBtn.disabled = !submitBtn.disabled;
};

fieldIsValid = function(field) {
  if (field.value.length === 0) {
    field.classList.add('is-invalid');
    return false;
  } else {
    field.classList.remove('is-invalid');
    return true;
  }
};

onSubmit = function(event) {
  var emailValid, nameValid;
  nameValid = fieldIsValid(nameField);
  emailValid = fieldIsValid(emailField);
  if (!nameValid || !emailValid) {
    if (event) {
      event.preventDefault();
    }
    return false;
  }
  toggleSubmitButtonEnabled();
  // Do ajaxy stuff
  toggleSubmitButtonEnabled();
  return false;
};

form.addEventListener('submit', onSubmit, false);

apiRoot = '/fmi/data/v1/databases/';

fm = {
  host: 'https://rccbox.fmi-beta.filemaker-cloud.com',
  application: 'FMSP_5_English',
  auth: {
    username: '',
    password: '',
    token: {
      value: '',
      obtained: null,
      isExpired: function() {
        var age, keepsFor, now;
        if (!this.obtained) {
          return true;
        }
        keepsFor = 1000 * 60 * 15;
        now = new Date();
        age = now - this.obtained;
        if (age >= keepsFor) {
          return true;
        }
        return false;
      },
      obtain: function() {
        var p;
        if (this.isExpired()) {
          p = fetch(this.host + apiRoot + this.application + '/sessions', {
            method: 'POST',
            headers: new Headers([['Authorization', 'Bearer ' + btoa([fm.auth.username, fm.auth.password].join(':'))], ['Content-Type', 'application/json']]),
            body: '{}',
            cache: 'no-cache'
          }).then(function(response) {
            if (!response.ok) {
              throw response;
            }
            return response.json();
          }).then(function(result) {
            this.token.obtained = new Date();
            this.token.value = result.response.token;
            return result.response.token;
          }).catch(function(error) {
            return console.log(error);
          });
          return p;
        } else {
          return Response.Response(this.token.value);
        }
      },
      destroy: function() {
        var p;
        if (this.isExpired()) {
          return true;
        }
        return p = fetch(this.host + apiRoot + this.application + '/sessions', {
          method: 'DELETE',
          headers: new Headers([['Authorization', 'Bearer ' + this.value], ['Content-Type', 'application/json']]),
          body: '{}',
          cache: 'no-cache'
        });
      }
    }
  },
  layouts: {
    contacts: ''
  },
  contact: {
    add: function() {
      var p;
      return p = fetch(this.host + apiRoot + this.application + '/sessions');
    }
  },
  addNewContact: function() {
    return this.token.obtain().then(function(token) {
      var p;
      return p = fetch(this.host + apiRoot + this.application + '/layouts/' + this.layouts.contacts, {
        method: 'POST',
        headers: new Headers([['Authorization', 'Bearer ' + token], ['Content-Type', 'application/json']]),
        body: '{}',
        cache: 'no-cache'
      });
    });
  }
};

//# sourceMappingURL=maps/index.js.map
