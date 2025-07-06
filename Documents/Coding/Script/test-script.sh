#!/bin/bash

# =========== Tangkap Ctrl + C dan keluar dengan pesan ===========
trap "echo -e '\n❌ Script dibatalkan ❌'; exit" INT
echo ""

# =========== Input database name ===========
while true; do
    read -p "Masukkan yang dibutuhin : " DATANAME
    if [[ -n "$DATANAME" ]]; then
        break
    else
        echo "❌ Nama database tidak boleh kosong."
    fi
done

get_path_relative_to_htdocs() {
    local base="/c/xampp/htdocs"
    local current_dir="$(pwd)"

    if [[ "$current_dir" != "$base"* ]]; then
        echo "⚠️  You're not inside $base"
        return 1
    fi

    local rel="${current_dir#"$base"/}"
    [[ "$rel" != /* ]] && rel="/$rel"
    [[ "$rel" != */ ]] && rel="$rel/"

    # Set global variable
    RELATIVE_PATH="$rel"
}

get_path_relative_to_htdocs

# =========== index.html ===========
cat <<EOL >> "index.html"


<form action="$DATANAME" method="post">
   <input type="hidden" name="action" value="read">
   <button type="submit" name="submit">$DATANAME</button>
</form>
EOL
