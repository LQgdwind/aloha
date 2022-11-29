# Real-time events API

Aloha's real-time events API lets you write software that reacts
immediately to events happening in Aloha.  This API is what powers the
real-time updates in the Aloha web and mobile apps.  As a result, the
events available via this API cover all changes to data displayed in
the Aloha product, from new messages to stream descriptions to
emoji reactions to changes in user or organization-level settings.

## Using the events API

The simplest way to use Aloha's real-time events API is by using
`call_on_each_event` from our Python bindings.  You just need to write
a Python function (in the examples below, the `lambda`s) and pass it
into `call_on_each_event`; your function will be called whenever a new
event matching the specified parameters (`event_types`, `narrow`,
etc.) occurs in Aloha.

`call_on_each_event` takes care of all the potentially tricky details
of long-polling, error handling, exponential backoff in retries, etc.
It's cousin, `call_on_each_message`, provides an even simpler
interface for processing Aloha messages.

More complex applications (like a Aloha terminal client) may need to
instead use the raw [register](/api/register-queue) and
[events](/api/get-events) endpoints.

## Usage examples

{start_tabs}
{tab|python}

```
#!/usr/bin/env python

import sys
import aloha

# Pass the path to your aloharc file here.
client = aloha.Client(config_file="~/aloharc")

# Print every message the current user would receive
# This is a blocking call that will run forever
client.call_on_each_message(lambda msg: sys.stdout.write(str(msg) + "\n"))

# Print every event relevant to the user
# This is a blocking call that will run forever
client.call_on_each_event(lambda event: sys.stdout.write(str(event) + "\n"))
```

{end_tabs}

## Parameters

You may also pass in the following keyword arguments to `call_on_each_event`:

{generate_api_arguments_table|aloha.yaml|/real-time:post}

See the [GET /events](/api/get-events) documentation for
more details on the format of individual events.
