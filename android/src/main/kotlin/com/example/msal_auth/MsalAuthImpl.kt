package com.example.msal_auth

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.microsoft.identity.client.AcquireTokenParameters
import com.microsoft.identity.client.AcquireTokenSilentParameters
import com.microsoft.identity.client.IAccount
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication
import com.microsoft.identity.client.Prompt
import com.microsoft.identity.client.PublicClientApplication
import com.microsoft.identity.client.exception.MsalException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale

class MsalAuthImpl(private val msal: Msal) : MethodChannel.MethodCallHandler {
    private val mTAG = "MsalAuthImpl"

    private var channel: MethodChannel? = null

    fun setMethodCallHandler(messenger: BinaryMessenger) {
        if (channel != null) {
            Log.wtf(mTAG, "Setting a method call handler before the last was disposed.")
            stopMethodCallHandler()
        }

        channel = MethodChannel(messenger, "msal_auth")
        channel!!.setMethodCallHandler(this)
    }

    fun stopMethodCallHandler() {
        if (channel == null) {
            Log.d(mTAG, "Tried to stop listening when no MethodChannel had been initialized.")
            return
        }

        channel!!.setMethodCallHandler(null)
        channel = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val scopesArg: ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val configFilePath: String? = call.argument("configFilePath")

        when (call.method) {
            "initialize" -> {
                initialize(configFilePath, result)
            }

            "loadAccounts" -> Thread { msal.loadAccounts(result) }.start()
            "acquireToken" -> Thread { acquireToken(scopes, result) }.start()
            "acquireTokenSilent" -> Thread { acquireTokenSilent(scopes, result) }.start()
            "logout" -> Thread { logout(result) }.start()

            else -> result.notImplemented()
        }
    }

    private fun logout(result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to logout",
                    null
                )
            }
            return
        }

        if (msal.accountList.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "No account is available to acquire token silently",
                    null
                )
            }
            return
        }

        msal.clientApplication.removeAccount(
            msal.accountList.first(),
            object : IMultipleAccountPublicClientApplication.RemoveAccountCallback {
                override fun onRemoved() {
                    Thread { msal.loadAccounts(result) }.start()
                }

                override fun onError(exception: MsalException) {
                    result.error("AUTH_ERROR", exception.message, exception.stackTrace)
                }
            })
    }

    private fun acquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire a silent token.",
                    null
                )
            }
        }

        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Call must have the scopes", null)
            }
            return
        }

        // ensures that accounts are exist
        if (msal.accountList.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "No account is available to acquire token silently",
                    null
                )
            }
            return
        }

        val selectedAccount: IAccount = msal.accountList.first()
        // acquire the token and return the result
        scopes.map { s -> s.lowercase(Locale.ROOT) }.toTypedArray()

        val builder = AcquireTokenSilentParameters.Builder()
        builder.withScopes(scopes.toList())
            .forAccount(selectedAccount)
            .fromAuthority(selectedAccount.authority)
            .withCallback(msal.getAuthSilentCallback(result))
        val acquireTokenParameters = builder.build()
        msal.clientApplication.acquireTokenSilentAsync(acquireTokenParameters)
    }

    private fun acquireToken(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }

        if (scopes == null) {
            result.error("AUTH_ERROR", "Call must include a scope", null)
            return
        }

        //remove old accounts
        while (msal.clientApplication.accounts.any())
            msal.clientApplication.removeAccount(msal.clientApplication.accounts.first())


        //acquire the token

        msal.activity.let {
            val builder = AcquireTokenParameters.Builder()
            builder.startAuthorizationFromActivity(it?.activity)
                .withScopes(scopes.toList())
                .withPrompt(Prompt.LOGIN)
                .withCallback(msal.getAuthCallback(result))
            val acquireTokenParameters = builder.build()
            msal.clientApplication.acquireToken(acquireTokenParameters)
        }
    }

    private fun initialize(
        configFilePath: String?,
        result: MethodChannel.Result
    ) {
        if (msal.isClientInitialized()) {
            result.success(true)
            return
        }

        PublicClientApplication.createMultipleAccountPublicClientApplication(
            msal.applicationContext,
            File(configFilePath!!),
            msal.getApplicationCreatedListener(result)
        )
    }
}