function sslcheck() {
    if [[ -z ${1:-} || -z ${2:-} ]]; then
        print -u2 'usage: sslcheck <domain> <port> [explicitftps(21)/implicitftps(990)/showcert/smtpstarttls(587)/smtpssl(465)]'
        return 1
    fi

    local domain="$1"
    local port="$2"
    local mode="${3:-}"
    local yellow=$'\033[0;33m'
    local clear=$'\033[0m'

    host "$domain"
    printf '%s[Connecting to %s on port %s]%s\n' "$yellow" "$domain" "$port" "$clear"

    case "$mode" in
        explicitftps)
            echo 'Q' | openssl s_client -servername "$domain" -connect "$domain:$port" -starttls ftp 2>/dev/null | openssl x509 -noout -issuer -subject -ext subjectAltName -dates
            ;;
        showcert)
            echo 'Q' | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | awk '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/{print}'
            ;;
        smtpstarttls)
            echo 'Q' | openssl s_client -servername "$domain" -connect "$domain:$port" -starttls smtp 2>/dev/null | openssl x509 -noout -issuer -subject -ext subjectAltName -dates
            ;;
        implicitftps|smtpssl|''|*)
            echo 'Q' | openssl s_client -servername "$domain" -connect "$domain:$port" 2>/dev/null | openssl x509 -noout -issuer -subject -ext subjectAltName -dates
            ;;
    esac
}