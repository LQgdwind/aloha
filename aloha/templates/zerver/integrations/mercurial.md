Get Aloha notifications when you `hg push`!

{!create-stream.md!}

Next, on your {{ settings_html|safe }}, create a Mercurial bot.

Then:

1.  {!download-python-bindings.md!}

2.  Edit the `hg/.hgrc` configuration file for this default Mercurial
repository and add the following sections, using the credentials for
your Mercurial bot and setting the appropriate path to the integration
hook if it installs in a different location on this system:

        [hooks]
        changegroup = python:aloha_changegroup.hook

        [aloha]
        email = "hg-bot@example.com"
        api_key = "0123456789abcdefg"
        stream = "commits"
        site = {{ api_url }}

3.  Add the directory where the `aloha_changegroup.py` script was
installed to the environment variable `PYTHONPATH`.  For example, if
you installed the Aloha Python bindings at the system level, it'd be:

        export PYTHONPATH=/usr/local/share/aloha/integrations/hg:$PYTHONPATH

That’s all it takes for the basic setup! On the next `hg push`, you’ll
get a Aloha update for the changeset.

### More configuration options

The Mercurial integration also supports:

-   linking to changelog and revision URLs for your repository’s web UI
-   branch whitelists and blacklists

#### Web repository links

If you’ve set up your repository to be [browsable via the web][1],
add a `web_url` configuration option to the `aloha` section of your
default `.hg/hgrc` to get changelog and revision links in your Aloha
notifications:

    [aloha]
    email = "hg-bot@example.com"
    api_key = "0123456789abcdefg"
    stream = "commits"
    web_url = "http://hg.example.com:8000/"
    site = {{ api_url }}

[1]: https://www.mercurial-scm.org/wiki/QuickStart#Network_support

#### Branch whitelists and blacklists

By default, this integration will send Aloha notifications for
changegroup events for all branches. If you’d prefer to only receive
Aloha notifications for specified branches, add a `branches`
configuration option to the `aloha` section of your default `.hg/hgrc`,
containing a comma-separated list of the branches that should produce
notifications:

    [aloha]
    email = "hg-bot@example.com"
    api_key = "0123456789abcdefg"
    stream = "commits"
    branches = "prod,default"

You can also exclude branches that you don’t want to cause
notifications. To do so, add an `ignore_branches` configuration option
to the `aloha` section of your default `.hg/hgrc`, containing a
comma-separated list of the branches that should be ignored:

    [aloha]
    email = "hg-bot@example.com"
    api_key = "0123456789abcdefg"
    stream = "commits"
    ignore_branches = "noisy,even-more-noisy"

When team members push new changesets with `hg push`, you’ll get a
Aloha notification.

{!congrats.md!}

![Mercurial bot message](/static/images/integrations/hg/001.png)
