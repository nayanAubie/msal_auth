package com.example.msal_auth;

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

class MsalAuthPlugin : FlutterPlugin, ActivityAware {

    private var mTAG = "MsalAuthPlugin"
    private var msalAuthImpl: MsalAuthImpl? = null
    private var msal: Msal? = null;


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        msal = Msal(binding.applicationContext, null);
        msalAuthImpl = MsalAuthImpl(msal!!)
        msalAuthImpl.let {
            it?.setMethodCallHandler(binding.binaryMessenger)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (msalAuthImpl == null) {
            Log.wtf(mTAG, "Already detached from the engine.");
            return;
        }

        msalAuthImpl.let {
            it?.stopMethodCallHandler();
        }
        msalAuthImpl = null;
        msal = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (msalAuthImpl == null) {
            Log.wtf(mTAG, "urlLauncher was never set.");
            return;
        }
        msal.let {
            it?.setActivity(binding.activity as FlutterActivity);
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity();
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding);
    }

    override fun onDetachedFromActivity() {
        if (msalAuthImpl == null) {
            Log.wtf(mTAG, "urlLauncher was never set.");
            return;
        }
    }
}