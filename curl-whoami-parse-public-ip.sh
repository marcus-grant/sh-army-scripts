#!/bin/bash

function usage {
    echo "curl-whoami-parse-public-ip.sh.sh"
    echo "Usage: curl-whoami-parse-public-ip.sh"
    echo "Description:"
    echo "Uses 'curl-whoami.sh' and"
    echo "'util-search-override.sh' to"
    echo "extract the public IP address from the whoami response."
    echo "It does so by looking at the headers most likely to"
    echo "containt a public IP."
}

PUBLIC_IP_HTTP_HEADERS_PRIORITY_LIST=(
"Forwarded:" # Legacy proxy forwarding header
"X-Forwarded-For:" # Stack of originating IPs, last is the IP first proxy detected
"X-Real-Ip:" # Typically used in Proxies and load balancers
"CF-Connecting-IP:" # Header used by CloudFlare to indicate originating IP
"Client-IP:" # A less common header used by proxies to pass originating IP along
"True-Client-IP:" # Another even less common header used by proxies for same reason
)

function main {

    # Get whoami TXT response containing all headers used by request
    # Inside that request are going to be headers the whoami server will see
    # It then returns those headers as a raw text response
    whoami_response="$(./curl-whoami.sh)"
    whoami_rc=$?
    if [ $whoami_rc -ne 0 ]; then
        echo "Error in 'curl-whoami.sh'"
        echo
        echo "(curl-whoami.sh) Output:"
        echo $whoami_response
        echo
        usage
        exit 1
    fi
    # Now extract the IP by using util-search-override.sh
    # The response will have a header containing the public IP.
    # With the most likely to contain the correct public IP from first to last,
    # headers is joined from the list above as a separate argument for
    # the search script.
    # The script will extract the line in the response that matches last.
    headers=${PUBLIC_IP_HTTP_HEADERS_PRIORITY_LIST[*]} # Join list by spaces
    ip_line=$(echo "$whoami_response" | ./util-search-override.sh $headers)
    search_rc="$?"
    if [ $search_rc -ne 0 ] || [ ! -n "$ip_line" ]; then
        echo "Unable to determine public IP address."
        echo
        echo "Debug: curl-whoami.sh Output:"
        echo "$whoami_response"
        echo
        echo "Debug: util-search-override.sh return code: $search_rc"
        echo
        echo "Debug: headers:"
        echo $headers
        echo
        echo "Debug: util-search-override.sh output:"
        echo $ip_line
        echo
        usage
        exit 2
    fi

    # We now have the line, including HEADER_NAME(colon & space)IP_ADDRESS
    # We just have to filter away the HEADER_NAME(colon & space)
    ip="${ip_line#*: }"
    echo "$ip"
    exit 0
}

main "$@"

