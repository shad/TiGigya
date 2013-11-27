package com.appersonlabs.gigya;

import java.util.Map;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.common.Log;
import org.json.JSONException;
import org.json.JSONObject;

import com.gigya.socialize.GSArray;
import com.gigya.socialize.GSObject;

public class GSObjectConverter {

    private static final String TAG = "GSObjectConverter";

    public static KrollDict fromGSObject(GSObject obj) {
        if (obj == null) return null;
        /*
         * GSObject has no means of determining the native type of a value
         * stored under a particular key.
         */
        try {
            JSONObject json = new JSONObject(obj.toJsonString());
            return new KrollDict(json);
        }
        catch (JSONException e) {
            Log.e(TAG, "error converting GSObject: " + e.getMessage());
        }
        return null;
    }

    public static GSArray toGSArray(Object[] arr) {
        if (arr == null) return null;

        GSArray result = new GSArray();
        for (Object value : arr) {
            if (value instanceof Boolean) {
                result.add((Boolean) value);
            }
            else if (value instanceof Integer) {
                result.add((Double) value);
            }
            else if (value instanceof Long) {
                result.add((Long) value);
            }
            else if (value instanceof Double) {
                result.add((Double) value);
            }
            else if (value instanceof String) {
                result.add((String) value);
            }
            else if (value instanceof KrollDict) {
                result.add(GSObjectConverter.toGSObject((KrollDict) value));
            }
            else if (value instanceof Object[]) {
                result.add(GSObjectConverter.toGSArray((Object[]) value));
            }
        }
        return result;
    }

    public static GSObject toGSObject(KrollDict dict) {
        if (dict == null) return null;

        GSObject result = new GSObject();
        for (Map.Entry<String, Object> entry : dict.entrySet()) {
            String key = entry.getKey();
            Object value = entry.getValue();
            if (value instanceof Boolean) {
                result.put(key, (Boolean) value);
            }
            else if (value instanceof Integer) {
                result.put(key, (Double) value);
            }
            else if (value instanceof Long) {
                result.put(key, (Long) value);
            }
            else if (value instanceof Double) {
                result.put(key, (Double) value);
            }
            else if (value instanceof String) {
                result.put(key, (String) value);
            }
            else if (value instanceof KrollDict) {
                result.put(key, GSObjectConverter.toGSObject((KrollDict) value));
            }
            else if (value instanceof Object[]) {
                result.put(key, GSObjectConverter.toGSArray((Object[]) value));
            }
        }

        return result;
    }
}
