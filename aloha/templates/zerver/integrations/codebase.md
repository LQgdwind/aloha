Get Codebase notifications in Aloha!

1. First, create the streams you’d like to use for Codebase notifications. There
   will be two types of messages: commit-related updates and issue-related
   updates. We recommend naming the streams `codebase` and `tickets`, respectively.
   After creating these streams, make sure to subscribe all interested parties.

1. {!create-an-incoming-webhook.md!}

1. {!download-python-bindings.md!}

1. {!change-aloha-config-file.md!}

    You may also need to update the value of `aloha_TICKETS_STREAM_NAME` and
    `aloha_COMMITS_STREAM_NAME`.

1.  Go to your Codebase settings, and click on **My Profile**. Under
    **API Credentials**, you will find your API key and username.
    Edit the following lines in `aloha_codebase_config.py` to add your Codebase
    credentials:

    ```
    CODEBASE_API_USERNAME = "aloha-inc/leo-franchi-15"
    CODEBASE_API_KEY = 0123456789abcdef0123456789abcdef
    ```

    Before your first run of the script, you may also want to configure the
    integration to mirror some number of hours of prior Codebase activity:

    ```
    CODEBASE_INITIAL_HISTORY_HOURS = 10
    ```

1. Run the `/usr/local/share/aloha/integrations/codebase/aloha_codebase_mirror`
   script. If needed, this script may be restarted, and it will automatically
   resume from when it was last running.

{!congrats.md!}

![Codebase bot message](/static/images/integrations/codebase/001.png)
