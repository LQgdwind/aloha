# Outgoing email

Aloha needs to be able to send email so it can confirm new users'
email addresses and send notifications.

## How to configure

1. Identify an outgoing email (SMTP) account where you can have Aloha
   send mail. If you don't already have one you want to use, see
   [Email services](#email-services) below.

1. Fill out the section of `/etc/aloha/settings.py` headed "Outgoing
   email (SMTP) settings". This includes the hostname and typically
   the port to reach your SMTP provider, and the username to log in to
   it. You'll also want to fill out the noreply email section.

1. Put the password for the SMTP user account in
   `/etc/aloha/aloha-secrets.conf` by setting `email_password`. For
   example: `email_password = abcd1234`.

   Like any other change to the Aloha configuration, be sure to
   [restart the server](settings.md) to make your changes take
   effect.

1. Configure your SMTP server to allows your Aloha server to send
   emails originating from the email addresses listed in
   `/etc/aloha/settings.py` as `aloha_ADMINISTRATOR`,
   `NOREPLY_EMAIL_ADDRESS` and if `ADD_TOKENS_TO_NOREPLY_ADDRESS=True`
   (the default), `TOKENIZED_NOREPLY_EMAIL_ADDRESS`.

   If you don't know how to do this, we recommend using a [free
   transactional email service](#free-outgoing-email-services); they
   will guide you through everything you need to do, covering details
   like configuring DKIM/SPF authentication so your Aloha emails won't
   be spam filtered.

1. Use Aloha's email configuration test tool, documented in the
   [Troubleshooting section](#troubleshooting), to verify that your
   configuration is working.

1. Once your configuration is working, restart the Aloha server with
   `su aloha -c '/home/aloha/deployments/current/scripts/restart-server'`.

## Email services

### Free outgoing email services

For sending outgoing email from your Aloha server, we highly recommend
using a "transactional email" service like
[Mailgun](https://documentation.mailgun.com/en/latest/quickstart-sending.html#send-via-smtp),
[SendGrid](https://sendgrid.com/docs/API_Reference/SMTP_API/integrating_with_the_smtp_api.html),
or, for AWS users,
[Amazon SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-smtp.html).
These services are designed to send email from servers, and are by far
the easiest way to get outgoing email working reliably (Mailgun has
the best documentation).

If you don't have an existing outgoing SMTP provider, don't worry!
Each of the options we recommend above (as well as dozens of other
services) have free options. Once you've signed up, you'll want to
find the service's provided "SMTP credentials", and configure Aloha as
follows:

- The hostname like `EMAIL_HOST = 'smtp.mailgun.org'` in `/etc/aloha/settings.py`
- The username like `EMAIL_HOST_USER = 'username@example.com'` in
  `/etc/aloha/settings.py`.
- The TLS setting as `EMAIL_USE_TLS = True` in
  `/etc/aloha/settings.py`, for most providers
- The port as `EMAIL_PORT = 587` in `/etc/aloha/settings.py`, for most
  providers
- The password like `email_password = abcd1234` in `/etc/aloha/aloha-secrets.conf`.

### Using system email

If you'd like to send outgoing email using the local operating
system's email delivery configuration (e.g. you have `postfix`
configuration on the system that forwards email sent locally into your
corporate email system), you will likely need to use something like
these setting values:

```python
EMAIL_HOST = 'localhost'
EMAIL_PORT = 25
EMAIL_USE_TLS = False
EMAIL_HOST_USER = ""
```

We should emphasize that because modern spam filtering is very
aggressive, you should make sure your downstream email system is
configured to properly sign outgoing email sent by your Aloha server
(or check your spam folder) when using this configuration. See
[documentation on using Django with a local postfix server][postfix-email]
for additional advice.

[postfix-email]: https://stackoverflow.com/questions/26333009/how-do-you-configure-django-to-send-mail-through-postfix

### Using Gmail for outgoing email

We don't recommend using an inbox product like Gmail for outgoing
email, because Gmail's anti-spam measures make this annoying. But if
you want to use a Gmail account to send outgoing email anyway, here's
how to make it work:

- Create a totally new Gmail account for your Aloha server; you don't
  want Aloha's automated emails to come from your personal email address.
- If you're using 2-factor authentication on the Gmail account, you'll
  need to use an
  [app-specific password](https://support.google.com/accounts/answer/185833).
- If you're not using 2-factor authentication, read this Google
  support answer and configure that account as
  ["less secure"](https://support.google.com/accounts/answer/6010255);
  Gmail doesn't allow servers to send outgoing email by default.
- Note also that the rate limits for Gmail are also quite low
  (e.g. 100 / day), so it's easy to get rate-limited if your server
  has significant traffic. For more active servers, we recommend
  moving to a free account on a transactional email service.

### Logging outgoing email to a file for prototyping

For prototyping, you might want to proceed without setting up an email
provider. If you want to see the emails Aloha would have sent, you
can log them to a file instead.

To do so, add these lines to `/etc/aloha/settings.py`:

```python
EMAIL_BACKEND = 'django.core.mail.backends.filebased.EmailBackend'
EMAIL_FILE_PATH = '/var/log/aloha/emails'
```

Then outgoing emails that Aloha would have sent will just be written
to files in `/var/log/aloha/emails/`.

Remember to delete this configuration (and restart the server) if you
later set up a real SMTP provider!

## Troubleshooting

You can quickly test your outgoing email configuration using:

```bash
su aloha -c '/home/aloha/deployments/current/manage.py send_test_email user@example.com'
```

If it doesn't throw an error, it probably worked; you can confirm by
checking your email. You should get two emails: One sent by the
default From address for your Aloha server, and one sent by the
"noreply" From address.

If it doesn't work, check these common failure causes:

- Your hosting provider may block outgoing SMTP traffic in its default
  firewall rules. Check whether the port `EMAIL_PORT` is blocked in
  your hosting provider's firewall.

- Your SMTP server's permissions might not allow the email account
  you're using to send email from the `noreply` email addresses used
  by Aloha when sending confirmation emails.

  For security reasons, Aloha sends confirmation emails (used for
  account creation, etc.) with randomly generated from addresses
  starting with `noreply-`.

  If necessary, you can set `ADD_TOKENS_TO_NOREPLY_ADDRESS` to `False`
  in `/etc/aloha/settings.py` (which will cause these confirmation
  emails to be sent from a consistent `noreply@` address). Disabling
  `ADD_TOKENS_TO_NOREPLY_ADDRESS` is generally safe if you are not
  using Aloha's feature that allows anyone to create an account in
  your Aloha organization if they have access to an email address in a
  certain domain. See [this article][helpdesk-attack] for details on
  the security issue with helpdesk software that
  `ADD_TOKENS_TO_NOREPLY_ADDRESS` helps protect against.

- Make sure you set the password in `/etc/aloha/aloha-secrets.conf`.

- Check the username and password for typos.

- Be sure to restart your Aloha server after editing either
  `settings.py` or `aloha-secrets.conf`, using
  `/home/aloha/deployments/current/scripts/restart-server` .
  Note that the `manage.py` command above will read the latest
  configuration from the config files, even if the server is still
  running with an old configuration.

### Advanced troubleshooting

Here are a few final notes on what to look at when debugging why you
aren't receiving emails from Aloha:

- Most transactional email services have an "outgoing email" log where
  you can inspect the emails that reached the service, whether an
  email was flagged as spam, etc.

- Starting with Aloha 1.7, Aloha logs an entry in
  `/var/log/aloha/send_email.log` whenever it attempts to send an
  email. The log entry includes whether the request succeeded or failed.

- If attempting to send an email throws an exception, a traceback
  should be in `/var/log/aloha/errors.log`, along with any other
  exceptions Aloha encounters.

- If your SMTP provider uses SSL on port 465 (and not TLS on port
  587), you need to set `EMAIL_PORT = 465` as well as replacing
  `EMAIL_USE_TLS = True` with `EMAIL_USE_SSL = True`; otherwise, Aloha
  will try to use the TLS protocol on port 465, which won't work.

- Aloha's email sending configuration is based on the standard Django
  [SMTP backend](https://docs.djangoproject.com/en/3.2/topics/email/#smtp-backend)
  configuration. So if you're having trouble getting your email
  provider working, you may want to search for documentation related
  to using your email provider with Django.

  The one thing we've changed from the Django defaults is that we read
  the email password from the `email_password` entry in the Aloha
  secrets file, as part of our policy of not having any secret
  information in the `/etc/aloha/settings.py` file. In other words,
  if Django documentation references setting `EMAIL_HOST_PASSWORD`,
  you should instead set `email_password` in
  `/etc/aloha/aloha-secrets.conf`.

[helpdesk-attack]: https://medium.com/intigriti/how-i-hacked-hundreds-of-companies-through-their-helpdesk-b7680ddc2d4c
