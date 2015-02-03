package com.appersonlabs.gigya;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.common.Log;
import org.json.JSONException;
import org.json.JSONObject;

import com.gigya.socialize.GSArray;
import com.gigya.socialize.GSObject;
import com.gigya.socialize.GSResponse;

public class GSObjectConverter {

    private static final String TAG = "GSObjectConverter";

    public static KrollDict fromGSObject(GSObject obj) {
        if (obj == null)
            return null;
        /*
         * GSObject has no means of determining the native type of a value stored under a particular
         * key.
         */
        try {
            JSONObject json = new JSONObject(obj.toJsonString());
            return new KrollDict(json);
        } catch (Exception e) {
            Log.e(TAG, "error converting GSObject: " + e.getMessage());
        }
        return null;
    }

    public static KrollDict fromGSResponse(GSResponse response) {
        if (response == null)
            return null;

        try {
            return new KrollDict(new JSONObject(response.getResponseText()));
        } catch (JSONException e) {
            Log.e(TAG, "error converting GSResponse: " + e.getMessage());
        }

        return null;
    }

    public static GSArray toGSArray(Object[] arr) {
        if (arr == null)
            return null;

        GSArray result = new GSArray();
        for (Object value : arr) {
            if (value instanceof Boolean) {
                result.add((Boolean) value);
            } else if (value instanceof Integer) {
                result.add((Double) value);
            } else if (value instanceof Long) {
                result.add((Long) value);
            } else if (value instanceof Double) {
                result.add((Double) value);
            } else if (value instanceof String) {
                result.add((String) value);
            } else if (value instanceof KrollDict) {
                result.add(GSObjectConverter.toGSObject((KrollDict) value));
            } else if (value instanceof Object[]) {
                result.add(GSObjectConverter.toGSArray((Object[]) value));
            }
        }
        return result;
    }

    public static GSObject toGSObject(Map<String, Object> dict) {
        return toGSObject(dict, null);
    }

    public static GSObject toGSObject(Map<String, Object> dict, String[] skipKeys) {
        if (dict == null)
            return null;

        List<String> keysToSkip = skipKeys != null ? Arrays.asList(skipKeys) : null;

        GSObject result = new GSObject();
        for (Map.Entry<String, Object> entry : dict.entrySet()) {
            String key = entry.getKey();

            if (keysToSkip != null && keysToSkip.contains(key))
                continue;

            Object value = entry.getValue();
            if (value instanceof Boolean) {
                result.put(key, value);
            } else if (value instanceof Integer) {
                result.put(key, value);
            } else if (value instanceof Long) {
                result.put(key, value);
            } else if (value instanceof Double) {
                result.put(key, value);
            } else if (value instanceof String) {
                result.put(key, (String) value);
            } else if (value instanceof KrollDict) {
                result.put(key, GSObjectConverter.toGSObject((KrollDict) value));
            } else if (value instanceof Object[]) {
                result.put(key, GSObjectConverter.toGSArray((Object[]) value));
            }
        }

        return result;
    }
}
