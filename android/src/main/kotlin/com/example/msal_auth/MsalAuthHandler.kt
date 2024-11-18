package com.example.msal_auth

import android.os.Handler
import android.os.Looper
import com.google.gson.Gson
import com.microsoft.identity.client.AcquireTokenParameters
import com.microsoft.identity.client.AcquireTokenSilentParameters
import com.microsoft.identity.client.MultipleAccountPublicClientApplication
import com.microsoft.identity.client.Prompt
import com.microsoft.identity.client.SingleAccountPublicClientApplication
import com.microsoft.identity.client.configuration.AccountMode
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MsalAuthHandler(private val msal: MsalAuth) : MethodChannel.MethodCallHandler {
    private val mTAG = MsalAuthHandler::class.simpleName

    private lateinit var channel: MethodChannel

    fun initialize(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "msal_auth")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        println("onMethodCall called========${call.method}")
        when (call.method) {
            "createSingleAccountPca", "createMultipleAccountPca" -> {
                val config = call.argument<HashMap<String, Any>>("config")!!
                val configFile = File(msal.context.cacheDir, "msal_config.json").apply {
                    writeText(Gson().toJson(config))
                }
                if (call.method == "createSingleAccountPca") {
                    createSingleAccountPca(configFile, result)
                } else {
                    createMultipleAccountPca(configFile, result)
                }
            }

            "acquireToken" -> {
                val scopes: List<String> = call.argument<List<String>>("scopes")!!.toList()
                val promptArg: String? = call.argument("prompt")
                val loginHint: String? = call.argument("loginHint")

                val prompt: Prompt = when (promptArg) {
                    "selectAccount" -> Prompt.SELECT_ACCOUNT
                    "login" -> Prompt.LOGIN
                    "consent" -> Prompt.CONSENT
                    "create" -> Prompt.CREATE
                    else -> Prompt.WHEN_REQUIRED
                }
                Thread { acquireToken(scopes, prompt, loginHint, result) }.start()
            }

            "acquireTokenSilent" -> {
                val scopes: List<String> = call.argument<List<String>>("scopes")!!.toList()
                val identifier: String? = call.argument("identifier")
                Thread { acquireTokenSilent(scopes, identifier, result) }.start()
            }

            "currentAccount" -> getCurrentAccount(result)

            "signOut" -> signOut(result)

            "getAccount" -> {
                val identifier = call.argument<String>("identifier")!!
                getAccount(identifier, result)
            }

            "getAccounts" -> getAccounts(result)

            "removeAccount" -> {
                val identifier = call.argument<String>("identifier")!!
                Thread { removeAccount(identifier, result) }.start()
            }

            else -> result.notImplemented()
        }
    }

    private fun createSingleAccountPca(configFile: File, result: MethodChannel.Result) {
        if (msal.isClientInitialized() && msal.iPublicClientApplication.configuration.accountMode == AccountMode.SINGLE) {
            result.success(true)
            return
        }

        SingleAccountPublicClientApplication.createSingleAccountPublicClientApplication(
            msal.context,
            configFile,
            msal.singleAccountApplicationCreatedListener(result)
        )
    }

    private fun createMultipleAccountPca(configFile: File, result: MethodChannel.Result) {
        if (msal.isClientInitialized() && msal.iPublicClientApplication.configuration.accountMode == AccountMode.MULTIPLE) {
            result.success(true)
            return
        }

        MultipleAccountPublicClientApplication.createMultipleAccountPublicClientApplication(
            msal.context,
            configFile,
            msal.multipleAccountApplicationCreatedListener(result)
        )
    }

    private fun acquireToken(
        scopes: List<String>,
        prompt: Prompt,
        loginHint: String?,
        result: MethodChannel.Result
    ) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }

        if (msal.iSingleAccountPca != null) {
            msal.iSingleAccountPca!!.currentAccount?.let { accountResult ->
                if (accountResult.currentAccount != null) {
                    acquireTokenSilent(scopes, null, result)
                } else {
                    msal.activity.let {
                        val builder = AcquireTokenParameters.Builder()
                        builder.startAuthorizationFromActivity(it)
                            .withScopes(scopes.toList())
                            .withPrompt(prompt)
                            .withLoginHint(loginHint)
                            .withCallback(msal.authenticationCallback(result))

                        val acquireTokenParameters = builder.build()
                        msal.iPublicClientApplication.acquireToken(acquireTokenParameters)
                    }
                }
            }
        } else if (msal.iMultipleAccountPca != null) {
            msal.activity.let {
                val builder = AcquireTokenParameters.Builder()
                builder.startAuthorizationFromActivity(it)
                    .withScopes(scopes.toList())
                    .withPrompt(prompt)
                    .withLoginHint(loginHint)
                    .withCallback(msal.authenticationCallback(result))

                val acquireTokenParameters = builder.build()
                msal.iPublicClientApplication.acquireToken(acquireTokenParameters)
            }
        }
    }

    private fun acquireTokenSilent(
        scopes: List<String>,
        identifier: String? = null,
        result: MethodChannel.Result
    ) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire a silent token.",
                    null
                )
            }
        }

        if (msal.iSingleAccountPca != null) {
            msal.iSingleAccountPca!!.currentAccount?.let { accountResult ->
                val currentAccount = accountResult.currentAccount
                if (currentAccount != null) {
                    val builder = AcquireTokenSilentParameters.Builder()
                    builder.withScopes(scopes.toList())
                        .forAccount(currentAccount)
                        .fromAuthority(currentAccount.authority)
                        .withCallback(msal.silentAuthenticationCallback(result))
                    val acquireTokenParameters = builder.build()
                    msal.iPublicClientApplication.acquireTokenSilentAsync(acquireTokenParameters)
                } else {
                    result.error("AUTH_ERROR", "No current account is available", null)
                }
            }
        } else if (msal.iMultipleAccountPca != null) {
            msal.iMultipleAccountPca!!.getAccount(identifier!!)?.let { account ->
                val builder = AcquireTokenSilentParameters.Builder()
                builder.withScopes(scopes.toList())
                    .forAccount(account)
                    .fromAuthority(account.authority)
                    .withCallback(msal.silentAuthenticationCallback(result))
                val acquireTokenParameters = builder.build()
                msal.iPublicClientApplication.acquireTokenSilentAsync(acquireTokenParameters)
            }
        }
    }

    private fun getCurrentAccount(result: MethodChannel.Result) {
        msal.iSingleAccountPca?.getCurrentAccountAsync(msal.currentAccountCallback(result))
    }

    private fun signOut(result: MethodChannel.Result) {
        msal.iSingleAccountPca?.signOut(msal.signOutCallback(result))
    }

    private fun getAccount(identifier: String, result: MethodChannel.Result) {
        msal.iMultipleAccountPca?.getAccount(identifier, msal.accountCallback(result))
    }

    private fun getAccounts(result: MethodChannel.Result) {
        msal.iMultipleAccountPca?.getAccounts(msal.loadAccountsCallback(result))
    }

    private fun removeAccount(identifier: String, result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to remove",
                    null
                )
            }
            return
        }

        val account = msal.iMultipleAccountPca?.getAccount(identifier)
        msal.iMultipleAccountPca?.removeAccount(account, msal.removeAccountCallback(result))
    }
}