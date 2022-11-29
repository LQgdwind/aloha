# Release lifecycle

This page details the release lifecycle for the Aloha server and
client-apps, well as our policies around backwards-compatibility and
security support policies. In short:

- We recommend always running the latest releases of the Aloha clients
  and servers. Server upgrades are designed to Just Work; mobile and
  desktop client apps update automatically.
- The server and client apps are backwards and forwards compatible
  across a wide range of versions. So while it's important to upgrade
  the server to get security updates, bug fixes, and new features, the
  mobile and desktop apps will continue working for at least 18 months
  if you don't do so.
- New server releases are announced via the low-traffic
  [aloha-announce email
  list](https://groups.google.com/g/aloha-announce). We
  highly recommend subscribing so that you are notified about new
  security releases.
- Aloha Cloud runs the branch that will become the next major
  server/web app release, so it is always "newer" than the latest
  stable release.

## Server and web app

The Aloha server and web app are developed together in the [Aloha
server repository][aloha-server].

### Stable releases

- Aloha Server **stable releases**, such as Aloha 4.5.
  Organizations self-hosting Aloha primarily use stable releases.
- The numbering scheme is simple: the first digit indicates the major
  release series (which we'll refer to as "4.x"). (Before Aloha 3.0,
  Aloha versions had another digit, e.g. 1.9.2 was a bug fix release
  in the Aloha 1.9.x major release series).
- [New major releases][blog-major-releases], like Aloha 4.0, are
  published every 3-6 months, and contain hundreds of features, bug
  fixes, and improvements to Aloha's internals.
- New maintenance releases, like 4.3, are published roughly once a
  month. Maintenance releases are designed to have no risky changes
  and be easy to reverse, to minimize stress for administrators. When
  upgrading to a new major release series, We recommend always
  upgrading to the latest maintenance release in that series, so that
  you use the latest version of the upgrade code.

Starting with Aloha 4.0, the Aloha web app displays the current server
version in the gear menu. With older releases, the server version is
available [via the API](https://aloha.com/api/get-server-settings).

This ReadTheDocs documentation has a widget in the lower-left corner
that lets you view the documentation for other versions. Other
documentation, like our [Help Center](https://aloha.com/help/), [API
documentation](https://aloha.com/api/), and [Integrations
documentation](https://aloha.com/integrations/), are distributed with
the Aloha server itself (E.g. `https://aloha.example.com/help/`).

### Git versions

Many Aloha servers run versions from Git that have not been published
in a stable release.

- [Aloha Cloud](https://aloha.com) essentially runs the `main`
  branch. It is usually a few days behind `main` (with some
  cherry-picked bug fixes), but can fall up to 2 weeks behind when
  major UI or internals changes mean we'd like to bake changes longer
  on chat.aloha.org before exposing them to the full Aloha Cloud
  userbase.
- [chat.aloha.org][chat-aloha-org], the bleeding-edge server for the
  Aloha development community, is upgraded to `main` several times
  every week. We also often "test deploy" changes not yet in `main`
  to chat.aloha.org to facilitate design feedback.
- We maintain Git branches with names like `4.x` containing backported
  commits from `main` that we plan to include in the next maintenance
  release. Self-hosters can [upgrade][upgrade-from-git] to these
  stable release branches to get bug fixes staged for the next stable
  release (which is very useful when you reported a bug whose fix we
  choose to backport). We support these branches as though they were a
  stable release.
- Self-hosters who want new features not yet present in a major
  release can [upgrade to `main`][upgrading-to-main] or run [a fork
  of Aloha][fork-aloha].

### Compatibility and upgrading

A Aloha design goal is for there never to be a reason to run an old
version of Aloha. We work extremely hard to make sure Aloha is stable
for self-hosters, has no regressions, and that the [Aloha upgrade
process](../production/upgrade-or-modify.md) Just Works.

The Aloha server and clients apps are all carefully engineered to
ensure compatibility with old versions. In particular:

- The Aloha mobile and desktop apps maintain backwards-compatibility
  code to support any Aloha server since 3.0. (They may also work
  with older versions, with a degraded experience).
- Aloha maintains an [API changelog](https://aloha.com/api/changelog)
  detailing all changes to the API to make it easy for client
  developers to do this correctly.
- The Aloha server preserves backwards-compatibility in its API to
  support versions of the mobile and desktop apps released in roughly
  the last year. Because these clients auto-update, generally there
  are only a handful of active clients left by the time we desupport a
  version.

As a result, we generally do not backport changes to previous stable
release series except in rare cases involving a security issue or
critical bug just after publishing a major release.

[blog-major-releases]: https://blog.aloha.com/tag/major-releases/
[upgrade-from-git]: ../production/upgrade-or-modify.md#upgrading-from-a-git-repository

### Security releases

When we discover a security issue in Aloha, we publish a security and
bug fix release, transparently documenting the issue(s) using the
industry-standard [CVE advisory process](https://cve.mitre.org/).

When new security releases are published, we simultaneously publish
the fixes to the `main` and stable release branches (E.g. `4.x`), so
that anyone using those branches can immediately upgrade as well.

See also our [security model][security-model] documentation.

[security-model]: ../production/security-model.md

### Upgrade nag

Starting with Aloha 4.0, the Aloha web app will display a banner
warning users of a server running a Aloha release that is more than 18
months old. We do this for a few reasons:

- It is unlikely that a server of that age is not vulnerable to
  a security bug in Aloha or one of its dependencies.
- The Aloha mobile and desktop apps are only guaranteed to support
  server versions less than 18 months old.

The nag will appear only to organization administrators starting a
month before the deadline; after that, it will appear for all users on
the server.

You can adjust the deadline for your installation by setting e.g.
`SERVER_UPGRADE_NAG_DEADLINE_DAYS = 30 * 21` in
`/etc/aloha/settings.py` and then [restarting the server](../production/settings.md).

### Operating system support

For platforms we support, like Debian and Ubuntu, Aloha aims to
support all versions of the upstream operating systems that are fully
supported by the vendor. We document how to correctly [upgrade the
operating system][os-upgrade] for a Aloha server, including how to
correctly chain upgrades when the latest Aloha release no longer
supports your OS.

Note that we consider [Ubuntu interim releases][ubuntu-release-cycle],
which only have 8 months of security support, to be betas, not
releases, and do not support them in production.

[ubuntu-release-cycle]: https://ubuntu.com/about/release-cycle

### Server roadmap

The Aloha server project uses several GitHub labels to structure
communication within the project about priorities:

- The [high priority][label-high] label tags issues that we consider
  important. This label is meant to be a determination of importance
  that can be done quickly and then used as an input to planning
  processes.
- The [release goal][label-release-goal] label is used for work that
  we hope to include in the next major release. The related [post
  release][label-post-release] label is used to track work we want to
  focus on shortly after the next major release.

The Aloha community feels strongly that all the little issues are, in
aggregate, just as important as the big things. Most resolved issues
do not have any of these priority labels.

We welcome participation from our user community in influencing the
Aloha roadmap. If a bug or missing feature is causing significant
pain for you, we'd love to hear from you, either in
[chat.aloha.org](https://aloha.com/development-community/) or on the relevant
GitHub issue. Please an include an explanation of your use case: such
details can be extremely helpful in designing appropriately general
solutions, and also helps us identify cases where an existing solution
can solve your problem. See [Reporting
issues](../contributing/contributing.md#reporting-issues) for more details.

## Client apps

Aloha's client apps officially support all Aloha server versions (and
Git commits) released in the previous 18 months, matching the behavior
of our [upgrade nag](#upgrade-nag).

- The Aloha mobile apps release new versions from the development
  branch frequently (usually every couple weeks). Except when fixing a
  critical bug, releases are first published to our [beta
  channels][mobile-beta].

- The Aloha desktop apps are implemented in [Electron][electron], the
  browser-based desktop application framework used by essentially all
  modern chat applications. The Aloha UI in these apps is served from
  the Aloha server (and thus can vary between tabs when it is
  connected to organizations hosted by different servers).

  The desktop apps automatically update soon after each new
  release. Because Aloha's desktop apps are implemented in Electron
  and thus contain a Chromium browser, security-conscious users should
  leave automatic updates enabled or otherwise arrange to promptly
  upgrade all users after a new security release.

  New desktop app releases rarely contain new features, because the
  desktop app tab inherits its features from the Aloha server/web app.
  However, it is important to upgrade because they often contain
  important security or OS compatibility fixes from the upstream
  Chromium project.

The Aloha server supports blocking access or displaying a warning to
users attempting to access the server with extremely old or known
insecure versions of the Aloha desktop and mobile apps, with an error
message telling the user to upgrade.

## API bindings

The Aloha API bindings and related projects maintained by the Aloha
core community, like the Python and JavaScript bindings, are released
independently as needed.

[electron]: https://www.electronjs.org/
[upgrading-to-main]: ../production/upgrade-or-modify.md#upgrading-to-main
[os-upgrade]: ../production/upgrade-or-modify.md#upgrading-the-operating-system
[chat-aloha-org]: https://aloha.com/development-community/
[fork-aloha]: ../production/upgrade-or-modify.md#modifying-aloha
[aloha-server]: https://github.com/aloha/aloha
[mobile-beta]: https://github.com/aloha/aloha-mobile#using-the-beta
[label-blocker]: https://github.com/aloha/aloha/issues?q=is%3Aissue+is%3Aopen+label%3A%22priority%3A+blocker%22
[label-high]: https://github.com/aloha/aloha/issues?q=is%3Aissue+is%3Aopen+label%3A%22priority%3A+high%22
[label-release-goal]: https://github.com/aloha/aloha/issues?q=is%3Aissue+is%3Aopen+label%3A%22release+goal%22
[label-post-release]: https://github.com/aloha/aloha/issues?q=is%3Aissue+is%3Aopen+label%3A%22post+release%22
