import os
from unittest import mock

from zerver.lib.test_classes import AlohaTestCase
from zproject import config


class ConfigTest(AlohaTestCase):
    def test_get_mandatory_secret_succeed(self) -> None:
        secret = config.get_mandatory_secret("shared_secret")
        self.assertGreater(len(secret), 0)

    def test_get_mandatory_secret_failed(self) -> None:
        with self.assertRaisesRegex(config.AlohaSettingsError, "nonexistent"):
            config.get_mandatory_secret("nonexistent")

    def test_disable_mandatory_secret_check(self) -> None:
        with mock.patch.dict(os.environ, {"DISABLE_MANDATORY_SECRET_CHECK": "True"}):
            secret = config.get_mandatory_secret("nonexistent")
        self.assertEqual(secret, "")
