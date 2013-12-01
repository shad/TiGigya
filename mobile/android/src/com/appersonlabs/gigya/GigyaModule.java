/**
 * This file was auto-generated by the Titanium Module SDK helper for Android
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
package com.appersonlabs.gigya;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.KrollObject;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;

import android.text.TextUtils;
import android.util.Log;

import com.gigya.socialize.GSObject;
import com.gigya.socialize.GSResponse;
import com.gigya.socialize.GSResponseListener;
import com.gigya.socialize.android.GSAPI;
import com.gigya.socialize.android.GSSession;
import com.gigya.socialize.android.event.GSConnectUIListener;
import com.gigya.socialize.android.event.GSEventListener;
import com.gigya.socialize.android.event.GSLoginUIListener;

@Kroll.module(name = "Gigya", id = "com.appersonlabs.gigya")
public class GigyaModule extends KrollModule implements GSEventListener {

    private static final String TAG = "GigyaModule";

    @Kroll.onAppCreate
    public static void onAppCreate(TiApplication app) {
        Log.i(TAG, "onAppCreate");
    }

    private GSAPI api;

    public GigyaModule() {
        super();
    }

    @Kroll.getProperty(name = "session")
    public GSSessionProxy getSession() {
        GSSession session = api.getSession();
        return session != null ? new GSSessionProxy(api.getSession()) : null;
    }

    @Kroll.method(name = "loginToProvider", runOnUiThread = true)
    public void loginToProvider(KrollDict dict) throws Exception {
        String provider = (String) dict.get("name");
        if (provider == null) {
            Log.e(TAG, "missing provider name");
            return;
        }

        GSObject params = new GSObject();
        params.put("provider", provider);

        if (dict.containsKey("cid")) {
            params.put("cid", (String) dict.get("cid"));
        }
        if (dict.containsKey("forceAuthentication")) {
            params.put("forceAuthentication", (Boolean) dict.get("forceAuthentication"));
        }
        if (dict.containsKey("facebookExtraPermissions")) {
            params.put("facebookExtraPermissions", TextUtils.join(",", (String[]) dict.get("facebookExtraPermissions")));
        }

        final KrollFunction success = (KrollFunction) dict.get("success");
        final KrollFunction failure = (KrollFunction) dict.get("failure");
        final KrollObject thisObject = getKrollObject();

        api.login(params, new GSResponseListener() {
            @Override
            public void onGSResponse(String method, GSResponse response, Object context) {
                if (response.getErrorCode() == 0 && success != null) {
                    KrollDict dict = new KrollDict();
                    dict.put("user", GSObjectConverter.fromGSObject(response.getData()));
                    success.call(thisObject, dict);
                }
                if (response.getErrorCode() != 0 && failure != null) {
                    failure.call(thisObject, GSObjectConverter.fromGSObject(response.getData()));
                }
            }
        }, null);
    }

    @Kroll.method(name = "logout")
    public void logout(KrollDict dict) {
        api.logout();
    }

    @Override
    public void onConnectionAdded(String provider, GSObject user, Object context) {
    }

    @Override
    public void onConnectionRemoved(String provider, Object context) {
    }

    @Override
    public void onLogin(String provider, GSObject user, Object context) {
        KrollDict params = new KrollDict();
        params.put("user", GSObjectConverter.fromGSObject(user));
        fireEvent("login", params);
    }

    @Override
    public void onLogout(Object context) {
        fireEvent("logout", null);
    }

    public Object requestForMethod(String method) {
        return null;
    }

    @Kroll.setProperty(name = "APIKey")
    public void setAPIKey(String apikey) {
        if (api == null) {
            api = new GSAPI(apikey, this.getActivity());
            api.setEventListener(this);
        }
    }

    @Kroll.method(name = "showAddConnectionProvidersDialog", runOnUiThread = true)
    public void showAddConnectionProvidersDialog(KrollDict dict) {
        GSObject params = new GSObject();

        if (dict.containsKey("enabledProviders")) {
            params.put("enabledProviders", TextUtils.join(",", (String[]) dict.get("enabledProviders")));
        }
        if (dict.containsKey("disabledProviders")) {
            params.put("disabledProviders", TextUtils.join(",", (String[]) dict.get("disabledProviders")));
        }
        if (dict.containsKey("captionText")) {
            params.put("captionText", (String) dict.get("captionText"));
        }
        if (dict.containsKey("cid")) {
            params.put("cid", (String) dict.get("cid"));
        }

        final KrollFunction success = (KrollFunction) dict.get("success");
        final KrollFunction failure = (KrollFunction) dict.get("failure");
        final KrollObject thisObject = getKrollObject();

        api.showAddConnectionsUI(params, new GSConnectUIListener() {

            @Override
            public void onClose(boolean cancelled, Object context) {
                if (failure != null && cancelled) {
                    KrollDict params = new KrollDict();
                    params.put("code", -1);
                    params.put("error", "User cancelled login");
                    failure.call(thisObject, params);
                }
            }

            @Override
            public void onConnectionAdded(String provider, GSObject user, Object context) {
                if (success != null) {
                    KrollDict eventParams = new KrollDict();
                    eventParams.put("provider", provider);
                    eventParams.put("user", GSObjectConverter.fromGSObject(user));
                    success.call(thisObject, eventParams);
                }
            }

            @Override
            public void onError(GSResponse response, Object context) {
                if (failure != null) {
                    KrollDict params = new KrollDict();
                    params.put("code", response.getErrorCode());
                    params.put("error", response.getErrorMessage());
                    failure.call(thisObject, params);
                }
            }

            @Override
            public void onLoad(Object context) {
                // TODO Auto-generated method stub

            }
        }, null);
    }

    @Kroll.method(name = "showLoginProvidersDialog", runOnUiThread = true)
    public void showLoginProvidersDialog(KrollDict dict) {
        GSObject params = new GSObject();

        if (dict.containsKey("enabledProviders")) {
            params.put("enabledProviders", TextUtils.join(",", (String[]) dict.get("enabledProviders")));
        }
        if (dict.containsKey("disabledProviders")) {
            params.put("disabledProviders", TextUtils.join(",", (String[]) dict.get("disabledProviders")));
        }
        if (dict.containsKey("captionText")) {
            params.put("captionText", (String) dict.get("captionText"));
        }
        if (dict.containsKey("cid")) {
            params.put("cid", (String) dict.get("cid"));
        }
        if (dict.containsKey("forceAuthentication")) {
            params.put("forceAuthentication", (Boolean) dict.get("forceAuthentication"));
        }
        if (dict.containsKey("facebookExtraPermissions")) {
            params.put("facebookExtraPermissions", (String) dict.get("facebookExtraPermissions"));
        }

        final KrollFunction success = (KrollFunction) dict.get("success");
        final KrollFunction failure = (KrollFunction) dict.get("failure");
        final KrollObject thisObject = getKrollObject();

        api.showLoginUI(params, new GSLoginUIListener() {
            @Override
            public void onClose(boolean cancelled, Object context) {
                if (failure != null && cancelled) {
                    KrollDict params = new KrollDict();
                    params.put("code", -1);
                    params.put("error", "User cancelled login");
                    failure.call(thisObject, params);
                }
            }

            @Override
            public void onError(GSResponse response, Object context) {
                if (failure != null) {
                    KrollDict params = new KrollDict();
                    params.put("code", response.getErrorCode());
                    params.put("error", response.getErrorMessage());
                    failure.call(thisObject, params);
                }
            }

            @Override
            public void onLoad(Object context) {
                // TODO Auto-generated method stub

            }

            @Override
            public void onLogin(String provider, GSObject user, Object context) {
                if (success != null) {
                    KrollDict eventParams = new KrollDict();
                    eventParams.put("user", GSObjectConverter.fromGSObject(user));
                    success.call(thisObject, eventParams);
                }
            }

        }, null);
    }

}
