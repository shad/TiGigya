package com.appersonlabs.gigya;

import java.util.Date;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.gigya.socialize.android.GSSession;

@Kroll.proxy(parentModule = GigyaModule.class)
public class GSSessionProxy extends KrollProxy {

    private GSSession session;

    public GSSessionProxy(GSSession session) {
        this.session = session;
    }

    @Kroll.getProperty(name = "expiration")
    public Date getExpiration() {
        return new Date(session.getExpirationTime());
    }

    @Kroll.getProperty(name = "secret")
    public String getSecret() {
        return session.getSecret();
    }

    @Kroll.getProperty(name = "token")
    public String getToken() {
        return session.getToken();
    }

    @Kroll.getProperty(name = "isValid")
    public boolean isValid() {
        return session.isValid();
    }

}
