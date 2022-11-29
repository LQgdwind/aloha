You attempted to use the `DevAuthBackend` authentication method, which
is used for logging in without a password in the Aloha development
environment.

This backend is not supported on this server, either because:

* This Aloha server is configured as a production server.
* `DevAuthBackend` is disabled in `AUTHENTICATION_BACKENDS` in `{{
settings_path }}`.
