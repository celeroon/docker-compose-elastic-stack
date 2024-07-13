#!/bin/bash

# Function to check if the input is an IP address
is_ip_address() {
    local ip="$1"
    local IFS='.'
    read -r -a ip_parts <<< "$ip"
    if [[ ${#ip_parts[@]} -ne 4 ]]; then
        return 1  # Not a valid IP address
    fi
    for part in "${ip_parts[@]}"; do
        if ! [[ "$part" =~ ^[0-9]+$ ]] || ((part > 255)); then
            return 1  # Not a valid IP address
        fi
    done
    return 0  # It's an IP address
}

# Function to check if the input is a FQDN
is_fqdn() {
    local fqdn="$1"
    if [[ $fqdn =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0  # It's a FQDN
    else
        return 1  # It's not a FQDN
    fi
}

# Function to print usage
usage() {
    echo "Usage: $0 [--elastic IP_OR_FQDN] [--fleet IP_OR_FQDN]"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --elastic)
        es_server_host="$2"
        shift # past argument
        shift # past value
        ;;
        --fleet)
        fleet_server_host="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        usage
        ;;
    esac
done

# If flags are not provided, prompt the user for input
if [[ -z "$es_server_host" ]]; then
    read -p "Enter the IP address or FQDN for ES_SERVER_HOST: " es_server_host
fi

if [[ -z "$fleet_server_host" ]]; then
    read -p "Enter the IP address or FQDN for FLEET_SERVER_HOST: " fleet_server_host
fi

# Verify if the inputs are valid IP addresses or FQDNs
if is_ip_address "$es_server_host"; then
    echo "ES_SERVER_HOST is a valid IP address."
elif is_fqdn "$es_server_host"; then
    echo "ES_SERVER_HOST is a valid Fully Qualified Domain Name."
else
    echo "ES_SERVER_HOST is neither a valid IP address nor a valid Fully Qualified Domain Name."
    exit 1
fi

if is_ip_address "$fleet_server_host"; then
    echo "FLEET_SERVER_HOST is a valid IP address."
elif is_fqdn "$fleet_server_host"; then
    echo "FLEET_SERVER_HOST is a valid Fully Qualified Domain Name."
else
    echo "FLEET_SERVER_HOST is neither a valid IP address nor a valid Fully Qualified Domain Name."
    exit 1
fi

# Append the values to the .env file if they are valid
echo "Appending variables to .env file..."

# Append ES_SERVER_HOST to .env
echo "ES_SERVER_HOST=$es_server_host" >> .env

# Append FLEET_SERVER_HOST to .env
echo "FLEET_SERVER_HOST=$fleet_server_host" >> .env

echo "Variables appended to .env file successfully."
