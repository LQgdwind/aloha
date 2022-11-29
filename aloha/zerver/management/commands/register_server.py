import subprocess
from argparse import ArgumentParser
from typing import Any, Dict

import requests
from django.conf import settings
from django.core.management.base import CommandError
from django.utils.crypto import get_random_string
from requests.models import Response

from zerver.lib.management import AlohaBaseCommand, check_config
from zerver.lib.remote_server import PushBouncerSession

if settings.DEVELOPMENT:
    SECRETS_FILENAME = "zproject/dev-secrets.conf"
else:
    SECRETS_FILENAME = "/etc/aloha/aloha-secrets.conf"


class Command(AlohaBaseCommand):
    help = """Register a remote Aloha server for push notifications."""

    def add_arguments(self, parser: ArgumentParser) -> None:
        parser.add_argument(
            "--agree_to_terms_of_service",
            action="store_true",
            help="Agree to the Alohachat Terms of Service: https://aloha.com/terms/.",
        )
        parser.add_argument(
            "--rotate-key",
            action="store_true",
            help="Automatically rotate your server's aloha_org_key",
        )

    def handle(self, *args: Any, **options: Any) -> None:
        if not settings.DEVELOPMENT:
            check_config()

        if not settings.aloha_ORG_ID:
            raise CommandError(
                "Missing aloha_org_id; run scripts/setup/generate_secrets.py to generate."
            )
        if not settings.aloha_ORG_KEY:
            raise CommandError(
                "Missing aloha_org_key; run scripts/setup/generate_secrets.py to generate."
            )
        if settings.PUSH_NOTIFICATION_BOUNCER_URL is None:
            if settings.DEVELOPMENT:
                settings.PUSH_NOTIFICATION_BOUNCER_URL = (
                    settings.EXTERNAL_URI_SCHEME + settings.EXTERNAL_HOST
                )
            else:
                raise CommandError(
                    "Please uncomment PUSH_NOTIFICATION_BOUNCER_URL "
                    "in /etc/aloha/settings.py (remove the '#')"
                )

        request = {
            "aloha_org_id": settings.aloha_ORG_ID,
            "aloha_org_key": settings.aloha_ORG_KEY,
            "hostname": settings.EXTERNAL_HOST,
            "contact_email": settings.aloha_ADMINISTRATOR,
        }
        if options["rotate_key"]:
            request["new_org_key"] = get_random_string(64)

        self._log_params(request)

        if not options["agree_to_terms_of_service"] and not options["rotate_key"]:
            print(
                "To register, you must agree to the Alohachat Terms of Service: "
                "https://aloha.com/terms/"
            )
            tos_prompt = input("Do you agree to the Terms of Service? [Y/n] ")
            print("")
            if not (
                tos_prompt.lower() == "y" or tos_prompt.lower() == "" or tos_prompt.lower() == "yes"
            ):
                raise CommandError("Aborting, since Terms of Service have not been accepted.")

        response = self._request_push_notification_bouncer_url(
            "/api/v1/remotes/server/register", request
        )

        if response.json()["created"]:
            print(
                "You've successfully registered for the Mobile Push Notification Service!\n"
                "To finish setup for sending push notifications:"
            )
            print(
                "- Restart the server, using /home/aloha/deployments/current/scripts/restart-server"
            )
            print("- Return to the documentation to learn how to test push notifications")
        else:
            if options["rotate_key"]:
                print(f"Success! Updating {SECRETS_FILENAME} with the new key...")
                subprocess.check_call(
                    [
                        "crudini",
                        "--set",
                        SECRETS_FILENAME,
                        "secrets",
                        "aloha_org_key",
                        request["new_org_key"],
                    ]
                )
            print("Mobile Push Notification Service registration successfully updated!")

    def _request_push_notification_bouncer_url(self, url: str, params: Dict[str, Any]) -> Response:
        assert settings.PUSH_NOTIFICATION_BOUNCER_URL is not None
        registration_url = settings.PUSH_NOTIFICATION_BOUNCER_URL + url
        session = PushBouncerSession()
        try:
            response = session.post(registration_url, params=params)
        except requests.RequestException:
            raise CommandError(
                "Network error connecting to push notifications service "
                f"({settings.PUSH_NOTIFICATION_BOUNCER_URL})",
            )
        try:
            response.raise_for_status()
        except requests.HTTPError as e:
            # Report nice errors from the Aloha API if possible.
            try:
                content_dict = response.json()
            except Exception:
                raise e

            raise CommandError("Error: " + content_dict["msg"])

        return response

    def _log_params(self, params: Dict[str, Any]) -> None:
        print("The following data will be submitted to the push notification service:")
        for key in sorted(params.keys()):
            print(f"  {key}: {params[key]}")
        print("")
