package com.example.msal_auth

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.microsoft.identity.client.AcquireTokenParameters
import com.microsoft.identity.client.AcquireTokenSilentParameters
import com.microsoft.identity.client.IAccount
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication
import com.microsoft.identity.client.IPublicClientApplication
import com.microsoft.identity.client.ISingleAccountPublicClientApplication
import com.microsoft.identity.client.ISingleAccountPublicClientApplication.CurrentAccountCallback
import com.microsoft.identity.client.Prompt
import com.microsoft.identity.client.PublicClientApplication
import com.microsoft.identity.client.SignInParameters
import com.microsoft.identity.client.SingleAccountPublicClientApplication
import com.microsoft.identity.client.exception.MsalException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.Locale

class MsalAuthImpl(private val msal: Msal) : MethodChannel.MethodCallHandler {
    private val mTAG = "MsalAuthImpl"
    private var channel: MethodChannel? = null
    private var loginHint: String? = null
    private lateinit var msalAuth: MsalAuth

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
        val publicClientAppAccountType: String? = call.argument("publicClientAppAccountType")
        loginHint = call.argument("loginHint")

        when (call.method) {
            "initialize" -> Thread {
                initialize(
                    publicClientAppAccountType,
                    configFilePath,
                    result
                )
            }.start()

            "loadAccounts" -> Thread { handleLoadAccounts(result) }.start()
            "loadAccount" -> Thread { handleLoadAccount(result) }.start()
            "login" -> Thread { handleLogin(scopes, result) }.start()
            "acquireToken" -> Thread { handleAcquireToken(scopes, result) }.start()
            "acquireTokenSilent" -> Thread {
                handleAcquireTokenSilent(
                    scopes,
                    result
                )
            }.start()

            "logout" -> Thread { msalAuth.logout(result) }.start()
            else -> result.notImplemented()
        }
    }

    private fun isInitialised(): Boolean {
        return ::msalAuth.isInitialized
    }

    private fun handleLoadAccount(result: MethodChannel.Result) {

        if (!isInitialised()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Must initialize before attempting to load account.",
                    null
                )
            }
            return
        } else {
            msalAuth.getAccount(result)
        }
    }

    private fun handleLoadAccounts(result: MethodChannel.Result) {
        if (!isInitialised()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Must initialize before attempting to load accounts.",
                    null
                )
            }
            return
        } else {
            msalAuth.getAccounts(result)
        }
    }

    private fun handleLogin(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isInitialised()) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Must initialize before attempting to login.", null)
            }
            return
        } else {
            msalAuth.login(scopes, result)
        }
    }

    private fun handleAcquireToken(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isInitialised()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Must initialize before attempting to acquire token.",
                    null
                )
            }
            return
        } else {
            msalAuth.acquireToken(
                scopes,
                result
            )
        }
    }

    private fun handleAcquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isInitialised()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Must initialize before attempting to acquire token silently.",
                    null
                )
            }
            return
        } else {
            msalAuth.acquireTokenSilent(
                scopes,
                result
            )
        }
    }

    private fun isAccountModeValid(accountMode: String?): Boolean {
        return if (accountMode == null) {
            false
        } else if (accountMode == "singleAccount" && msalAuth is MsalAuthMultipleAccount) {
            false
        } else if (accountMode == "multipleAccount" && msalAuth is MsalAuthSingleAccount) {
            false
        } else {
            true
        }
    }


    private fun initialize(
        accountMode: String?,
        configFilePath: String?,
        result: MethodChannel.Result
    ) {
        if (isInitialised()) {
            if (!isAccountModeValid(accountMode)) {
                Handler(Looper.getMainLooper()).post {
                    result.error(
                        "AUTH_ERROR",
                        "Cannot change public client app account type after initialisation",
                        null
                    )
                }
                return
            } else {
                Handler(Looper.getMainLooper()).post {
                    result.success(true)
                }
                return
            }
        }
        if (accountMode == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Public client app type not set", null)
            }
            return
        }

        when (accountMode) {
            "singleAccount" -> {
                msalAuth = MsalAuthSingleAccount(msal, loginHint)
            }

            "multipleAccount" -> {
                msalAuth = MsalAuthMultipleAccount(msal, loginHint)
            }

            else -> {
                Handler(Looper.getMainLooper()).post {
                    result.error("AUTH_ERROR", "Invalid public application client app type", null)
                }
                return
            }
        }

        msalAuth.initialize(configFilePath, result)
    }

}

