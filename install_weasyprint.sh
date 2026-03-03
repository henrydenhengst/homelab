#!/bin/bash

echo "--- Installeren van WeasyPrint en afhankelijkheden ---"

# 1. Systeem bibliotheken (nodig voor PDF rendering)
sudo apt update
sudo apt install -y python3-pip python3-cffi python3-brotli libpango-1.0-0 libharfbuzz0b libpangoft2-1.0-0 libpangocairo-1.0-0

# 2. WeasyPrint installeren via pip
# We installeren het 'user-wide' zodat het ook buiten de venv in het pad staat
python3 -m pip install --user weasyprint

# 3. Controleren of het pad in de PATH variabele staat
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    export PATH="$HOME/.local/bin:$PATH"
fi

echo -e "\n--- Controle ---"
if command -v weasyprint &> /dev/null; then
    echo "Succes! WeasyPrint is nu bereikbaar."
    weasyprint --version
else
    echo "Fout: WeasyPrint staat nog niet in het pad. Start je terminal even opnieuw."
fi
