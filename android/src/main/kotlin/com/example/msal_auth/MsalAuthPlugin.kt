package com.example.msal_auth

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel

class MsalAuthPlugin : FlutterPlugin, ActivityAware {

    private var mTAG = MsalAuthPlugin::class.simpleName
    private lateinit var msalAuthHandler: MsalAuthHandler
    private lateinit var msal: MsalAuth

    private lateinit var channel: MethodChannel


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        msal = MsalAuth(binding.applicationContext)
        msalAuthHandler = MsalAuthHandler(msal)
        msalAuthHandler.initialize(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        msal.setActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d(mTAG, "Detached from activity")
    }
}