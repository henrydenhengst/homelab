#!/bin/bash

# Ga naar de map van het script
cd "$(dirname "$0")"

echo "🚀 Homelab Git Update gestart..."

# 1. Check op gevoelige bestanden die niet in .gitignore staan
if [ -f "vault_pass.txt" ]; then
    echo "⚠️  WAARSCHUWING: vault_pass.txt gevonden! Controleer of deze in .gitignore staat."
fi

# 2. Voeg alles toe (behalve wat in .gitignore staat)
git add .

# 3. Vraag om een commit message (of gebruik een standaard)
read -p "📝 Commit message (leeg laten voor 'Daily homelab update'): " msg
if [ -z "$msg" ]; then
    msg="Daily homelab update: $(date +'%Y-%m-%d %H:%M')"
fi

# 4. Committen
git commit -m "$msg"

# 5. Pushen naar GitHub
echo "📤 Pushen naar GitHub..."
git push origin main

echo "✅ Alles bijgewerkt op GitHub!"
