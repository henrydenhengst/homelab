ssh henry@192.168.178.2 << 'EOF'
echo -e "\n--- Lokale Check op de Server ---"
SERVICES=(
    "Portainer|9000"
    "Home Assistant|8123"
    "Zigbee2MQTT|8080"
    "Flame Dashboard|5005"
    "ESPHome|6052"
)

for service in "${SERVICES[@]}"; do
    IFS="|" read -r NAME PORT <<< "$service"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://localhost:$PORT")
    if [[ "$STATUS" == "200" || "$STATUS" == "302" || "$STATUS" == "301" || "$STATUS" == "307" ]]; then
        echo -e "[ OK ] $NAME (Poort $PORT) antwoordt met status $STATUS"
    else
        echo -e "[FAIL] $NAME (Poort $PORT) geeft status $STATUS"
    fi
done
EOF
