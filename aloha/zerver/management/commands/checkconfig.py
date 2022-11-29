from typing import Any

from django.core.management.base import BaseCommand

from zerver.lib.management import check_config


class Command(BaseCommand):
    help = """Checks /etc/aloha/settings.py for common configuration issues."""

    def handle(self, *args: Any, **options: Any) -> None:
        check_config()
