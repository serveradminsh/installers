# ServerAdmin Installers

ServerAdmin Installers consists of a collection of simple, easy-to-use auto-installer bash scripts designed to simplify common and complex tasks.

## Current OS Support

Each auto-installer is tested on Ubuntu 16.04 and 16.10 (64bit). They may work for other distributions, such as Debian, though it's not guaranteed. Integrated support for other OS's is planned.

## Installation Time

Installation times will vary according to the Auto-Installer being used and the resources available to your server/VPS. Auto-Installers that compile from source may need more CPU/RAM, so it's advised that you have at least 1GB of RAM and at least 1 CPU/Core.

## Running an Auto-Installer

Each Auto-Installer is designed to be ran as the `root` user from the CLI. Simply choose the preferred Auto-Installer and run the command below. Better support for launching from the CLI is planned; doing this for each is only temporary.

`chmod +x installer.sh && ./installer.sh`

## Found an Issue? Have a Suggestion?

- [https://github.com/serveradminsh/installers/issues](https://github.com/serveradminsh/installers/issues)