package com.example.msal_auth

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.google.gson.Gson
import com.microsoft.identity.client.AuthenticationCallback
import com.microsoft.identity.client.IAuthenticationResult
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication
import com.microsoft.identity.client.IPublicClientApplication.IMultipleAccountApplicationCreatedListener
import com.microsoft.identity.client.IPublicClientApplication.ISingleAccountApplicationCreatedListener
import com.microsoft.identity.client.ISingleAccountPublicClientApplication
import com.microsoft.identity.client.SilentAuthenticationCallback
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class Msal(context: Context, internal var activity: FlutterActivity?) {
    internal val applicationContext = context


    fun setActivity(activity: FlutterActivity) {
        this.activity = activity
    }

    internal fun getMultipleAccountApplicationCreatedListener(
        onCreated: (IMultipleAccountPublicClientApplication) -> Unit,
        result: MethodChannel.Result
    ): IMultipleAccountApplicationCreatedListener {

        return object : IMultipleAccountApplicationCreatedListener {
            override fun onCreated(application: IMultipleAccountPublicClientApplication) {
                onCreated(application)
                Handler(Looper.getMainLooper()).post {
                    result.success(true)
                }
            }

            override fun onError(exception: MsalException?) {
                result.error("AUTH_ERROR", exception?.message, null)
            }
        }
    }

    internal fun getSingleAccountApplicationCreatedListener(
        onCreated: (ISingleAccountPublicClientApplication) -> Unit,
        result: MethodChannel.Result
    ): ISingleAccountApplicationCreatedListener {

        return object : ISingleAccountApplicationCreatedListener {
            override fun onCreated(application: ISingleAccountPublicClientApplication) {
                onCreated(application)
                Handler(Looper.getMainLooper()).post {
                    result.success(true)
                }
            }

            override fun onError(exception: MsalException?) {
                result.error("AUTH_ERROR", exception?.message, null)
            }
        }
    }

    internal fun getAuthCallback(result: MethodChannel.Result): AuthenticationCallback {
        return object : AuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Handler(Looper.getMainLooper()).post {
                    val accountMap = mutableMapOf<String, Any?>()
                    authenticationResult.account.claims?.let { accountMap.putAll(it) }
                    accountMap["access_token"] = authenticationResult.accessToken
                    accountMap["id_token"] = authenticationResult.getAccount().getIdToken()
                    accountMap["exp"] = authenticationResult.expiresOn.time
                    result.success(Gson().toJson(accountMap))
                }
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
    internal fun getAuthSilentCallback(result: MethodChannel.Result): SilentAuthenticationCallback {
        return object : SilentAuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Handler(Looper.getMainLooper()).post {
                    val accountMap = mutableMapOf<String, Any?>()
                    authenticationResult.account.claims?.let { accountMap.putAll(it) }
                    accountMap["access_token"] = authenticationResult.accessToken
                    accountMap["id_token"] = authenticationResult.getAccount().getIdToken()
                    accountMap["exp"] = authenticationResult.expiresOn.time
                    result.success(Gson().toJson(accountMap))
                }
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
}


