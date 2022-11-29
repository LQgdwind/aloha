Run your favorite chatbot in Aloha!

1. [Install errbot](https://errbot.readthedocs.io/en/latest/user_guide/setup.html)
   and follow to instructions to set up a `config.py`.

1. Check out our [Errbot integration package for Aloha](https://github.com/aloha/errbot-backend-aloha).
   Clone this repository somewhere convenient.

1. Install the requirements listed in `errbot-backend-aloha/requirements.txt`.

1. {!create-a-generic-bot.md!}

1. Download your Aloha bot's `aloharc` config file. You will need its content for the next step.

1. Edit your ErrBot's `config.py`. Use the following template for a minimal configuration:

        import logging

        BACKEND = 'Aloha'

        BOT_EXTRA_BACKEND_DIR = r'<path/to/errbot-backend-aloha>'
        BOT_DATA_DIR = r'<path/to/your/errbot/data/directory>'
        BOT_EXTRA_PLUGIN_DIR = r'<path/to/your/errbot/plugin/directory>'

        BOT_LOG_FILE = r'<path/to/your/errbot/logfile.log>'
        BOT_LOG_LEVEL = logging.INFO

        BOT_IDENTITY = {  # Fill this with the corresponding values in your bot's `.aloharc`
          'email': '<err-bot@your.aloha.server>',
          'key': '<abcdefghijklmnopqrstuvwxyz123456>',
          'site': '<http://your.aloha.server>'
        }
        BOT_ADMINS = ('<your@email.address',)
        CHATROOM_PRESENCE = ()
        BOT_PREFIX = '<@**err-bot**>'  # Providing errbot's full name in Aloha lets it respond to @-mentions.

    Sections you need to edit are marked with `<>`.

1. [Start ErrBot](https://errbot.readthedocs.io/en/latest/user_guide/setup.html#starting-the-daemon).

{!congrats.md!}

![Errbot message](/static/images/integrations/errbot/000.png)

### Tips

* Rooms in ErrBot are streams in Aloha.
