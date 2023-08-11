# Termux SDK Installer

### Notes

-   Termux from playstore [is no longer updated](https://wiki.termux.com/wiki/Termux_Google_Play), install termux from [f-droid](https://f-droid.org/en/packages/com.termux) or from their [github releases](https://github.com/termux/termux-app/releases) instead.
-   This is for people who prefer using termux if you want gui checkout [itsaky's AndroidIDE android app](https://github.com/AndroidIDEOfficial/AndroidIDE), sdk is taken from there.
-   This does **NOT** installs the NDK (for now).
-   Post install, you can use `sdkmanager --list | sed -e '/Available Packages/q'` to list all installed packages.
-   To accept all licenses run `yes | sdkmanager --licenses`

### Usage

-   Run installer like so `bash installer.sh`
-   Give `-h or --help` argument to script for help and available commands.
-   Give `--info` argument to show informations on sdk, jdk, tools, etc.
-   Give `-i or --install` argument to start the installation of dependencies, jdk and android sdk.
