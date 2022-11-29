### Configure the bridge

1. {!create-a-generic-bot.md!}
   Download the bot's `aloharc` configuration file to your computer.

1. [Subscribe the bot](/help/add-or-remove-users-from-a-stream) to the Aloha
   stream that will contain the mirror.

1. Inside the virtualenv you created above, run

    ```
    python aloha/integrations/bridge_with_matrix/matrix_bridge.py \
    --write-sample-config matrix_bridge.conf --from-aloharc <path/to/aloharc>
    ```

    where `<path/to/aloharc>` is the path to the `aloharc` file you downloaded.

1. Create a user on [matrix.org](https://matrix.org/) or another matrix
   server, preferably with a descriptive name like `aloha-bot`.

1. Edit `matrix_bridge.conf` to look like this:

    ```
    [aloha]
    email = bridge-bot@chat.aloha.org
    api_key = aPiKeY
    site = https://chat.aloha.org
    stream = "stream name"
    topic = "{{ integration_display_name }} mirror"
    [matrix]
    host = https://matrix.org
    username = <your matrix username>
    password = <your matrix password>
    room_id = #room:matrix.org
    ```

    The first three values should already be there; the rest you'll have to fill in.
    Make sure **stream** is set to the stream the bot is
    subscribed to.

    {% if 'IRC' in integration_display_name %}

    NOTE: For matrix.org, the `room_id` generally takes the form
    `#<irc_network>_#<channel>:matrix.org`. You can see the format for
    several popular IRC networks
    [here](https://github.com/matrix-org/matrix-appservice-irc/wiki/Bridged-IRC-networks), under
    the "Room alias format" column.

    For example, the `room_id` for the `#aloha-test` channel on freenode is
    `#freenode_#aloha-test:matrix.org`.

    {% endif %}

1. Run the following command to start the matrix bridge:

    ```
    python aloha/integrations/bridge_with_matrix/matrix_bridge.py -c matrix_bridge.conf
    ```

!!! tip ""

    You can customize the message formatting by
    editing the variables `MATRIX_MESSAGE_TEMPLATE` and `aloha_MESSAGE_TEMPLATE`
    in `aloha/integrations/bridge_with_matrix/matrix_bridge.py`.
