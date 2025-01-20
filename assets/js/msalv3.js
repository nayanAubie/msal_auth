// This code is adapted from https://github.com/earlybyte/aad_oauth
// Copyright (c) 2020 Earlybyte GmbH
// Licensed under the MIT License

// Needs to be a var at the top level to get hoisted to global scope.
// https://stackoverflow.com/questions/28776079/do-let-statements-create-properties-on-the-global-object/28776236#28776236

var msalAuth = (function () {
  let msalObject = null;
  let redirectHandlerTask = null;

  async function init(config) {
    var authData = {
      clientId: config.clientId,
      authority: config.isB2C
        ? `https://${config.tenant}.b2clogin.com/tfp/${config.tenant}.onmicrosoft.com/${config.policy}/`
        : `https://login.microsoftonline.com/${config.tenant}`,
      knownAuthorities: [
        `${config.tenant}.b2clogin.com`,
        "login.microsoftonline.com",
      ],
      redirectUri: config.redirectUri,
    };
    var msalConfig = {
      auth: authData,
      cache: {
        cacheLocation: config.cacheLocation,
        storeAuthStateInCookie: false,
      },
    };

    msalObject =
      await msal.PublicClientApplication.createPublicClientApplication(
        msalConfig
      );

    // Register Callbacks for Redirect flow and record the task so we
    // can await its completion in the login API
    redirectHandlerTask = msalObject.handleRedirectPromise();
  }

  async function acquireToken(scopes, prompt, loginHint, useRedirect) {
    let parameters = {
      scopes: scopes,
      prompt: prompt,
      loginHint: loginHint,
    };

    if (useRedirect) {
      msalObject.acquireTokenRedirect(parameters);
    } else {
      return await msalObject.loginPopup(parameters);
    }
  }

  // Tries to silently acquire a token. Will return null if a token
  // could not be acquired or if no cached account credentials exist.
  // Will return the authentication result on success.
  async function acquireTokenSilent(scopes, identifier) {
    // The redirect handler task will complete with auth results if we
    // were redirected from AAD. If not, it will complete with null
    // We must wait for it to complete before we attempt to acquire a token silently.
    let result = await redirectHandlerTask;
    if (result !== null) {
      return result;
    }

    const account = getAccount(identifier);
    if (account == null) {
      return null;
    }

    const silentAuthResult = await msalObject.acquireTokenSilent({
      scopes: scopes,
      prompt: "none",
      account: account,
    });

    return silentAuthResult;
  }

  function getAccount(identifier) {
    const accountFilter = {
      homeAccountId: identifier,
    };
    return msalObject.getAccount(accountFilter);
  }

  function getAccounts() {
    return msalObject.getAllAccounts();
  }

  async function logout(identifier) {
    const account = getAccount(identifier);

    if (!account) {
      return;
    }

    await msalObject.logoutRedirect({
      account: account,
      onRedirectNavigate: (_) => {
        return false;
      },
    });
  }

  return {
    init: init,
    acquireToken: acquireToken,
    acquireTokenSilent: acquireTokenSilent,
    getAccount: getAccount,
    getAccounts: getAccounts,
    logout: logout,
  };
})();
