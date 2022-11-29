from unittest import mock

from zerver.lib.compatibility import find_mobile_os, is_outdated_desktop_app, version_lt
from zerver.lib.test_classes import AlohaTestCase


class VersionTest(AlohaTestCase):
    data = (
        [
            case.split()
            for case in """
        1.2.3    <  1.2.4
        1.2.3    =  1.2.3
        1.4.1    >  1.2.3
        1.002a   =  1.2a
        1.2      <  1.2.3
        1.2.3    ?  1.2-dev
        1.2-dev  ?  1.2a
        1.2a     ?  1.2rc3
        1.2rc3   ?  1.2
        1.2      ?  1.2-g0f1e2d3c4
        10.1     >  1.2
        0.17.18  <  16.2.96
        9.10.11  <  16.2.96
        15.1.95  <  16.2.96
        16.2.96  =  16.2.96
        20.0.103 >  16.2.96
    """.strip().split(
                "\n"
            )
        ]
        + [
            ["", "?", "1"],
            ["", "?", "a"],
        ]
    )

    def test_version_lt(self) -> None:
        for ver1, cmp, ver2 in self.data:
            msg = f"expected {ver1} {cmp} {ver2}"
            if cmp == "<":
                self.assertTrue(version_lt(ver1, ver2), msg=msg)
                self.assertFalse(version_lt(ver2, ver1), msg=msg)
            elif cmp == "=":
                self.assertFalse(version_lt(ver1, ver2), msg=msg)
                self.assertFalse(version_lt(ver2, ver1), msg=msg)
            elif cmp == ">":
                self.assertFalse(version_lt(ver1, ver2), msg=msg)
                self.assertTrue(version_lt(ver2, ver1), msg=msg)
            elif cmp == "?":
                self.assertIsNone(version_lt(ver1, ver2), msg=msg)
                self.assertIsNone(version_lt(ver2, ver1), msg=msg)
            else:
                assert False  # nocoverage

    mobile_os_data = [
        case.split(None, 1)
        for case in """
      android AlohaMobile/1.2.3 (Android 4.5)
      ios     AlohaMobile/1.2.3 (iPhone OS 2.1)
      ios     AlohaMobile/1.2.3 (iOS 6)
      None    AlohaMobile/1.2.3 (Windows 8)
    """.strip().split(
            "\n"
        )
    ]

    def test_find_mobile_os(self) -> None:
        for expected_, user_agent in self.mobile_os_data:
            expected = None if expected_ == "None" else expected_
            self.assertEqual(find_mobile_os(user_agent), expected, msg=user_agent)


class CompatibilityTest(AlohaTestCase):
    data = [
        case.split(None, 1)
        for case in """
      old AlohaInvalid/5.0
      ok  AlohaMobile/5.0
      ok  AlohaMobile/5.0 (iOS 11)
      ok  AlohaMobile/5.0 (Androidish 9)
      old AlohaMobile/5.0 (Android 9)
      old AlohaMobile/15.1.95 (Android 9)
      old AlohaMobile/16.1.94 (Android 9)
      ok  AlohaMobile/16.2.96 (Android 9)
      ok  AlohaMobile/20.0.103 (Android 9)

      ok  AlohaMobile/0.7.1.1 (iOS 11.4)
      old AlohaMobile/1.0.13 (Android 9)
      ok  AlohaMobile/17.1.98 (iOS 12.0)
      ok  AlohaMobile/19.2.102 (Android 6.0)
      ok  AlohaMobile/1 CFNetwork/974.2.1 Darwin/18.0.0
      ok  AlohaMobile/20.0.103 (Android 6.0.1)
      ok  AlohaMobile/20.0.103 (iOS 12.1)
    """.strip().split(
            "\n"
        )
        if case
    ]

    def test_compatibility_without_user_agent(self) -> None:
        result = self.client_get("/compatibility", skip_user_agent=True)
        self.assert_json_error(result, "User-Agent header missing from request")

    def test_compatibility(self) -> None:
        for expected, user_agent in self.data:
            result = self.client_get("/compatibility", HTTP_USER_AGENT=user_agent)
            if expected == "ok":
                self.assert_json_success(result)
            elif expected == "old":
                self.assert_json_error(result, "Client is too old")
            else:
                assert False  # nocoverage

    @mock.patch("zerver.lib.compatibility.DESKTOP_MINIMUM_VERSION", "5.0.0")
    @mock.patch("zerver.lib.compatibility.DESKTOP_WARNING_VERSION", "5.2.0")
    def test_insecure_desktop_app(self) -> None:
        self.assertEqual(is_outdated_desktop_app("AlohaDesktop/0.5.2 (Mac)"), (True, True, True))
        self.assertEqual(
            is_outdated_desktop_app(
                "AlohaElectron/2.3.82 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Aloha/2.3.82 Chrome/61.0.3163.100 Electron/2.0.9 Safari/537.36"
            ),
            (True, True, True),
        )
        self.assertEqual(
            is_outdated_desktop_app(
                "AlohaElectron/4.0.0 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Aloha/4.0.3 Chrome/66.0.3359.181 Electron/3.1.10 Safari/537.36"
            ),
            (True, True, False),
        )

        self.assertEqual(
            is_outdated_desktop_app(
                "AlohaElectron/4.0.3 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Aloha/4.0.3 Chrome/66.0.3359.181 Electron/3.1.10 Safari/537.36"
            ),
            (True, True, False),
        )

        # Verify what happens if DESKTOP_MINIMUM_VERSION < v < DESKTOP_WARNING_VERSION
        with mock.patch("zerver.lib.compatibility.DESKTOP_MINIMUM_VERSION", "4.0.3"):
            self.assertEqual(
                is_outdated_desktop_app(
                    "AlohaElectron/4.0.3 Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Aloha/4.0.3 Chrome/66.0.3359.181 Electron/3.1.10 Safari/537.36"
                ),
                (True, False, False),
            )

        self.assertEqual(
            is_outdated_desktop_app(
                "AlohaElectron/5.2.0 Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Aloha/5.2.0 Chrome/80.0.3987.165 Electron/8.2.5 Safari/537.36"
            ),
            (False, False, False),
        )

        self.assertEqual(
            is_outdated_desktop_app(
                "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.130 Safari/537.36"
            ),
            (False, False, False),
        )

        self.assertEqual(is_outdated_desktop_app(""), (False, False, False))
