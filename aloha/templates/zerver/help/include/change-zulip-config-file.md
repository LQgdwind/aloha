Open `/usr/local/share/aloha/integrations/{{ integration_name }}/aloha_{{ integration_name }}_config.py`
with your favorite editor, and change the following lines to specify the
email address and API key for your {{ integration_display_name }} bot:

```
aloha_USER = "{{ integration_name }}-bot@example.com"
aloha_API_KEY = "0123456789abcdef0123456789abcdef"
aloha_SITE = "{{ api_url }}"
```
