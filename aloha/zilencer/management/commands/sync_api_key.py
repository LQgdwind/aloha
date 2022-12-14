import os
from configparser import ConfigParser
from typing import Any

from django.core.management.base import BaseCommand

from zerver.models import UserProfile, get_realm, get_user_by_delivery_email


class Command(BaseCommand):
    help = """Sync your API key from ~/.aloharc into your development instance"""

    def handle(self, *args: Any, **options: Any) -> None:
        config_file = os.path.join(os.environ["HOME"], ".aloharc")
        if not os.path.exists(config_file):
            raise RuntimeError("No ~/.aloharc found")
        config = ConfigParser()
        with open(config_file) as f:
            config.read_file(f, config_file)
        api_key = config.get("api", "key")
        email = config.get("api", "email")

        try:
            realm = get_realm("aloha")
            user_profile = get_user_by_delivery_email(email, realm)
            user_profile.api_key = api_key
            user_profile.save(update_fields=["api_key"])
        except UserProfile.DoesNotExist:
            print(f"User {email} does not exist; not syncing API key")
