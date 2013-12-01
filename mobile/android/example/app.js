var win = Ti.UI.createWindow({
  backgroundColor:'white',
  layout: 'vertical'
});
var label = Ti.UI.createLabel({
  top: 20
});
win.add(label);

var module = require('com.appersonlabs.gigya');
Ti.API.info("module is => " + module);

// INITIALIZATION

module.APIKey = 'your-gigya-api-key-here';

// AUTHENTICATION

var showLoginProvidersButton = Ti.UI.createButton({
  title: 'Show Login Providers'
});
showLoginProvidersButton.addEventListener('click', function(e) {
  label.text = '';
  module.showLoginProvidersDialog({
/*    providers: ['facebook', 'google'], */
    success: function(e) {
      label.text = 'logged in as ' + e.user.firstName + ' ' + e.user.lastName;
      Ti.API.info("success: showLoginProvidersDialog: "+JSON.stringify(e));
    },
    failure: function(e) {
      label.text = 'login failure: ' + e.error;
      Ti.API.info("failure: showLoginProvidersDialog: "+JSON.stringify(e));
    }
  });
});
win.add(showLoginProvidersButton);

var foo = Ti.Network;  

var loginToProviderButton = Ti.UI.createButton({
  title: 'Login to Google'
});
loginToProviderButton.addEventListener('click', function(e) {
  label.text = '';
  module.loginToProvider({
    name: 'google',
    success: function(e) {
      label.text = 'logged in as ' + e.user.firstName + ' ' + e.user.lastName;
      Ti.API.info("success: showLoginProvidersDialog: "+JSON.stringify(e));
      
      // test HTTPClient bug
      var client = Ti.Network.createHTTPClient({
        onload: function(e) {
          label.text = "HTTPClient success";
        },
        onerror: function(e) {
          label.text = "HTTPClient error";
        }
      });
      client.open("GET", "http://www.google.com/");
      client.send();
      label.text = "sent HTTP req";
    },
    failure: function(e) {
      label.text = 'login failure: ' + e.error;
      Ti.API.info("failure: showLoginProvidersDialog: "+JSON.stringify(e));
    }
  });
});
win.add(loginToProviderButton);


var logoutButton = Ti.UI.createButton({
  title: 'Logout'
});
logoutButton.addEventListener('click', function(e) {
  label.text = '';
  module.logout();
});
win.add(logoutButton);

var sessionButton = Ti.UI.createButton({
  title: 'Show Session'
});
sessionButton.addEventListener('click', function(e) {
  var session = module.session;
  label.text = session ? "token="+session.token+"; isValid="+session.isValid : "null";
});
win.add(sessionButton);


// CONNNECTIONS

var addConnectionProvidersButton = Ti.UI.createButton({
  title: 'Add Connection Providers'
});
addConnectionProvidersButton.addEventListener('click', function(e) {
  if (module.session && module.session.isValid) {
    module.showAddConnectionProvidersDialog({
      providers: ['facebook', 'twitter'],
      success: function(e) {
        label.text = "added connection provider: "+JSON.stringify(e);
      },
      failure: function(e) {
        label.text = "failed to add connection provider: "+JSON.stringify(e);
      }
    });
  }
});
win.add(addConnectionProvidersButton);


// REQUESTS

var sendGetFriendsInfoRequestButton = Ti.UI.createButton({
  title: 'Get Friends (async)'
});
sendGetFriendsInfoRequestButton.addEventListener('click', function(e) {
  var req = module.requestForMethod('socialize.getFriendsInfo');
  req.sendAsync({
    success: function(e) {
      label.text = JSON.stringify(e);
    },
    failure: function(e) {
      label.text = JSON.stringify(e);
    }
  });
});
win.add(sendGetFriendsInfoRequestButton);

var sendGetAlbumsRequestButton = Ti.UI.createButton({
  title: 'Get Albums (sync)'
});
sendGetAlbumsRequestButton.addEventListener('click', function(e) {
  var req = module.requestForMethod('socialize.getAlbums');
  var resp = req.sendSync();
  label.text = JSON.stringify(resp);
});
win.add(sendGetAlbumsRequestButton);



// AUTH EVENTS

// These are optional. I use them to set up the UI to show logged in/out state.

function updateUI(loggedIn) {
  showLoginProvidersButton.enabled = !loggedIn;
  loginToProviderButton.enabled = !loggedIn;
  logoutButton.enabled = loggedIn;
  addConnectionProvidersButton.enabled = loggedIn;
  sendGetFriendsInfoRequestButton.enabled = loggedIn;
  sendGetAlbumsRequestButton.enabled = loggedIn;
}

module.addEventListener('login', function(e) {
  if (e.user) {
    updateUI(true);
  }
});

module.addEventListener('logout', function(e) {
  updateUI(false);
});

win.addEventListener('open', function(e) {
  var session = module.session;
  updateUI(!!(session && session.isValid));
});

win.open();
