#!/bin/bash
WORKING_DIR="/opt/ddns"

# Get cloudflare creds
source "$WORKING_DIR/.env"
if [ -z "$ZONE_ID" ] || [ -z "$DNS_RECORD_ID" ] || [ -z "$CLOUDFLARE_API_TOKEN" ]; then
  logger --priority user.error "Missing required info. Check $WORKING_DIR/.env"
  exit 1
fi

currentip="$(curl -s "https://ipv4.icanhazip.com/")"
if [ -f "$WORKING_DIR/.ip" ]; then
  previousip=$(cat "$WORKING_DIR/.ip")
else
  previousip="192.0.2.0"
  logger "Couldn't find $WORKING_DIR/.ip"
fi

if [ $currentip != $previousip ]; then
  # Build the request
  requestBody="$(cat <<EOF
{
  "type": "A",
  "comment": "Updated by script $(date "+%m-%d at %H:%M")",
  "content": "$currentip"
}
EOF
)"

  # Get a response
  response="$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$DNS_RECORD_ID" \
    -X PATCH \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -d "$requestBody")"

  # Log as needed
  if [ "$(echo "$response"|grep '"success":true')" != "" ]; then
    echo "$currentip" > "$WORKING_DIR/.ip"
    logger --priority user.notice "DDNS updated to $(cat "$WORKING_DIR/.ip")"
  else
    logger --priority user.error "DDNS update failed: $response"
  fi
else
  logger --priority user.info "DDNS no update required"
fi
