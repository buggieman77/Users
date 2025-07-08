#!/bin/bash

# =========== Tangkap Ctrl + C dan keluar dengan pesan ===========
trap "echo -e '\n❌ Script dibatalkan ❌'; exit" INT
echo ""
# =========== Input database name ===========
while true; do
    read -p "Masukkan nama database : " DATANAME
    if [[ -n "$DATANAME" ]]; then
        break
    else
        echo "❌ Nama database tidak boleh kosong. ❌"
    fi
done

# Input table name
while true; do
    read -p "Masukkan nama tabel database: " TABLENAME
    if [[ -n "$TABLENAME" ]]; then
        break
    else
        echo "❌ Nama tabel tidak boleh kosong. ❌"
    fi
done

# Input field/kolom table name
while true; do
    read -p "Masukkan 1 nama field dari tabel database: " FIELD
    if [[ -n "$FIELD" ]]; then
        break
    else
        echo "❌ Nama field tabel tidak boleh kosong. ❌"
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

echo ""

# =========== index.html ===========
cat <<EOL >> "index.html"


<form action="$DATANAME" method="post">
   <input type="hidden" name="action" value="read">
   <button type="submit" name="submit">$DATANAME Manager</button>
</form>
EOL

echo "[✓] button $DATANAME Manager di masukan ke dalam index.html [✓]"

# =========== .htaccess ===========
cat <<EOL >> ".htaccess"
RewriteEngine On
RewriteBase $RELATIVE_PATH

# ======================== ENTRY POINT ========================

RewriteRule ^$DATANAME-database/?$ $DATANAME [R=302,L]

# ======================== ALIAS KE FILE ========================

RewriteRule ^add-new-$DATANAME/?$ $DATANAME-database/create-data.php [L]
RewriteRule ^$DATANAME/?$ $DATANAME-database/read-data.php [L]
RewriteRule ^update-[^/]+/?$ $DATANAME-database/update-data.php [L]
RewriteRule ^delete-[^/]+/?$ $DATANAME-database/delete-data.php [L]

# ========= AKSES LANGSUNG FILE PHP DI $DATANAME-database/ REDIRECT KE ENTRY POINT =========

RewriteCond %{THE_REQUEST} ^[A-Z]{3,}\s.*?/$DATANAME-database/ [NC]
RewriteRule ^$DATANAME-database/.*$ $RELATIVE_PATH$DATANAME [R=302,L]
EOL

echo "[✓] file .htaccess [✓]"

mkdir -p "$DATANAME-database" 
echo "[✓] Folder $DATANAME-database [✓]"

# =========== $DATANAME-database/mysql-function.php ===========
cat <<EOL > "$DATANAME-database/mysql-function.php"
<?php

\$dataName = "$DATANAME";
\$capitalDataName = ucfirst(\$dataName) ;
\$entryPoint = "$RELATIVE_PATH".\$dataName ; 

function mysql(
   callable \$callback,
   mixed \$data = null,
   ?int \$port = null,
   ?string \$socket = null,
   string \$databaseName = "$DATANAME",
   string \$databaseTableName = "$TABLENAME",
   string \$hostname = "localhost",
   string \$username = "root",
   string \$password = "",
): mixed
{
   // Aktifkan mode exception pada MySQLi agar error dilempar sebagai exception
   mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);

   try {
      // Membuka koneksi ke database dengan parameter yang diberikan
      \$connection = mysqli_connect(\$hostname, \$username, \$password, \$databaseName, \$port, \$socket);
      // Menjalankan callback sesuai operasi CRUD yang diminta
      return \$callback(\$data,\$connection, \$databaseTableName);
   } catch (mysqli_sql_exception \$error) {
      // Menangkap error MySQLi dan menampilkan pesan error
      return showAlert("Error: " . \$error -> getMessage());
   }  
}