interface MsalAuth {
    fun login(scopes: Array<String>?, result: MethodChannel.Result)
    fun getAccount(result: MethodChannel.Result)
    fun getAccounts(result: MethodChannel.Result)
    fun logout(result: MethodChannel.Result)
    fun acquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result)
    fun acquireToken(scopes: Array<String>?, result: MethodChannel.Result)
    fun initialize(configFilePath: String?, result: MethodChannel.Result)
}

class MsalAuthMultipleAccount(private val msal: Msal, private val loginHint: String?) :
    MsalAuth {
    private lateinit var accountList: List<IAccount>
    private lateinit var clientApplication: IMultipleAccountPublicClientApplication

    private fun isClientInitialized(): Boolean = ::clientApplication.isInitialized


    override fun login(scopes: Array<String>?, result: MethodChannel.Result) {
        Handler(Looper.getMainLooper()).post {
            result.error(
                "AUTH_ERROR",
                "Login not implemented for multiple account public client application",
                null
            )
        }
    }

    override fun getAccount(result: MethodChannel.Result) {
        Handler(Looper.getMainLooper()).post {
            result.error(
                "AUTH_ERROR",
                "Load account not implemented for multiple account public client application",
                null
            )
        }
    }

    override fun getAccounts(result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to load accounts.",
                    null,
                )
            }
            return
        }
        clientApplication.getAccounts(
            object : IPublicClientApplication.LoadAccountsCallback {

                override fun onTaskCompleted(resultList: List<IAccount>) {
                    accountList = resultList
                    result.success(true)
                }

                override fun onError(exception: MsalException) {
                    result.error(
                        "AUTH_ERROR",
                        "No account is available to acquire token silently for",
                        null
                    )
                }
            }
        )
    }

    override fun logout(result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to logout",
                    null,
                )
            }
            return
        }
        if (accountList.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "No account is available to logout", null)
            }
            return
        }

        clientApplication.removeAccount(
            accountList.first(),
            object : IMultipleAccountPublicClientApplication.RemoveAccountCallback {
                override fun onRemoved() {
                    Thread { getAccounts(result) }.start()
                }

                override fun onError(exception: MsalException) {
                    result.error("AUTH_ERROR", exception.message, exception.stackTrace)
                }
            }
        )
    }

    override fun acquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire token silently",
                    null,
                )
            }
            return
        }
        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Call must have the scopes", null)
            }
            return
        }

        // ensures that accounts are exist
        if (accountList.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "No account is available to acquire token silently",
                    null
                )
            }
            return
        }

        val selectedAccount: IAccount = accountList.first()
        // acquire the token and return the result
        scopes.map { s -> s.lowercase(Locale.ROOT) }.toTypedArray()

        val builder = AcquireTokenSilentParameters.Builder()
        builder.withScopes(scopes.toList())
            .forAccount(selectedAccount)
            .fromAuthority(selectedAccount.authority)
            .withCallback(msal.getAuthSilentCallback(result))
        val acquireTokenParameters = builder.build()
        clientApplication.acquireTokenSilentAsync(acquireTokenParameters)
    }

    override fun acquireToken(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire token",
                    null,
                )
            }
            return
        }

        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Call must include a scope", null)
            }
            return
        }


        // remove old accounts
        while (clientApplication.accounts.any()) clientApplication.removeAccount(
            clientApplication.accounts.first()
        )

        // acquire the token

        msal.activity.let {
            val builder = AcquireTokenParameters.Builder()
            builder.startAuthorizationFromActivity(it?.activity)
                .withScopes(scopes.toList())
                .withPrompt(Prompt.LOGIN)
                .withCallback(msal.getAuthCallback(result))
                .withLoginHint(loginHint)

            val acquireTokenParameters = builder.build()
            clientApplication.acquireToken(acquireTokenParameters)
        }
    }

    override fun initialize(configFilePath: String?, result: MethodChannel.Result) {

        if (isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.success(true)
            }
            return
        }

        PublicClientApplication.createMultipleAccountPublicClientApplication(
            msal.applicationContext,
            File(configFilePath!!),
            msal.getMultipleAccountApplicationCreatedListener(onCreated = { publicClientApp ->
                clientApplication = publicClientApp
            }, result = result)
        )
    }
}

