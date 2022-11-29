Aloha supports integration with Perforce as a [trigger][1]
that fires once a changelist is submitted and committed.

[1]: https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.scripting.html

1.  {!download-python-bindings.md!}

1.  The Perforce trigger will be installed to a location like
    `/usr/local/share/aloha/integrations/perforce`.

1.  {!change-aloha-config-file.md!}

1.  If you have a P4Web viewer set up, you may change `P4_WEB`
    to point at the base URL of the server. If this is configured,
    then the changelist number of each commit will be converted to
    a hyperlink that displays the commit details on P4Web.

1.  Edit your [trigger table][2] with `p4 triggers` and add an entry
    something like the following:

        notify_aloha change-commit //depot/... "/usr/local/share/aloha/integrations/perforce/aloha_change-commit.py %change% %changeroot%"

    [2]: https://www.perforce.com/manuals/p4sag/Content/P4SAG/chapter.scripting.html#d0e14583

1.  By default, this hook will send to streams of the form
    `depot_subdirectory-commits`. So, a changelist that modifies
    files in `//depot/foo/bar/baz` will result in a message to
    stream `foo-commits`. Messages about changelists that modify
    files in the depot root or files in multiple direct subdirectories
    of the depot root will be sent to `depot-commits`.
    If you'd prefer different behavior, such as all commits across your
    depot going to one stream, change it now in `aloha_perforce_config.py`.
    Make sure that everyone interested in getting these post-commit Alohas
    is subscribed to the relevant streams!

1.  By default, this hook will send a message to Aloha even if the
    destination stream does not yet exist. Messages to nonexistent
    streams prompt the Aloha Notification Bot to inform the bot's
    owner by private message that they may wish to create the stream.
    If this behaviour is undesirable, for example with a large and busy
    Perforce server, change the `aloha_IGNORE_MISSING_STREAM`
    variable in `aloha_perforce_config.py` to `True`.
    This will change the hook's behaviour to first check whether the
    destination stream exists and silently drop messages if it does not.

{!congrats.md!}

![Perforce notification bot message](/static/images/integrations/perforce/001.png)