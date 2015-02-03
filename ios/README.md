Building
========

This module requires the Gigya SDK Framework to build.

1. Download the framework from the Gigya developer site.
1. Copy `GigyaSDK.framework/GigyaSDK` to `lib/libGigyaSDK.a`
1. Copy `GigyaSDK.framework/Headers/*` to `headers`
1. Build the module using `build.py`


Usage
=====

The Gigya authentication mechanism uses a custom URL scheme so login providers
can call back into the app.  