class MsalAuthSingleAccount(private val msal: Msal, private val loginHint: String?) :
    MsalAuth {
    private var currentAccount: IAccount? = null
    private lateinit var clientApplication: ISingleAccountPublicClientApplication

    private fun isClientInitialized(): Boolean = ::clientApplication.isInitialized


    override fun getAccount(result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to load account.",
                    null,
                )
            }
            return
        }
        clientApplication.getCurrentAccountAsync(
            object : CurrentAccountCallback {
                override fun onAccountLoaded(activeAccount: IAccount?) {
                    currentAccount = activeAccount
                    result.success(true)
                }

                override fun onAccountChanged(priorAccount: IAccount?, newAccount: IAccount?) {
                    currentAccount = newAccount
                    result.success(true)
                }

                override fun onError(exception: MsalException) {
                    result.error("AUTH_ERROR", exception.message, exception.stackTrace)
                }
            }
        )
    }

    override fun getAccounts(result: MethodChannel.Result) {
        result.error(
            "AUTH_ERROR",
            "Load accounts not implemented for single account public client application",
            null
        )
    }

    override fun login(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to login.",
                    null,
                )
            }
            return
        }

        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Call must include a scope", null)
            }
            return
        }

        if (currentAccount != null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Logged in account exists", null)
            }
            return
        }

        msal.activity.let {
            val builder = SignInParameters.builder()

            builder.withActivity(it!!.activity)
                .withScopes(scopes.toList())
                .withPrompt(Prompt.LOGIN)
                .withCallback(msal.getAuthCallback(result))
                .withLoginHint(loginHint)

            val signInParameters = builder.build()
            clientApplication.signIn(
                signInParameters
            )
        }
    }

    override fun logout(result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to logout.",
                    null,
                )
            }
            return
        }
        if (currentAccount == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "No account is available to logout", null)
            }
            return
        }

        clientApplication.signOut()
    }

    override fun acquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire token silently.",
                    null,
                )
            }
            return
        }

        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Call must have the scopes", null)
            }
            return
        }

        // ensures that account exists
        if (currentAccount == null) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "No account is available to acquire token silently",
                    null
                )
            }
            return
        }

        // acquire the token and return the result
        scopes.map { s -> s.lowercase(Locale.ROOT) }.toTypedArray()

        val builder = AcquireTokenSilentParameters.Builder()
        builder.withScopes(scopes.toList())
            .forAccount(currentAccount)
            .fromAuthority(currentAccount!!.authority)
            .withCallback(msal.getAuthSilentCallback(result))
        val acquireTokenParameters = builder.build()
        clientApplication.acquireTokenSilentAsync(acquireTokenParameters)
    }

    override fun acquireToken(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "AUTH_ERROR",
                    "Client must be initialized before attempting to acquire token.",
                    null,
                )
            }
            return
        }
        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "Call must include a scope", null)
            }
            return
        }

        if (currentAccount == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("AUTH_ERROR", "No account is available to acquire token", null)
            }
            return
        }

        msal.activity.let {
            val builder = AcquireTokenParameters.Builder()
            builder.startAuthorizationFromActivity(it?.activity)
                .forAccount(currentAccount)
                .withScopes(scopes.toList())
                .withPrompt(Prompt.LOGIN)
                .withCallback(msal.getAuthCallback(result))
                .withLoginHint(loginHint)

            val acquireTokenParameters = builder.build()
            clientApplication.acquireToken(acquireTokenParameters)
        }
    }

    override fun initialize(configFilePath: String?, result: MethodChannel.Result) {
        if (isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.success(true)
            }
            return
        }

        PublicClientApplication.createSingleAccountPublicClientApplication(
            msal.applicationContext,
            File(configFilePath!!),
            msal.getSingleAccountApplicationCreatedListener(
                onCreated = { v -> clientApplication = v },
                result
            )
        )
    }
}
