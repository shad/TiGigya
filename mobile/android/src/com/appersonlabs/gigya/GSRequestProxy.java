package com.appersonlabs.gigya;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollObject;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import android.util.Log;

import com.gigya.socialize.GSObject;
import com.gigya.socialize.GSResponse;
import com.gigya.socialize.GSResponseListener;
import com.gigya.socialize.android.GSAPI;

@Kroll.proxy(parentModule = GigyaModule.class)
public class GSRequestProxy extends KrollProxy {

    private GSAPI       api;

    private KrollDict parameters;

private String method;

@Kroll.getProperty(name="method")
public String getMethod() {
  return method;
}

    @Kroll.property(name = "useHTTPS")
    public boolean      useHTTPS = false;

    public GSRequestProxy(GSAPI api, String method) {
        assert api != null;
        assert method != null;
        
        this.api = api;
        this.method = method;
    }

    @Kroll.method(name = "sendAsync")
    public void sendAsync(KrollDict dict) {
        
        final KrollFunction success = (KrollFunction) dict.get("success");
        final KrollFunction failure = (KrollFunction) dict.get("failure");
        final KrollObject thisObject = getKrollObject();

        GSObject params = parameters != null ? GSObjectConverter.toGSObject(parameters) : new GSObject();

        api.sendRequest(method, params, useHTTPS, new GSResponseListener() {

            @Override
            public void onGSResponse(String method, GSResponse response, Object context) {
                if (success != null && response.getErrorCode() == 0) {
                    KrollDict params = new KrollDict();
                    params.put("response", GSObjectConverter.fromGSResponse(response));
                    success.call(thisObject, params);
                }
                if (failure != null && response.getErrorCode() != 0) {
                    KrollDict params = new KrollDict();
                    params.put("code", response.getErrorCode());
                    params.put("error", response.getErrorMessage());
                    failure.call(thisObject, params);
                }
            }

        }, null);
    }

    @Kroll.method(name = "sendSync")
    public KrollDict sendSync() {
        throw new UnsupportedOperationException("sendSync() not supported on Android");
    }

    @Kroll.setProperty(name = "parameters")
    public void setParameters(KrollDict parameters) {
        this.parameters = parameters;
    }
}
