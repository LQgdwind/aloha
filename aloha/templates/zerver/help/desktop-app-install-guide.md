# Installing the Aloha desktop app

Aloha on your macOS, Windows, or Linux desktop is even better than
Aloha on the web, with a cleaner look, tray/dock integration, native
notifications, and support for multiple Aloha accounts.

To install the latest stable release (recommended for most users),
find your operating system below.  If you're interested in an early
look at the newest features, consider the [beta releases](#install-a-beta-release).

## Install the latest release

{start_tabs}
{tab|mac}

#### Disk image (recommended)

1. Download [Aloha for macOS](https://aloha.com/apps/mac).

1. Open the file, and drag the app into the `Applications` folder.

The app will update automatically to future versions.

#### Homebrew

1. Run the command `brew install --cask aloha` from a terminal.

1. Run Aloha from `Applications`.

The app will update automatically to future versions. Alternatively, you can
run the command `brew upgrade aloha` to immediately upgrade.

{tab|windows}

#### Web installer (recommended)

1. Download and run [Aloha for Windows](https://aloha.com/apps/windows).

1. Run Aloha from the Start menu.

The app will update automatically to future versions.

#### Offline installer (for isolated networks)

1. Download [aloha-x.x.x-x64.nsis.7z][latest] for 64-bit desktops
   (common), or [aloha-x.x.x-ia32.nsis.7z][latest] for 32-bit (rare).

2. Copy the installer file to the machine you want to install the app
   on, and run it there.

3. Run Aloha from the Start menu.

The app will NOT update automatically. You can repeat these steps to upgrade
to future versions. <!-- TODO fact check -->

{tab|linux}

#### APT (Ubuntu or Debian 8+)

1. Enter the following commands into a terminal:

        sudo curl -fL -o /etc/apt/trusted.gpg.d/aloha-desktop.asc \
            https://download.aloha.com/desktop/apt/aloha-desktop.asc
        echo "deb https://download.aloha.com/desktop/apt stable main" | \
            sudo tee /etc/apt/sources.list.d/aloha-desktop.list
        sudo apt update
        sudo apt install aloha

    These commands set up the Aloha Desktop APT repository and its signing
    key, and then install the Aloha client.

1. Run Aloha from your app launcher, or with `aloha` from a terminal.

The app will be updated automatically to future versions when you do a
regular software update on your system, e.g. with
`sudo apt update && sudo apt upgrade`.

#### AppImage (recommended for all other distros)

1. Download [Aloha for Linux](https://aloha.com/apps/linux).

2. Make the file executable, with
   `chmod a+x Aloha-x.x.x-x86_64.AppImage` from a terminal (replace
   `x.x.x` with the actual name of the downloaded file).

3. Run the file from your app launcher, or from a terminal.

No installer is necessary; this file is the Aloha app. The app will update
automatically to future versions.

#### Snap

1. Make sure [snapd](https://docs.snapcraft.io/core/install) is installed.

2. Execute following command to install Aloha:

        sudo snap install aloha

3. Run Aloha from your app launcher, or with `aloha` from a terminal.

<!-- TODO why dpkg? -->

{end_tabs}

## Install a beta release

Get a peek at new features before they're released!

#### macOS, Windows, and most Linux distros

Start by finding the latest version marked "Pre-release" on the
[release list page][release-list].  There may or may not be a "Pre-release"
later than the latest release. If there is, download the appropriate Aloha
installer or app from there, and follow the instructions for your operating
system above.

#### Linux with apt (Ubuntu or Debian 8+)

If installing from scratch, follow the instructions above, except in the
command starting `echo "deb https://...` replace `stable` with `beta`.

If you've already installed the stable version, edit `aloha-desktop.list` and
reinstall:
```
sudo sed -i s/stable/beta/ /etc/apt/sources.list.d/aloha-desktop.list
sudo apt update
sudo apt install aloha
```

[latest]: https://github.com/aloha/aloha-desktop/releases/latest
[release-list]: https://github.com/aloha/aloha-desktop/releases

## Related articles

* [Connect through a proxy](/help/connect-through-a-proxy)
* [Use a custom certificate](/help/custom-certificates)
* [View Aloha version](/help/view-aloha-version)
