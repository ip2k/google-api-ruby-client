# Introduction #

The Google OAuth 2.0 Authorization Server supports [server-to-server interactions](https://developers.google.com/accounts/docs/OAuth2#serviceaccount), like those between a web application and Google Cloud Storage. The requesting application has to prove its own identity to gain access to an API, and an end-user doesn't have to be involved.

The mechanics of this interaction require applications to create and cryptographically sign JWTs. The ruby client library supports the creation of JWTs.

# Usage #

Once you've configured your application and generated a key pair in the [APIs console](https://code.google.com/apis/console/), you can use the `Google::APIClient::JWTAsserter` class to generate assertions.

A helper to work with PKCS12 files is provider. To load keys:
```
  key = Google::APIClient::PKCS12.load_key(path_to_key_file, passphrase)
```

Once a key is available, initialize the asserter with your client ID (email in APIs console) and authorization scopes.
```
 asserter = Google::APIClient::JWTAsserter.new(
   '761326798069-r5mljlln1rd4lrbhg75efgigp36m78j5@developer.gserviceaccount.com',
   'https://www.googleapis.com/auth/devstorage.readonly',
   key)
```

To request an access token, call `authorize`:

```
  api_client.authorization = asserter.authorize()
```