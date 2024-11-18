package com.example.msal_auth

import android.app.Activity
import android.content.Context
import android.os.Handler
import android.os.Looper
import com.microsoft.identity.client.AuthenticationCallback
import com.microsoft.identity.client.IAccount
import com.microsoft.identity.client.IAuthenticationResult
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication.GetAccountCallback
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication.RemoveAccountCallback
import com.microsoft.identity.client.IPublicClientApplication
import com.microsoft.identity.client.IPublicClientApplication.IMultipleAccountApplicationCreatedListener
import com.microsoft.identity.client.IPublicClientApplication.ISingleAccountApplicationCreatedListener
import com.microsoft.identity.client.IPublicClientApplication.LoadAccountsCallback
import com.microsoft.identity.client.ISingleAccountPublicClientApplication
import com.microsoft.identity.client.ISingleAccountPublicClientApplication.CurrentAccountCallback
import com.microsoft.identity.client.ISingleAccountPublicClientApplication.SignOutCallback
import com.microsoft.identity.client.SilentAuthenticationCallback
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.plugin.common.MethodChannel

class MsalAuth(internal val context: Context) {

    internal lateinit var activity: Activity
    lateinit var iPublicClientApplication: IPublicClientApplication
    var iSingleAccountPca: ISingleAccountPublicClientApplication? = null
    var iMultipleAccountPca: IMultipleAccountPublicClientApplication? = null

    fun setActivity(activity: Activity) {
        this.activity = activity
    }

    internal fun isClientInitialized(): Boolean = ::iPublicClientApplication.isInitialized

    internal fun singleAccountApplicationCreatedListener(result: MethodChannel.Result): ISingleAccountApplicationCreatedListener {
        return object : ISingleAccountApplicationCreatedListener {
            override fun onCreated(application: ISingleAccountPublicClientApplication) {
                iSingleAccountPca = application
                iPublicClientApplication = application
                result.success(true)
            }

            override fun onError(exception: MsalException) {
                result.error(exception.errorCode, exception.message, null)
            }
        }
    }

    internal fun multipleAccountApplicationCreatedListener(result: MethodChannel.Result): IMultipleAccountApplicationCreatedListener {
        return object : IMultipleAccountApplicationCreatedListener {
            override fun onCreated(application: IMultipleAccountPublicClientApplication) {
                iMultipleAccountPca = application
                iPublicClientApplication = application
                result.success(true)
            }

            override fun onError(exception: MsalException) {
                result.error(exception.errorCode, exception.message, null)
            }

        }
    }

    internal fun authenticationCallback(result: MethodChannel.Result): AuthenticationCallback {
        return object : AuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                setAuthenticationResult(authenticationResult, result)
            }

            override fun onError(exception: MsalException) {
                Handler(Looper.getMainLooper()).post {
                    result.error(
                        "AUTH_ERROR",
                        "Authentication failed ${exception.message}",
                        null
                    )
                }
            }

            override fun onCancel() {
                Handler(Looper.getMainLooper()).post {
                    result.error(
                        "USER_CANCELED",
                        "User has cancelled the login process",
                        null
                    )
                }
            }
        }
    }

    /**
     * Callback used in for silent acquireToken calls.
     */
    internal fun silentAuthenticationCallback(result: MethodChannel.Result): SilentAuthenticationCallback {
        return object : SilentAuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                setAuthenticationResult(authenticationResult, result)
            }

            override fun onError(exception: MsalException) {
                when (exception) {
                    is MsalUiRequiredException -> {
                        result.error("UI_REQUIRED", exception.message, null)
                    }

                    else -> {
                        result.error("AUTH_ERROR", exception.message, null)
                    }
                }
            }
        }
    }

    private fun getCurrentAccountMap(account: IAccount): Map<String, Any?> {
        return mutableMapOf<String, Any?>().apply {
            put("id", account.id)
            put("idToken", account.idToken)
            put("username", account.username)
            put("name", account.claims?.get("name"))
            put("authority", account.authority)
        }
    }

    private fun setAuthenticationResult(
        authenticationResult: IAuthenticationResult,
        result: MethodChannel.Result
    ) {
        val authResult = mutableMapOf<String, Any?>().apply {
            put("accessToken", authenticationResult.accessToken)
            put("authorizationHeader", authenticationResult.authorizationHeader)
            put("authenticationScheme", authenticationResult.authenticationScheme)
            put("expiresOn", authenticationResult.expiresOn.time)
            put("tenantId", authenticationResult.tenantId)
            put("scopes", authenticationResult.scope.toList())
            put("correlationId", authenticationResult.correlationId.toString())
            put("account", getCurrentAccountMap(authenticationResult.account))
        }

        result.success(authResult)
    }

    internal fun currentAccountCallback(result: MethodChannel.Result): CurrentAccountCallback {
        return object : CurrentAccountCallback {
            override fun onAccountLoaded(activeAccount: IAccount?) {
                if (activeAccount == null) {
                    result.error("AUTH_ERROR", "No active account is available", null)
                    return
                }
                result.success(getCurrentAccountMap(activeAccount))
            }

            override fun onAccountChanged(priorAccount: IAccount?, currentAccount: IAccount?) {
                if (currentAccount == null) {
                    result.error("AUTH_ERROR", "No current account is available", null)
                    return
                }
                result.success(getCurrentAccountMap(currentAccount))
            }

            override fun onError(exception: MsalException) {
                result.error("AUTH_ERROR", exception.message, null)
            }
        }
    }

    internal fun signOutCallback(result: MethodChannel.Result): SignOutCallback {
        return object : SignOutCallback {
            override fun onSignOut() {
                println("Sign out success==========")
                result.success(true)
            }

            override fun onError(exception: MsalException) {
                result.error("AUTH_ERROR", exception.message, null)
            }
        }
    }

    internal fun accountCallback(result: MethodChannel.Result): GetAccountCallback {
        return object : GetAccountCallback {
            override fun onTaskCompleted(account: IAccount?) {
                if (account == null) {
                    result.error("AUTH_ERROR", "No account is available", null)
                    return
                }
                result.success(getCurrentAccountMap(account))
            }

            override fun onError(exception: MsalException?) {
                result.error("AUTH_ERROR", exception?.message, null)
            }
        }
    }

    internal fun loadAccountsCallback(result: MethodChannel.Result): LoadAccountsCallback {
        return object : LoadAccountsCallback {
            override fun onTaskCompleted(accounts: MutableList<IAccount>?) {
                if (accounts.isNullOrEmpty()) {
                    result.error("AUTH_ERROR", "No account is available", null)
                    return
                }
                result.success(accounts.map { getCurrentAccountMap(it) })
            }

            override fun onError(exception: MsalException?) {
                result.error("AUTH_ERROR", exception?.message, null)
            }
        }
    }

    internal fun removeAccountCallback(result: MethodChannel.Result): RemoveAccountCallback {
        return object : RemoveAccountCallback {
            override fun onRemoved() {
                result.success(true)
            }

            override fun onError(exception: MsalException) {
                result.error("AUTH_ERROR", exception?.message, null)
            }
        }
    }

    /**
     * Load currently signed-in accounts, if there's any.
     */
    internal fun loadAccounts(result: MethodChannel.Result) {
        println("Get accounts called========")
        iMultipleAccountPca?.getAccounts(object : IPublicClientApplication.LoadAccountsCallback {

            override fun onTaskCompleted(resultList: List<IAccount>) {
                result.success(true)
            }

            override fun onError(exception: MsalException) {
                result.error(
                    "AUTH_ERROR",
                    "No account is available to acquire token silently for",
                    null
                )
            }
        })
    }
}

