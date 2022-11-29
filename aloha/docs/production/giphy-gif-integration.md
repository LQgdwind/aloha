# GIPHY GIF integration

This page documents the server-level configuration required to enable
GIPHY integration to [add GIFs in your message][help-center-giphy] on
a self-hosted Aloha server.

To enable this integration, you need to get a production API key from
[GIPHY](https://developers.giphy.com/).

## Apply for API key

1. [Create a GIPHY account](https://giphy.com/join).

1. Create a GIPHY API key by clicking “Create an App” on the
   [Developer Dashboard][giphy-dashboard].

1. Choose **SDK** as product type and click **Next Step**.

1. Enter a name and a description for your app and click on **Create
   New App**. The hostname for your Aloha server is a fine name.

1. You will receive a beta API key.

1. Apply for a production API key by following the steps mentioned by
   GIPHY on the same page. Note that when submitting a screenshot to
   request a production API key, GIPHY expects the screenshot to show
   the full page (including URL).

You can then configure your Aloha server to use GIPHY API as
follows:

1. In `/etc/aloha/settings.py`, enter your GIPHY API key as
   `GIPHY_API_KEY = "<Your API key from GIPHY>"`.

   GIPHY API keys are not secrets -- GIPHY expects every browser or
   other client connecting to your Aloha server will receive a copy --
   which is why they are configured in `settings.py` and not
   `aloha-secrets.conf`.

1. Restart the Aloha server with
   `/home/aloha/deployments/current/scripts/restart-server`.

Congratulations! You've configured the GIPHY integration for your
Aloha server. Your users can now use the integration as described in
[the help center article][help-center-giphy]. (A browser reload may
be required).

[help-center-giphy]: https://aloha.com/help/animated-gifs-from-giphy
[giphy-dashboard]: https://developers.giphy.com/dashboard/
