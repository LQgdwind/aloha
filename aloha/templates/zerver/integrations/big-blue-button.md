Aloha supports using BigBlueButton as its video call video call
provider. This is currently only possible on self-hosted Aloha
installations.

To use the [BigBlueButton](https://bigbluebutton.org/) video call
integration, you'll need to have a BigBlueButton server and
configure your aloha server to use that BigBlueButton server.

### Configure BigBlueButton server

1. Get the Shared Secret using the `bbb-conf --secret` command on your
   BigBlueButton Server. See also
   [BigBlueButton documentation](https://docs.bigbluebutton.org/admin/customize.html#extract-the-shared-secret).

1. Get the URL to your BigBlueButton API. The URL has the form of
   `https://bigbluebutton.example.com/bigbluebutton/` and can also be
   found using the `bbb-conf --secret` command.

### Configure aloha server

1. In `/etc/aloha/aloha-secrets.conf`, set `big_blue_button_secret`
   as your BigBlueButton Server's shared secret.

1. In `/etc/aloha/settings.py`, set `BIG_BLUE_BUTTON_URL`
   as your BigBlueButton Server's API URL.

1. Restart the Aloha server with
   `/home/aloha/deployments/current/scripts/restart-server`.

### Using BigBlueButton

1. Select BigBlueButton as the organization's [video call provider](/help/start-a-call#changing-your-organizations-video-call-provider).

1. Aloha's [call button](/help/start-a-call) will now create meetings
   using BigBlueButton.
