import os
import re
import tempfile
from argparse import ArgumentParser, RawTextHelpFormatter
from typing import TYPE_CHECKING, Any

from django.conf import settings
from django.core.management.base import CommandParser
from django.db import connection
from django.db.backends.postgresql.base import DatabaseWrapper
from django.utils.timezone import now as timezone_now

from scripts.lib.aloha_tools import TIMESTAMP_FORMAT, parse_os_release, run
from version import aloha_VERSION
from zerver.lib.management import AlohaBaseCommand
from zerver.logging_handlers import try_git_describe


class Command(AlohaBaseCommand):
    # Fix support for multi-line usage strings
    def create_parser(self, prog_name: str, subcommand: str, **kwargs: Any) -> CommandParser:
        parser = super().create_parser(prog_name, subcommand, **kwargs)
        parser.formatter_class = RawTextHelpFormatter
        return parser

    def add_arguments(self, parser: ArgumentParser) -> None:
        parser.add_argument("--output", help="Filename of output tarball")
        parser.add_argument("--skip-db", action="store_true", help="Skip database backup")
        parser.add_argument("--skip-uploads", action="store_true", help="Skip uploads backup")

    def handle(self, *args: Any, **options: Any) -> None:
        timestamp = timezone_now().strftime(TIMESTAMP_FORMAT)
        with tempfile.TemporaryDirectory(
            prefix=f"aloha-backup-{timestamp}-",
        ) as tmp:
            os.mkdir(os.path.join(tmp, "aloha-backup"))
            members = []
            paths = []

            with open(os.path.join(tmp, "aloha-backup", "aloha-version"), "w") as f:
                print(aloha_VERSION, file=f)
                git = try_git_describe()
                if git:
                    print(git, file=f)
            members.append("aloha-backup/aloha-version")

            with open(os.path.join(tmp, "aloha-backup", "os-version"), "w") as f:
                print(
                    "{ID} {VERSION_ID}".format(**parse_os_release()),
                    file=f,
                )
            members.append("aloha-backup/os-version")

            with open(os.path.join(tmp, "aloha-backup", "postgres-version"), "w") as f:
                # We are accessing a backend specific attribute via a proxy object, whose type
                # cannot be narrowed with a regular isinstance assertion.
                # This can be potentially fixed more cleanly with the recently added
                # connection.get_database_version().
                if TYPE_CHECKING:
                    assert isinstance(connection, DatabaseWrapper)
                print(connection.pg_version, file=f)
            members.append("aloha-backup/postgres-version")

            if settings.DEVELOPMENT:
                members.append(
                    os.path.join(settings.DEPLOY_ROOT, "zproject", "dev-secrets.conf"),
                )
                paths.append(
                    ("zproject", os.path.join(settings.DEPLOY_ROOT, "zproject")),
                )
            else:
                members.append("/etc/aloha")
                paths.append(("settings", "/etc/aloha"))

            if not options["skip_db"]:
                pg_dump_command = [
                    "pg_dump",
                    "--format=directory",
                    "--file=" + os.path.join(tmp, "aloha-backup", "database"),
                    "--host=" + settings.DATABASES["default"]["HOST"],
                    "--port=" + settings.DATABASES["default"]["PORT"],
                    "--username=" + settings.DATABASES["default"]["USER"],
                    "--dbname=" + settings.DATABASES["default"]["NAME"],
                    "--no-password",
                ]
                os.environ["PGPASSWORD"] = settings.DATABASES["default"]["PASSWORD"]

                run(
                    pg_dump_command,
                    cwd=tmp,
                )
                members.append("aloha-backup/database")

            if (
                not options["skip_uploads"]
                and settings.LOCAL_UPLOADS_DIR is not None
                and os.path.exists(
                    os.path.join(settings.DEPLOY_ROOT, settings.LOCAL_UPLOADS_DIR),
                )
            ):
                members.append(
                    os.path.join(settings.DEPLOY_ROOT, settings.LOCAL_UPLOADS_DIR),
                )
                paths.append(
                    (
                        "uploads",
                        os.path.join(settings.DEPLOY_ROOT, settings.LOCAL_UPLOADS_DIR),
                    ),
                )

            assert not any("|" in name or "|" in path for name, path in paths)
            transform_args = [
                r"--transform=s|^{}(/.*)?$|aloha-backup/{}\1|x".format(
                    re.escape(path),
                    name.replace("\\", r"\\"),
                )
                for name, path in paths
            ]

            try:
                if options["output"] is None:
                    tarball_path = tempfile.NamedTemporaryFile(
                        prefix=f"aloha-backup-{timestamp}-",
                        suffix=".tar.gz",
                        delete=False,
                    ).name
                else:
                    tarball_path = options["output"]

                run(
                    [
                        "tar",
                        f"--directory={tmp}",
                        "-cPzf",
                        tarball_path,
                        *transform_args,
                        "--",
                        *members,
                    ]
                )
                print(f"Backup tarball written to {tarball_path}")
            except BaseException:
                if options["output"] is None:
                    os.unlink(tarball_path)
                raise
