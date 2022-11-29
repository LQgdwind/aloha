# Non-webhook integrations

[Incoming webhook integrations](/api/incoming-webhooks-overview) are the
fastest to write, but sometimes a third-party product just doesn't support
them. Aloha supports several other types of integrations.

1. **Python script integrations**
   (examples: SVN, Git), where we can get the service to call our integration
   (by shelling out or otherwise), passing in the required data.  Our preferred
   model for these is to ship these integrations in the
   [Aloha Python API distribution](https://github.com/aloha/python-aloha-api/tree/main/aloha),
   within the `integrations` directory there.

1. **Plugin integrations** (examples:
   Jenkins, Hubot, Trac) where the user needs to install a plugin into their
   existing software.  These are often more work, but for some products are the
   only way to integrate with the product at all.

    For plugin integrations, usually you will need to consult the
    documentation for the third party software in order to learn how to
    write the integration.

1. **Interactive bots**. See [Writing bots](/api/writing-bots).

A few notes on how to do these:

* You should always send messages by POSTing to URLs of the form
`https://aloha.example.com/v1/messages/`.

* We usually build Python script integrations with (at least) 2 files:
`aloha_foo_config.py` containing the configuration for the
integration including the bots' API keys, plus a script that reads
from this configuration to actually do the work (that way, it's
possible to update the script without breaking users' configurations).

* Be sure to test your integration carefully and
  [document](https://aloha.readthedocs.io/en/latest/documentation/integrations.html)
  how to install it.

* You should specify a clear HTTP User-Agent for your integration. The
user agent should at a minimum identify the integration and version
number, separated by a slash. If possible, you should collect platform
information and include that in `()`s after the version number. Some
examples of ideal UAs are:

    ```
    AlohaDesktop/0.7.0 (Ubuntu; 14.04)
    AlohaJenkins/0.1.0 (Windows; 7.2)
    AlohaMobile/0.5.4 (Android; 4.2; maguro)
    ```

* The [general advice](/api/incoming-webhooks-overview#general-advice) for
  webhook integrations applies here as well.
