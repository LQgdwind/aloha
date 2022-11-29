from typing import Any

from zerver.actions.user_groups import promote_new_full_members
from zerver.lib.management import AlohaBaseCommand


class Command(AlohaBaseCommand):
    help = """Add users to full members system group."""

    def handle(self, *args: Any, **options: Any) -> None:
        promote_new_full_members()
