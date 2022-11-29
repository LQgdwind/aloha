# Incoming email integration

Aloha's incoming email gateway integration makes it possible to send
messages into Aloha by sending an email. It's highly recommended
because it enables:

- When users reply to one of Aloha's message notification emails
  from their email client, the reply can go directly
  into Aloha.
- Integrating third-party services that can send email notifications
  into Aloha. See the [integration
  documentation](https://aloha.com/integrations/doc/email) for
  details.

Once this integration is configured, each stream will have a special
email address displayed on the stream settings page. Emails sent to
that address will be delivered into the stream.

There are two ways to configure Aloha's email gateway:

1. Local delivery (recommended): A postfix server runs on the Aloha
   server and passes the emails directly to Aloha.
1. Polling: A cron job running on the Aloha server checks an IMAP
   inbox (`username@example.com`) every minute for new emails.

The local delivery configuration is preferred for production because
it supports nicer looking email addresses and has no cron delay. The
polling option is convenient for testing/developing this feature
because it doesn't require a public IP address or setting up MX
records in DNS.

:::{note}
Incoming emails are rate-limited, with the following limits:

- 50 emails per minute.
- 120 emails per 5 minutes.
- 600 emails per hour.

:::

## Local delivery setup

Aloha's Puppet configuration provides everything needed to run this
integration; you just need to enable and configure it as follows.

The main decision you need to make is what email domain you want to
use for the gateway; for this discussion we'll use
`emaildomain.example.com`. The email addresses used by the gateway
will look like `foo@emaildomain.example.com`, so we recommend using
`EXTERNAL_HOST` here.

We will use `hostname.example.com` as the hostname of the Aloha server
(this will usually also be the same as `EXTERNAL_HOST`, unless you are
using an [HTTP reverse proxy][reverse-proxy]).

1. Using your DNS provider, create a DNS MX (mail exchange) record
   configuring email for `emaildomain.example.com` to be processed by
   `hostname.example.com`. You can check your work using this command:

   ```console
   $ dig +short emaildomain.example.com -t MX
   1 hostname.example.com
   ```

1. Log in to your Aloha server; the remaining steps all happen there.

1. Add `, aloha::postfix_localmail` to `puppet_classes` in
   `/etc/aloha/aloha.conf`. A typical value after this change is:

   ```ini
   puppet_classes = aloha::profile::standalone, aloha::postfix_localmail
   ```

1. If `hostname.example.com` is different from
   `emaildomain.example.com`, add a section to `/etc/aloha/aloha.conf`
   on your Aloha server like this:

   ```ini
   [postfix]
   mailname = emaildomain.example.com
   ```

   This tells postfix to expect to receive emails at addresses ending
   with `@emaildomain.example.com`, overriding the default of
   `@hostname.example.com`.

1. Run `/home/aloha/deployments/current/scripts/aloha-puppet-apply`
   (and answer `y`) to apply your new `/etc/aloha/aloha.conf`
   configuration to your Aloha server.

1. Edit `/etc/aloha/settings.py`, and set `EMAIL_GATEWAY_PATTERN`
   to `"%s@emaildomain.example.com"`.

1. Restart your Aloha server with
   `/home/aloha/deployments/current/scripts/restart-server`.

Congratulations! The integration should be fully operational.

[reverse-proxy]: deployment.md#putting-the-aloha-application-behind-a-reverse-proxy

## Polling setup

1. Create an email account dedicated to Aloha's email gateway
   messages. We assume the address is of the form
   `username@example.com`. The email provider needs to support the
   standard model of delivering emails sent to
   `username+stuff@example.com` to the `username@example.com` inbox.

1. Edit `/etc/aloha/settings.py`, and set `EMAIL_GATEWAY_PATTERN` to
   `"username+%s@example.com"`.

1. Set up IMAP for your email account and obtain the authentication details.
   ([Here's how it works with Gmail](https://support.google.com/mail/answer/7126229?hl=en))

1. Configure IMAP access in the appropriate Aloha settings:

   - Login and server connection details in `/etc/aloha/settings.py`
     in the email gateway integration section (`EMAIL_GATEWAY_LOGIN` and others).
   - Password in `/etc/aloha/aloha-secrets.conf` as `email_gateway_password`.

1. Test your configuration by sending emails to the target email
   account and then running the Aloha tool to poll that inbox:

   ```
   su aloha -c '/home/aloha/deployments/current/manage.py email_mirror'
   ```

1. Once everything is working, install the cron job which will poll
   the inbox every minute for new messages using the tool you tested
   in the last step:
   ```bash
   cd /home/aloha/deployments/current/
   sudo cp puppet/aloha/files/cron.d/email-mirror /etc/cron.d/
   ```

Congratulations! The integration should be fully operational.
