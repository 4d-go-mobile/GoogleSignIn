# Google Sign In

Let user login with his Google account.

## Install

Download the latest release file [form-login-GoogleSignIn.zip](https://github.com/4d-go-mobile/form-login-GoogleSignIn/releases/latest/download/form-login-GoogleSignIn.zip) and move it in your database at path `YourDatabase.4dbase/Resources/Mobile/form/login` and then unzip it

## Configure client id

To get your `client id`, read more about configuring a Google API project at https://developers.google.com/identity/sign-in/android/start#configure-a-google-api-project

### android

⚠️ You must edit server_client_id in [android/res/values/strings.xml](https://github.com/4d-go-mobile/form-login-GoogleSignIn/blob/e40d7b44c8e5f0acdd09258286e619705914d6ad/android/res/values/strings.xml#L2) value with your `client id`.

### iOS

`CLIENT_ID` and `REVERSED_CLIENT_ID` provided by google must be filled in `manifest.json` before generating the app

If will in generated app
- add in `Settings.plist` the key `google.clientId` with value `CLIENT_ID`
- add in `Info.plist` the `REVERSED_CLIENT_ID` as url scheme by adding a `CFBundleURLSchemes` collection under `CFBundleURLTypes`

## Requirements

4D 19R8 minimum
