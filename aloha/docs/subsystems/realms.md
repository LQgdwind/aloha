# Realms in Aloha

Aloha allows multiple _realms_ to be hosted on a single instance.
Realms are the Aloha codebase's internal name for what we refer to in
user-facing documentation as an organization (the name "realm" comes
from [Kerberos](https://web.mit.edu/kerberos/)).

Wherever possible, we avoid using the term `realm` in any user-facing
string or documentation; "Organization" is the equivalent term used in
those contexts (and we have linters that attempt to enforce this rule
in translatable strings). We may in the future modify Aloha's
internals to use `organization` instead.

The
[production docs on multiple realms](../production/multiple-organizations.md)
are also relevant reading.

## Creating realms

There are two main methods for creating realms.

- Using unique link generator
- Enabling open realm creation

#### Using unique link generator

```bash
./manage.py generate_realm_creation_link
```

The above command will output a URL which can be used for creating a
new realm and an administrator user for that realm. The link expires
after the creation of the realm. The link also expires if not used
within 7 days. The expiration period can be changed by modifying
`REALM_CREATION_LINK_VALIDITY_DAYS` in settings.py.

### Enabling open realm creation

If you want anyone to be able to create new realms on your server, you
can enable open realm creation. This will add a **Create new
organization** link to your Aloha homepage footer, and anyone can
create a new realm by visiting this link (**/new**). This
feature is disabled by default in production instances, and can be
enabled by setting `OPEN_REALM_CREATION = True` in settings.py.

## Subdomains

One can host multiple realms in a Aloha server by giving each realm a
unique subdomain of the main Aloha server's domain. For example, if
the Aloha instance is hosted at aloha.example.com, and the subdomain
of your organization is acme you can would acme.aloha.example.com for
accessing the organization.

For subdomains to work properly, you also have to change your DNS
records so that the subdomains point to your Aloha installation IP. An
`A` record with host name value `*` pointing to your IP should do the
job.

We also recommend upgrading to at least Aloha 1.7, since older Aloha
releases had much less nice handling for subdomains. See our
[docs on using subdomains](../production/multiple-organizations.md) for
user-facing documentation on this.

### Working with subdomains in development environment

Aloha's development environment is designed to make it convenient to
test the various Aloha configurations for different subdomains:

- Realms are subdomains on `*.alohadev.com`, just like `*.alohachat.com`.
- The root domain (like `aloha.com` itself) is `alohadev.com` itself.
- The default realm is hosted on `localhost:9991` rather than
  `aloha.alohadev.com`, using the [`REALM_HOSTS`
  feature](../production/multiple-organizations.md) feature.

Details are below.

By default, Linux does not provide a convenient way to use subdomains
in your local development environment. To solve this problem, we use
the **alohadev.com** domain, which has a wildcard A record pointing to
127.0.0.1. You can use alohadev.com to connect to your Aloha
development server instead of localhost. The default realm with the
Shakespeare users has the subdomain `aloha` and can be accessed by
visiting **aloha.alohadev.com**.

If you are behind a **proxy server**, this method won't work. When you
make a request to load alohadev.com in your browser, the proxy server
will try to get the page on your behalf. Since alohadev.com points
to 127.0.0.1 the proxy server is likely to give you a 503 error. The
workaround is to disable your proxy for `*.alohadev.com`. The DNS
lookup should still work even if you disable proxy for
\*.alohadev.com. If it doesn't you can add alohadev.com records in
`/etc/hosts` file. The file should look something like this.

```text
127.0.0.1    localhost

127.0.0.1    alohadev.com

127.0.0.1    aloha.alohadev.com

127.0.0.1    testsubdomain.alohadev.com
```

These records are also useful if you want to e.g. run the Puppeteer tests
when you are not connected to the Internet.