function create(array \$newData, mysqli|false \$database, string \$tableName):string|int {
   // Ambil nama-nama kolom dari array newData
   \$fields = array_keys(\$newData);
   // Buat placeholder '?' sebanyak jumlah key
   \$placeholders = implode(", ", array_fill(0, count(\$fields), "?"));
   // Nama kolom diapit backtick agar aman dari reserved word
   \$fieldList = implode(", ", array_map(fn(\$field) => "\`\$field\`", \$fields));
   // Ambil value dari array newData
   \$values = array_values(\$newData);
   // Tipe data parameter, di sini diasumsikan semua string ("s"), bisa diubah jika ada tipe lain
   \$types = str_repeat("s", count(\$fields));
   // Query SQL dengan prepared statement
   \$query = "INSERT INTO \$tableName (\$fieldList) VALUES (\$placeholders)";
   \$statement = mysqli_prepare(\$database, \$query);
   // Bind parameter ke statement
   mysqli_stmt_bind_param(\$statement, \$types, ...\$values);
   // Eksekusi statement
   mysqli_stmt_execute(\$statement);
   // Ambil jumlah baris yang terpengaruh
   \$value = mysqli_stmt_affected_rows(\$statement);
   // Tutup statement
   mysqli_stmt_close(\$statement);
   // Tutup koneksi
   mysqli_close(\$database);

   return \$value;
}

function read(int|string \$id, mysqli|false \$database, string \$tableName): array {
   // Jika id bukan angka ambil semua data di dalam table database
   \$query = is_numeric(\$id) ? "SELECT * FROM \$tableName WHERE id = \$id" : "SELECT * FROM \$tableName";
   \$data = [];
   // Eksekusi query dan simpan yang dikembalikan ke dalam variable result
   \$result = mysqli_query(\$database, \$query);
   // Fetching jadi array assosiatif
   while(\$row = mysqli_fetch_assoc(\$result)){
      \$data[] = \$row;
   }
   // Tutup koneksi
   mysqli_close(\$database);
   // jika tidak ada data di dalam table databasenya lempar error
   if (empty(\$data)){
      throw new mysqli_sql_exception("data not found");
   }
   return \$data;
}

function update(array \$newData, mysqli|false \$database, string \$tableName): string|int {
   // check apakah id ada di array, dan berupa angka 
   if (!isset(\$newData["id"]) || !is_numeric(\$newData["id"])){
   throw new mysqli_sql_exception ("Access denied");
   }

   // simpan nilai id sebagai integer
   \$id = (int) \$newData["id"];
   // hapus id dari array
   unset(\$newData["id"]);
   // masukan value ke dalam array values 
   \$values = array_values(\$newData);
   // tambahkan id ke dalam array values
   \$values[] = \$id;
   // set tipe data semua value (asumsi semua string kecuali id)
   \$types = str_repeat("s", count(\$values) - 1) . "i";
   //buat array untuk placeholder
   \$placeholdersArray = array_map(fn(\$field) => "\`\$field\` = ?", array_keys(\$newData));
   // ubah jadi string
   \$placeholders = implode(", ",\$placeholdersArray);
   // siapkan query
   \$query = "UPDATE \$tableName SET \$placeholders WHERE id = ?";
   // siapkan statement
   \$statement = mysqli_prepare(\$database,\$query);

   // kaitkan semua value ke dalam statement
   mysqli_stmt_bind_param(\$statement, \$types, ...\$values);
   // jalankan statement
   mysqli_stmt_execute(\$statement);
   // simpan jumlah baris yang berubah
   \$value = mysqli_stmt_affected_rows(\$statement);
   // tutup statement
   mysqli_stmt_close(\$statement);
   // tutup tutup koneksi
   mysqli_close(\$database);

   // kembalikan nilai
   return \$value;
}

function delete(string|int \$id, mysqli|false \$database, string \$tableName): string|int {
   // lempar error kalo id bukan angka
   if (!is_numeric(\$id)) {
      throw new mysqli_sql_exception ("Access denied");
   }
   // Query SQL dengan prepared statement
   \$query = "DELETE FROM \$tableName WHERE id = ?";
   // Siapkan statement
   \$statement = mysqli_prepare(\$database, \$query);
   // Bind parameter id
   mysqli_stmt_bind_param(\$statement, "i", \$id);
   // Eksekusi statement
   mysqli_stmt_execute(\$statement);
   // Ambil jumlah baris yang terpengaruh
   \$value = mysqli_stmt_affected_rows(\$statement);
   // Tutup statement
   mysqli_stmt_close(\$statement);
   // Tutup koneksi
   mysqli_close(\$database);

   return \$value;
}

