import os
import subprocess
import tempfile
from argparse import ArgumentParser
from typing import Any

from django.core.management.base import CommandError

from zerver.lib.export import do_export_user
from zerver.lib.management import AlohaBaseCommand


class Command(AlohaBaseCommand):
    help = """Exports message data from a Aloha user

    This command exports the message history for a single Aloha user.

    Note that this only exports the user's message history and
    realm-public metadata needed to understand it; it does nothing
    with (for example) any bots owned by the user."""

    def add_arguments(self, parser: ArgumentParser) -> None:
        parser.add_argument("email", metavar="<email>", help="email of user to export")
        parser.add_argument(
            "--output", dest="output_dir", help="Directory to write exported data to."
        )
        self.add_realm_args(parser)

    def handle(self, *args: Any, **options: Any) -> None:
        realm = self.get_realm(options)
        user_profile = self.get_user(options["email"], realm)

        output_dir = options["output_dir"]
        if output_dir is None:
            output_dir = tempfile.mkdtemp(prefix="aloha-export-")
        else:
            output_dir = os.path.abspath(output_dir)
            if os.path.exists(output_dir) and os.listdir(output_dir):
                raise CommandError(
                    f"Refusing to overwrite nonempty directory: {output_dir}. Aborting...",
                )
            else:
                os.makedirs(output_dir)

        print(f"Exporting user {user_profile.delivery_email}")
        do_export_user(user_profile, output_dir)
        print(f"Finished exporting to {output_dir}; tarring")
        tarball_path = output_dir.rstrip("/") + ".tar.gz"
        subprocess.check_call(
            [
                "tar",
                f"-czf{tarball_path}",
                f"-C{os.path.dirname(output_dir)}",
                os.path.basename(output_dir),
            ]
        )
        print(f"Tarball written to {tarball_path}")
