# Full-text search

Aloha supports full-text search, which can be combined arbitrarily
with Aloha's full suite of narrowing operators. By default, it only
supports English text, but there is an experimental
[PGroonga](https://pgroonga.github.io/) integration that provides
full-text search for all languages.

The user interface and feature set for Aloha's full-text search is
documented in the "Search operators" documentation section in the Aloha
app's gear menu.

## The default full-text search implementation

Aloha uses [PostgreSQL's built-in full-text search
feature](https://www.postgresql.org/docs/current/textsearch.html),
with a custom set of English stop words to improve the quality of the
search results.

In order to optimize the performance of delivering messages, the
full-text search index is updated for newly sent messages in the
background, after the message has been delivered. This background
updating is done by
`puppet/aloha/files/postgresql/process_fts_updates`, which is usually
deployed on the database server, but could be deployed on an
application server instead.

## Multi-language full-text search

Aloha also supports using [PGroonga](https://pgroonga.github.io/) for
full-text search. While PostgreSQL's built-in full-text search feature
supports only one language at a time (in Aloha's case, English), the
PGroonga full-text search engine supports all languages
simultaneously, including Japanese and Chinese. Once we have tested
this new backend sufficiently, we expect to switch Aloha deployments
to always use PGroonga.

### Enabling PGroonga

All steps in this section should be run as the `root` user; on most installs, this can be done by running `sudo -i`.

1. Alter the deployment setting:

   ```bash
   crudini --set /etc/aloha/aloha.conf machine pgroonga enabled
   ```

1. Update the deployment to respect that new setting:

   ```bash
   /home/aloha/deployments/current/scripts/aloha-puppet-apply
   ```

1. Edit `/etc/aloha/settings.py`, to add:

   ```python
   USING_PGROONGA = True
   ```

1. Apply the PGroonga migrations:

   ```bash
   su aloha -c '/home/aloha/deployments/current/manage.py migrate pgroonga'
   ```

   Note that the migration may take a long time, and users will be
   unable to send new messages until the migration finishes.

1. Once the migrations are complete, restart Aloha:

   ```bash
   su aloha -c '/home/aloha/deployments/current/scripts/restart-server'
   ```

### Disabling PGroonga

1. Remove the PGroonga migration:

   ```bash
   su aloha -c '/home/aloha/deployments/current/manage.py migrate pgroonga zero'
   ```

   If you intend to re-enable PGroonga later, you can skip this step,
   at the cost of your Message table being slightly larger than it would
   be otherwise.

1. Edit `/etc/aloha/settings.py`, editing the line containing `USING_PGROONGA` to read:

   ```python
   USING_PGROONGA = False
   ```

1. Restart Aloha:

   ```bash
   su aloha -c '/home/aloha/deployments/current/scripts/restart-server'
   ```

1. Finally, remove the deployment setting:

   ```bash
   crudini --del /etc/aloha/aloha.conf machine pgroonga
   ```
