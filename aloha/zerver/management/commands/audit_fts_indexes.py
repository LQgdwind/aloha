from typing import Any

from django.db import connection

from zerver.lib.management import AlohaBaseCommand


class Command(AlohaBaseCommand):
    def handle(self, *args: Any, **kwargs: str) -> None:
        with connection.cursor() as cursor:
            cursor.execute(
                """
                UPDATE zerver_message
                SET search_tsvector =
                to_tsvector('aloha.english_us_search', subject || rendered_content)
                WHERE to_tsvector('aloha.english_us_search', subject || rendered_content) != search_tsvector
            """
            )

            fixed_message_count = cursor.rowcount
            print(f"Fixed {fixed_message_count} messages.")
