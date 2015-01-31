# TiGigya Module

The **TiGigya** module provides an interface to the authentication functions and 
[REST API](http://developers.gigya.com/037_API_reference) of the [Gigya](http://gigya.com/)
platform.

## Quick Start

### Get it [![gitTio](http://gitt.io/badge.png)](http://gitt.io/component/com.appersonlabs.gigya)
Download the latest distribution ZIP-file and consult the [Titanium Documentation](http://docs.appcelerator.com/titanium/latest/#!/guide/Using_a_Module) on how install it, or simply use the [gitTio CLI](http://gitt.io/cli):

`$ gittio install com.appersonlabs.gigya`

### iOS setup

The Gigya module requires that the application have a custom URL scheme that matches the
app's bundle identifier.  This URL is called by the various login providers to switch
control from the providers web-based or native UI back to your application.  To define
the custom URL scheme, edit `tiapp.xml` and add a `<string>` element under the
`CFBundleURLTypes` section as follows:

    <ios>
     <plist>
       <dict>
         <key>CFBundleURLTypes</key>
         <array>
           <dict>
             <key>CFBundleURLName</key>
             <string>com.example.MyAppName</string>
             <array>
               <string>MyAppName</string> <!-- default, added by Ti SDK -->
               <string>fb123456789</string> <!-- if the Ti FB APIs are used -->
               <string>com.example.MyAppName</string> <!-- added by you to get Gigya to work -->
             </array>
           </dict>
         </array>
       </dict>
     </plist>
    </ios>

### Android setup

Android apps require an Activity defined for the various login screens.  Ensure that
your `tiapp.xml` file contains that activity and the two permissions listed below:

    <android xmlns:android="http://schemas.android.com/apk/res/android">
      <manifest>
        <application>
          <activity android:name="com.gigya.socialize.android.login.HostActivity" android:theme="@android:style/Theme.Translucent.NoTitleBar" />
          <uses-permission android:name="android.permission.INTERNET"/>
          <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
        </application>
      </manifest>
    </android>

## Loading the module

To use the Gigya module, you must register on [http://developer.gigya.com/](http://developer.gigya.com/)
to get an API key.

Load this module in your Titanium app as follows:

    var gigya = require('com.appersonlabs.gigya');
    gigya.initialize('your-gigya-api-key-here','optionally-APIDomain');

The `initialize` method must be called before calling any other methods.

## Module object

### Properties

**session**

[Session](#session) object, read-only.  The current authentication session or null if the user has not logged in.

### Methods

All arguments and optional dictionary values are optional unless otherwise stated.  Failure callbacks
are passed a dictionary with an error code (`code`) and message (`error`).

**initialize**(api_key,api_domain)

* api_key (string, required): Your Gigya API key.
* api_domain (string): Your Gigya partner API domain.

Initializes the Gigya module for use.

**showLoginProvidersDialog**(options)

* options (dictionary): dialog presentation options. Supported keys are:  
    * enabledProviders (string array): list of authentication providers to show.
    * disabledProviders (string array): list of authentication providers that should not be shown.
    * captionText (string): the text to display at the top of the dialog.
    * cid (string): context identifier that will be passed into the success and failure callbacks.
    * success (function(dict)): callback for successful login.
    * failure (function(dict)): callback for unsuccessful login or user cancellation.

Displays the login providers dialog which allows the user to select a login provider and authenticate
with that provider.

**loginToProvider**(options)

* options (dictionary): login options. Supported keys are:  
    * provider (string, required): the name of the provider to authenticate with.
    * forceAuthentication (boolean): if set to true, the user will be prompted for authentication
      details, even if they are already logged in to the provider (Android only).
    * facebookExtraPermissions (string): a comma-delimited string of extended permissions to request
      when logging in to Facebook.
    * success (function(dict)): callback for successful login.
    * failure (function(dict)): callback for unsuccessful login or user cancellation.

Logs the user in to the specified provider.

**logout**(options)

* options (dictionary): login options. Supported keys are:  
    * success (function(dict)): callback for successful logout (iOS only).
    * failure (function(dict)): callback for unsuccessful logout (iOS only).

Log out from Gigya and clear the saved session.  The callbacks are only supported in iOS; to detect
a successful logout on both platforms, add a listener for the `logout` event.

**showAddConnectionProvidersDialog**(options)

* options (dictionary): dialog presentation options. Supported keys are:  
    * enabledProviders (string array): list of authentication providers to show.
    * disabledProviders (string array): list of authentication providers that should not be shown.
    * captionText (string): the text to display at the top of the dialog.
    * cid (string): context identifier that will be passed into the success and failure callbacks.
    * success (function(dict)): callback for successful addition of a provider.
    * failure (function(dict)): callback for unsuccessful addition of a provider.

Add a new authentication provider to the logged in user's profile.

**requestForMethod**(method, parameters)

* method (string, required): the name of the [Gigya REST API](http://developers.gigya.com/037_API_reference/010_Socialize)
  method to call; e.g. "socialize.getFriendsInfo"
* parameters (dictionary): Request parameters.  See the API docs for each method for a list of
  valid options and their format.  Note that the `UID` parameter is *not* required when using the
  module.

Return a [Request](#request) object that can be used to make a request to the Gigya
social API.

### Events

**login**

Fired when the user logs in.  The `user` property of the event object will contain information
about the currently logged in user.

**logout**

Fired when the user logs out and ends their session.

<a name="session"/>
## Session object

Information about the user's current login session.

### Properties

**expiration**

date, read-only.  The date at which the session expires.

**secret**

string, read-only.  The session secret, which is used to sign requests.

**token**

string, read-only.  The session's authentication token.

**isValid**

boolean, read-only.  True if the session has not expired and represents a valid Gigya session.

<a name="request"/>
## Request object

A request object is created by calling the `requestForMethod()` method in the module and can be
customized before being sent to the Gigya server.

### Properties

**method**

string, read-only.  The REST API method that will be called.

**parameters**

dictionary, read/write.  The parameter values for the specific request method.

**useHTTPS**

boolean, read/write.  If set to true, make a secure HTTP connection to the Gigya server.  Default is false.

### Methods

**sendAsync**(options)

* options (dictionary): request options. Supported keys are:  
    * success (function(dict)): callback for successful request
    * failure (function(dict)): callback for unsuccessful request

Send the request to the Gigya server and return immediately.  The success or failure callback will be
called when the request is complete.  The success callback will contain a property named `response`
with the server's response data, if any.

**sendSync**(options)

* options (dictionary): request options. Supported keys are:  
    * success (function(dict)): callback for successful request
    * failure (function(dict)): callback for unsuccessful request

Sends a request to the Gigya server and waits for a response.  iOS only.
