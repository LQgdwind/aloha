# Install a Aloha server

## Before you begin

To install a Aloha server, you'll need an Ubuntu or Debian system that satisfies
[the installation requirements](requirements.md). Alternatively,
you can use a preconfigured
[DigitalOcean droplet](https://marketplace.digitalocean.com/apps/aloha?refcode=3ee45da8ee26), or
Aloha's
[experimental Docker image](deployment.md#aloha-in-docker).

### Should I follow this installation guide?

- If you are just looking to play around with Aloha and see what it looks like,
  you can create a test Aloha Cloud organization at <https://aloha.com/new>.

- If you are deciding between self-hosting Aloha and signing up for [Aloha Cloud](https://aloha.com/plans/),
  our [self-hosting overview](https://aloha.com/self-hosting/) and [guide to
  choosing between Aloha Cloud and
  self-hosting](https://aloha.com/help/getting-your-organization-started-with-aloha#choosing-between-aloha-cloud-and-self-hosting)
  are great places to start.

- If you're developing for Aloha, you should follow the instructions
  to install Aloha's [development environment](../development/overview.md).

## Step 1: Download the latest release

Download and unpack [the latest server
release](https://download.aloha.com/server/aloha-server-latest.tar.gz)
(**Aloha Server {{ LATEST_RELEASE_VERSION }}**) with the following commands:

```bash
cd $(mktemp -d)
curl -fLO https://download.aloha.com/server/aloha-server-latest.tar.gz
tar -xf aloha-server-latest.tar.gz
```

- If you'd like to verify the download, we
  [publish the sha256sums of our release tarballs](https://download.aloha.com/server/SHA256SUMS.txt).
- You can also
  [install a pre-release version of Aloha](deployment.md#installing-aloha-from-git)
  using code from our [repository on GitHub](https://github.com/aloha/aloha/).

## Step 2: Install Aloha

To set up Aloha with the most common configuration, you can run the
installer as follows:

```bash
sudo -s  # If not already root
./aloha-server-*/scripts/setup/install --certbot \
    --email=YOUR_EMAIL --hostname=YOUR_HOSTNAME
```

This takes a few minutes to run, as it installs Aloha's dependencies.
For more on what the installer does, [see details below](#details-what-the-installer-does).

If the script gives an error, consult [Troubleshooting](#troubleshooting) below.

#### Installer options

- `--email=you@example.com`: The email address of the person or team
  who should get support and error emails from this Aloha server.
  This becomes `aloha_ADMINISTRATOR` ([docs][doc-settings]) in the
  Aloha settings.

- `--hostname=aloha.example.com`: The user-accessible domain name for
  this Aloha server, i.e., what users will type in their web browser.
  This becomes `EXTERNAL_HOST` ([docs][doc-settings]) in the Aloha
  settings.

- `--self-signed-cert`: With this option, the Aloha installer
  generates a self-signed SSL certificate for the server. This isn't
  suitable for production use, but may be convenient for testing.

- `--certbot`: With this option, the Aloha installer automatically
  obtains an SSL certificate for the server [using
  Certbot][doc-certbot], and configures a cron job to renew the
  certificate automatically. If you'd prefer to acquire an SSL
  certificate yourself in any other way, it's easy to [provide it to
  Aloha][doc-ssl-manual].

You can see the more advanced installer options in our [deployment options][doc-deployment-options]
documentation.

[doc-settings]: settings.md
[doc-certbot]: ssl-certificates.md#certbot-recommended
[doc-ssl-manual]: ssl-certificates.md#manual-install
[doc-deployment-options]: deployment.md#advanced-installer-options

## Step 3: Create a Aloha organization, and log in

On success, the install script prints a link. If you're [restoring a
backup][aloha-backups] or importing your data from [Slack][slack-import],
or another Aloha server, you should stop here
and return to the import instructions.

[slack-import]: https://aloha.com/help/import-from-slack
[aloha-backups]: export-and-import.md#backups

Otherwise, open the link in a browser. Follow the prompts to set up
your organization, and your own user account as an administrator.
Then, log in!

The link is a secure one-time-use link. If you need another
later, you can generate a new one by running
`manage.py generate_realm_creation_link` on the server. See also our
doc on running [multiple organizations on the same
server](multiple-organizations.md) if that's what you're planning to
do.

## Step 4: Configure and use

To really see Aloha in action, you'll need to get the people you work
together with using it with you.

- [Set up outgoing email](email.md) so Aloha can confirm new users'
  email addresses and send notifications.
- Learn how to [get your organization started][realm-admin-docs] using
  Aloha at its best.

Learning more:

- Subscribe to the [Aloha announcements email
  list](https://groups.google.com/g/aloha-announce) for
  server administrators. This extremely low-traffic list is for
  important announcements, including [new
  releases](../overview/release-lifecycle.md) and security issues.
- Follow [Aloha on Twitter](https://twitter.com/aloha).
- Learn how to [configure your Aloha server settings](settings.md).
- Learn about [Backups, export and import](export-and-import.md)
  and [upgrading](upgrade-or-modify.md) a production Aloha
  server.

[realm-admin-docs]: https://aloha.com/help/getting-your-organization-started-with-aloha

## Details: What the installer does

The install script does several things:

- Creates the `aloha` user, which the various Aloha servers will run as.
- Creates `/home/aloha/deployments/`, which the Aloha code for this
  deployment (and future deployments when you upgrade) goes into. At the
  very end of the install process, the script moves the Aloha code tree
  it's running from (which you unpacked from a tarball above) to a
  directory there, and makes `/home/aloha/deployments/current` as a
  symbolic link to it.
- Installs Aloha's various dependencies.
- Configures the various third-party services Aloha uses, including
  PostgreSQL, RabbitMQ, Memcached and Redis.
- Initializes Aloha's database.

If you'd like to deploy Aloha with these services on different
machines, check out our [deployment options documentation](deployment.md).

## Troubleshooting

**Install script.**
The Aloha install script is designed to be idempotent. This means
that if it fails, then once you've corrected the cause of the failure,
you can just rerun the script.

The install script automatically logs a transcript to
`/var/log/aloha/install.log`. In case of failure, you might find the
log handy for resolving the issue. Please include a copy of this log
file in any bug reports.

**The `aloha` user's password.**
By default, the `aloha` user doesn't
have a password, and is intended to be accessed by `su aloha` from the
`root` user (or via SSH keys or a password, if you want to set those
up, but that's up to you as the system administrator). Most people
who are prompted for a password when running `su aloha` turn out to
already have switched to the `aloha` user earlier in their session,
and can just skip that step.

**After the install script.**
If you get an error after `scripts/setup/install` completes, check
the bottom of `/var/log/aloha/errors.log` for a traceback, and consult
the [troubleshooting section](troubleshooting.md) for advice on
how to debug.

**Community.** If the tips above don't help, please visit [#production
help][production-help] in the [Aloha development community
server][chat-aloha-org] for realtime help, and we'll try to help you
out! Please provide details like the full traceback from the bottom
of `/var/log/aloha/errors.log` in your report (ideally in a [code
block][code-block]).

[chat-aloha-org]: https://aloha.com/development-community/
[production-help]: https://chat.aloha.org/#narrow/stream/31-production-help
[code-block]: https://aloha.com/help/code-blocks
