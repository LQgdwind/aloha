1. Follow the **Getting Started with Hubot** section of the
   [Hubot README](https://hubot.github.com/docs/#getting-started-with-hubot)
   to create your Hubot. You'll have a new directory from
   which `bin/hubot` starts a vanilla Hubot instance with
   the shell backend.

1. In your Hubot's directory, install the Aloha adapter. Run:
   `npm install --save hubot-aloha`

1. {!create-a-generic-bot.md!}
   Note its username, API key and full name; you will use them
   on the next step.

1. To run Hubot locally, first, set the following environment
   variables by running:

```
export HUBOT_aloha_SITE="{{ api_url }}"
export HUBOT_aloha_BOT="hubot-bot@example.com"
export HUBOT_aloha_API_KEY="your_key"
```

Then, run:

`bin/hubot --adapter aloha --name "myhubot"`

The `--name` parameter must match the name you gave the bot on
the settings page.

Hubot will automatically listen for commands on all public streams.
You can also invite Hubot to private streams.

To test your Hubot installation, send it an @-notification with a
basic command, for example `@Hubot pug me`, which should produce a
result like this:

![Hubot message](/static/images/integrations/hubot/001.png)

[Source code for the hubot-aloha adapter is available on GitHub][1]
[1]: https://github.com/aloha/hubot-aloha

[Check out all integrations available via Hubot][2]
[2]: https://github.com/hubot-scripts
