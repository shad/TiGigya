var win = Ti.UI.createWindow({
	backgroundColor:'white',
  layout: 'vertical',
});
var label = Ti.UI.createLabel({
  top: 20
});
win.add(label);

var module = require('com.appersonlabs.gigya');
Ti.API.info("module is => " + module);

// INITIALIZATION

module.APIKey = '3_prG9bc47yYdLvDyytRV5rOl3Hp2SOxEJvoBnVg84Vy2lMQ8qIAftpyplXxtfqDUM';

// AUTHENTICATION

var showLoginProvidersButton = Ti.UI.createButton({
  title: 'Show Login Providers'
});
showLoginProvidersButton.addEventListener('click', function(e) {
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

win.addEventListener('open', function(e) {
  if (module.session.isValid) {
    showLoginProvidersButton.enabled = false;
    label.text = String.format('Current session: %s (%s)', module.session.token, module.session.lastLoginProvider);
  }
});

/*

module.loginToProvider({
  name: 'facebook',
  success: function(e) {
    Ti.API.info("success: loginToProvider");
  },
  failure: function(e) {
    Ti.API.info("failure: loginToProvider");
  }
});

// there are popover versions of these for iPad, maybe postpone?

module.logout({
  success: function(e) {
    Ti.API.info("success: logout");
  },
});

// CONNNECTIONS

module.showAddConnectionProvidersDialog({
  providers: ['facebook', 'twitter'],
  success: function(e) {
    Ti.API.info("success: showAddConnectionProvidersDialog");
  },
  failure: function(e) {
    Ti.API.info("failure: showAddConnectionProvidersDialog");
  }
});

// REQUESTS

var req = module.requestForMethod("socialize.getFriendsInfo", {
  detailLevel: "extended"
});
req.send({
  success: function(e) {
    // "response" is a JS object
    var friends = e.response.friends;
  },
  failure: function(e) {}
});

*/

win.open();