function showAlert(string \$message): void {
   // tampilkan alert javascript
   echo "
      <script>
         alert(" . json_encode(\$message) . ");
         // Redirect ke entry point (read-data.php)
         document.location.href = " . json_encode(\$GLOBALS["entryPoint"]) . ";
      </script>
   ";
   exit; 
}

function showConfirm(): void {
   echo "
      <script>
      function htmlDecode(input) {
         let e = document.createElement('textarea');
         e.innerHTML = input;
         return e.value;
      }

      function showConfirm(action, data) {
         let dataName = htmlDecode(JSON.parse(data));
         let message = (action == 'delete') 
                        ? 'want to delete ' + dataName + ' ?' 
                        : 'want to edit ' + dataName + ' ?'
         return confirm(message)
      }
      </script>
   ";
}

function check_crud_access(string \$expectedAction, string \$method = "post") {
   // konversi k lowercase
   \$method = strtolower(\$method);
   // ambil method sesuai data yang dikirim
   \$input = \$method === "get" ? \$_GET : \$_POST;
   // cek punya akses yang di dapat dari tekan tombol akses
   if (
      \$_SERVER["REQUEST_METHOD"] !== strtoupper(\$method) ||
      !isset(\$input["action"]) ||
      \$input["action"] !== \$expectedAction
   ) {
      // Redirect (302,dev) ke entry point jika ga punya akses
      header("Location: ".\$GLOBALS["entryPoint"],false,302);
      exit;
   } 
}

function mysql_crud(string \$action,mixed \$data,?string \$successInfo = null,?string \$failedInfo = null) {
   if (\$action == "read"){
      return mysql(\$action,\$data);
   }
   // Jika proses crud berhasil
   if ( mysql(\$action, \$data) > 0 ) {
   // Tampilkan alert sukses
   showAlert(\$successInfo); 
   } else {
   // Tampilkan alert gagal
   showAlert(\$failedInfo);
   }
}

?>
EOL

echo "[✓] file $DATANAME-database/mysql-function.php [✓]"

# =========== $DATANAME-database/create-data.php ===========
cat <<EOL > "$DATANAME-database/create-data.php"
<?php 
require "./mysql-function.php";  

// Cek akses masuk ke halaman ini
check_crud_access("create");  
// Jika form disubmit (tombol Create ditekan)
if (isset(\$_POST["submit"])) {  
   // Ambil data dari form, lakukan sanitasi dengan htmlspecialchars untuk mencegah XSS
   \$new$DATANAME = [
      "$FIELD" => htmlspecialchars(\$_POST["$FIELD"]),
   ];
   // Isi dari alert sukses
   \$success = "$DATANAME : ".html_entity_decode(\$new$DATANAME["$FIELD"])." successfully added !";
   // Isi dari alert gagal
   \$failed = "$DATANAME : ".html_entity_decode(\$new$DATANAME["$FIELD"])."  failed to be added !";

   // Jalankan function mysql callback create
   mysql_crud("create",\$new$DATANAME,\$success,\$failed);

}

?>

<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Add New $DATANAME </title>
</head>
<body>
   <form method="post" >
      <input type="hidden" name="action" value="create">

      <label for="$FIELD">$FIELD :</label>
      <input type="text" id="$FIELD" placeholder="$FIELD" name="$FIELD" required>

      <button type="submit" name="submit">Create</button>
   </form>
</body>
</html>
EOL

echo "[✓] file $DATANAME-database/create-data.php [✓]"

# =========== $DATANAME-database/read-data.php ===========
cat <<EOL > "$DATANAME-database/read-data.php"
<?php

require "./mysql-function.php";

// Ambil seluruh data $DATANAME dari database dan simpan ke array \$${DATANAME}s
\$${DATANAME}s = mysql_crud("read","all");

?>

