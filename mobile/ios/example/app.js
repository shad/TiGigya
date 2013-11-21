var win = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
win.add(label);
win.open();

var module = require('com.appersonlabs.gigya');
Ti.API.info("module is => " + module);

// INITIALIZATION

module.APIKey = '3_prG9bc47yYdLvDyytRV5rOl3Hp2SOxEJvoBnVg84Vy2lMQ8qIAftpyplXxtfqDUM';

// AUTHENTICATION


module.showLoginProvidersDialog({
  providers: ['facebook', 'google'],
  success: function(e) {
    Ti.API.info("success: showLoginProvidersDialog");
  },
  failure: function(e) {
    Ti.API.info("failure: showLoginProvidersDialog");
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