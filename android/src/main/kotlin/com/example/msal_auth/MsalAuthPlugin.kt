package com.example.msal_auth

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/**
 * This is the main entry point for the Flutter plugin.
 */
class MsalAuthPlugin : FlutterPlugin, ActivityAware {
    private lateinit var msalAuthHandler: MsalAuthHandler
    private lateinit var msal: MsalAuth

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        msal = MsalAuth(binding.applicationContext)
        msalAuthHandler = MsalAuthHandler(msal)
        msalAuthHandler.initialize(binding.binaryMessenger)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        msalAuthHandler.dispose()
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

    override fun onDetachedFromActivity() {}
}