# Cloudflare DDNS

## Description

Unless you pay for a static IP address, your IP addresses probably changes every once in a while. This script checks for a change and updates the public DNS record using Cloudflare's API. The install script makes this a systemd service for better manageability.

## Pre-reqs

- [Cloudflare DNS](https://www.cloudflare.com/application-services/products/dns/) configured for your domain
- [Create DNS Record](https://developers.cloudflare.com/dns/manage-dns-records/how-to/create-dns-records/)
- Get Zone ID and Record ID [From Audit Logs](https://developers.cloudflare.com/fundamentals/account/account-security/review-audit-logs/)
- [Cloudflare api key](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

## Usage

Download the files somewhere and cd to them. Create a file called .env and add api key, zone id, and record ID. 

To install as a system service run:
`./install_ddns.sh`

### Run every 10 minutes

`sudo systemctl start ddns.timer`

### Run every 10 minutes automatically at boot

`sudo systemctl enable ddns.timer --now`

### Run once

`sudo systemctl start ddns.service`

### Run once without systemd

If you want to kick off the script without systemd just run the update script instead of the installer
`./update_cloudflareddns.sh`

## Cleanup

The install script creates /opt/ddns owned by root. If your .env file contains your API key then it is considered sensitive and should be protected. The installer sets permissions to 400 so only root can read it. If you used the installer you should delete the downloaded files since the unit files reference /opt/ddns.

## TODO

It would be nice if this were a bit more modular to allow dropping in api calls for other dns providers.