<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title><?= \$capitalDataName ?> Data Manager</title>
</head>
<body>
   <form action="add-new-<?= \$dataName ?>" method="post"> 
      <input type="hidden" name="action" value="create">
      <button type="submit">Add New <?= \$capitalDataName ?></button>
   </form>
   <br><hr><br>
   <?php foreach (\$${DATANAME}s as \$index => \$$DATANAME) : ?>
   <?php ++\$index ?>
   <section>
      <h3><?= \$index.". $FIELD : ".\$$DATANAME["$FIELD"] ?></h3>
   </section>
   <br>
   <form
   action = "update-<?= \$dataName ?>"
   method = "post"
   data-action = "update"
   data-name = "<?= htmlspecialchars(json_encode(\$$DATANAME["$FIELD"]), ENT_QUOTES, "UTF-8") ?>"
   onsubmit = "return showConfirm(this.dataset.action, this.dataset.name)"
   >
      <input type="hidden" name="id" value="<?= \$$DATANAME["id"] ?>">
      <input type="hidden" name="action" value="update">
      <button type="submit">EDIT</button>
   </form>
   <br>
   <form
   action = "delete-<?= \$dataName ?>"
   method = "post"
   data-action = "delete"
   data-name = "<?= htmlspecialchars(json_encode(\$$DATANAME["$FIELD"]), ENT_QUOTES, "UTF-8") ?>"
   onsubmit = "return showConfirm(this.dataset.action, this.dataset.name)"
   >
      <input type="hidden" name="id" value="<?= \$$DATANAME["id"] ?>">
      <input type="hidden" name="$FIELD" value="<?= (\$$DATANAME["$FIELD"]) ?>">
      <input type="hidden" name="action" value="delete">
      <button type="submit">DELETE</button>
   </form>
   <br>
   <?php endforeach ?>
</body>
</html>

EOL

echo "[✓] file $DATANAME-database/read-data.php [✓]"

# =========== $DATANAME-database/update-data.php ===========
cat <<EOL > "$DATANAME-database/update-data.php"
<?php

require "./mysql-function.php";

// Cek akses masuk kehalaman ini
check_crud_access("update");

// Masukan seluruh data $DATANAME yang dipilih dari id ke array $DATANAME
\$$DATANAME = mysql_crud("read",\$_POST["id"])[0];

// Jika form disubmit (tombol update ditekan)
if (isset(\$_POST["submit"])) {
   // Ambil data dari form, lakukan sanitasi dengan htmlspecialchars untuk mencegah XSS
   \$edited$DATANAME = [
      // Masukan Id untuk dikirim ke fungsi msql update (nebeng parameter)
      "id" => \$_POST["id"],
      "$FIELD" => htmlspecialchars(\$_POST["$FIELD"]),
   ];
   // Isi dari alert sukses
   \$success = "Update $DATANAME : ".html_entity_decode(\$edited$DATANAME["$FIELD"])." success !";
   // Isi dari alert gagal
   \$failed = "$DATANAME : ".html_entity_decode(\$edited$DATANAME["$FIELD"])."  failed to be update !";

   mysql_crud("update",\$edited$DATANAME,\$success,\$failed);
}

?>

<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Updated $DATANAME</title>
</head>
<body>
   <form method="post" >
      <input type="hidden" name="id" value="<?= \$_POST["id"] ?>" >
      <input type="hidden" name="action" value="update">

      <label for="$FIELD">$FIELD :</label>
      <input type="text" id="$FIELD" placeholder="$FIELD" name="$FIELD" value="<?= \$$DATANAME["$FIELD"] ?>" required>
   
      <button type="submit" name="submit">Update</button>
   </form>
</body>
</html>
EOL

echo "[✓] file $DATANAME-database/update-data.php [✓]"

# =========== $DATANAME-database/delete-data.php ===========
cat <<EOL > "$DATANAME-database/delete-data.php"
<?php

require "./mysql-function.php";

// Cek akses masuk kehalaman ini
check_crud_access("delete");
// Ambil nama action dari parameter POST untuk callback
\$action = \$_POST["action"];
// Ambil $DATANAME dari parameter POST untuk pesan notifikasi
\$$DATANAME = \$_POST["$FIELD"];
// Ambil id $DATANAME dari parameter POST untuk cari target yang mau dihapus
\$id = \$_POST["id"];
// Isi dari alert sukses
\$succes = \$$DATANAME." has been deleted !";
// Isi dari alert gagal
\$failed = \$$DATANAME." failed to delete !";

//Jalankan function mysql callback create
mysql_crud(\$action,\$id,\$succes,\$failed);

?>

<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Delete $DATANAME</title>
</head>
</html>
EOL

echo "[✓] file $DATANAME-database/delete-data.php [✓]"
echo ""
echo "[✓] SCRIPT DONE [✓]"