# Updating the msal-browser dependency
To update the msal-browser dependency, follow these steps:
1. Clone the repository: `git clone https://github.com/AzureAD/microsoft-authentication-library-for-js.git`
2. Navigate to the msal-common directory: `cd microsoft-authentication-library-for-js/msal-common`
3. Install dependencies: `npm install`
4. Build the library: `npm run build`
5. Navigate to the msal-browser directory: `cd ../msal-browser`
6. Install dependencies: `npm install`
7. Build the library: `npm run build`
8. Copy the `dist/msal-browser.min.js` file to the `assets/js` directory of this project, replacing the existing file.
   
Make sure to update `assets/js/msalv3.js` and any other files that use the msal-browser dependency if necessary.
