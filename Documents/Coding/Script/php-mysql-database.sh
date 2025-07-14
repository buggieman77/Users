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

# Input primary key table name
while true; do
    read -p "Masukkan primary key dari tabel database: " PRIMARYKEY
    if [[ -n "$PRIMARYKEY" ]]; then
        break
    else
        echo "❌ Nama primary key tidak boleh kosong. ❌"
    fi
done

# Input field/kolom table name
while true; do
    read -p "Masukkan 1 nama field (primary field) dari tabel database: " FIELD
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
   <input type="hidden" name="access" value="entry-point" />
   <button type="submit" name="submit">$DATANAME Manager</button>
</form>
EOL

echo "[✓] button $DATANAME Manager di masukan ke dalam index.html [✓]"

# =========== .htaccess ===========
cat <<EOL >> ".htaccess"
RewriteEngine On
RewriteBase $RELATIVE_PATH

# ======================== ENTRY POINT ========================

RewriteRule ^$DATANAME/?$ $DATANAME-database/pages/read-page.php [L]

# ======================== ALIAS KE FILE ========================

RewriteRule ^add-new-$DATANAME/?$ $DATANAME-database/pages/create-page.php [L]
RewriteRule ^update-[^/]+/?$ $DATANAME-database/pages/update-page.php [L]
RewriteRule ^delete-[^/]+/?$ $DATANAME-database/pages/delete-page.php [L]

# ======================== CONDITION ========================

# Cek jika request mengandung /$DATANAME-database/
RewriteCond %{THE_REQUEST} ^[A-Z]{3,}\s.*?/$DATANAME-database/ [NC]

# Redirect ke /tutorial/pertemuan14/$DATANAME
RewriteRule ^$DATANAME-database/.*$ $RELATIVE_PATH$DATANAME [R=302,L]
EOL

echo "[✓] file .htaccess [✓]"

mkdir -p "$DATANAME-database/pages" 
echo "[✓] Folder $DATANAME-database/pages [✓]"

# =========== $DATANAME-database/pages/create-page.php ===========
cat <<EOL > "$DATANAME-database/pages/create-page.php"
<?php 
require __DIR__ . "/../script/mysql-database.php"; 
checkFormAccess(CREATE_ACCESS, "post");
?>
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Add New <?= DISPLAY_DB_NAME ?></title>
</head>
<body>
   <form method="post">
      <input type="hidden" name="access" value="<?= CREATE_ACCESS ?>"/>

      <?php foreach(VISIBLE_FIELD as \$field) : ?>

      <label for="<?= \$field ?>"><?= \$field ?> :</label>
      <input type="text" id="<?= \$field ?>" placeholder="<?= \$field ?>" name="<?= \$field ?>" value="<?= htmlspecialchars(trim(\$_POST[\$field] ?? null)) ?>" required>
      
      <?php endforeach ?>

      <button class="button" type="submit" name="submit">Create</button>
   </form>
<?php 
if(IS_SUBMIT) {
   \$result = runSqlCommand("insert", ...VISIBLE_FIELD);
   \$success = "✅ " . \$_POST[PRIMARY_FIELD] . " has been created ✅";
   \$failed = "❌ failed to create " . \$_POST[PRIMARY_FIELD] . " ❌";
   if (\$result > 0) {
      header("Location: " . ENTRY_POINT, true, 302);
      exit;
   }
} 
?>
</body>
</html>
EOL

echo "[✓] file $DATANAME-database/pages/create-page.php [✓]"

# =========== $DATANAME-database/pages/read-page.php ===========
cat <<EOL > "$DATANAME-database/pages/read-page.php"
<?php 
require __DIR__ . "/../script/mysql-database.php";
\$${DATANAME}s = runSqlCommand("select", "all");
?>
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title><?= DISPLAY_DB_NAME ?> Data Manager</title>
</head>
<body>
   <form action="add-new-<?= LOWER_DISPLAY_DB_NAME ?>" method="post"> 
      <input type="hidden" name="access" value="<?= CREATE_ACCESS ?>" />
      <button type="submit">Add New <?= DISPLAY_DB_NAME ?></button>
   </form>
   <br><hr><br>

   <?php foreach (\$${DATANAME}s as \$index => \$$DATANAME) : ?>
   <?php ++\$index ?>

   <section>
      <?php foreach(VISIBLE_FIELD as \$field) : ?>
      <h3><?= \$index . ". " . \$field . " : " . \$$DATANAME[\$field] ?></h3>
      <?php endforeach ?>
   </section>
   
   <br>
   <form action="update-<?= \$$DATANAME[PRIMARY_FIELD]?>" method="post">
      <input type="hidden" name="access" value="<?= UPDATE_ACCESS ?>" />
      <input type="hidden" name="<?= PRIMARY_KEY ?>" value="<?= \$$DATANAME[PRIMARY_KEY] ?>">
      <input type="hidden" name="<?= PRIMARY_FIELD ?>" value="<?= \$$DATANAME[PRIMARY_FIELD] ?>">
      <button type="submit" name="confirm">EDIT</button>
   </form>
   <br>

   <form action="delete-<?= \$$DATANAME[PRIMARY_FIELD] ?>" method="post">
      <input type="hidden" name="access" value="<?= DELETE_ACCESS ?>" />
      <input type="hidden" name="<?= PRIMARY_KEY ?>" value="<?= \$$DATANAME[PRIMARY_KEY] ?>">
      <input type="hidden" name="<?= PRIMARY_FIELD ?>" value="<?= \$$DATANAME[PRIMARY_FIELD] ?>">
      <button type="submit" name="confirm" value="delete">DELETE</button>
   </form>
   <br>
   
   <?php endforeach ?>
<?php
\$isDelete = isset(\$_POST["confirm"]) && \$_POST["confirm"] === "delete";

if (\$isDelete){
   \$delete = "⚠ Want to delete " . \$_POST[PRIMARY_FIELD] . " ?";
   \$edit = "📝 Want to edit " . \$_POST[PRIMARY_FIELD] . " ?";
   echo \$delete;
} 
?>
</body>
</html>
EOL

echo "[✓] file $DATANAME-database/pages/read-page.php [✓]"

# =========== $DATANAME-database/pages/update-pages.php ===========
cat <<EOL > "$DATANAME-database/pages/update-page.php"
<?php 
require __DIR__ . "/../script/mysql-database.php";
checkFormAccess(UPDATE_ACCESS, "post");
\$$DATANAME = runSqlCommand("select", PRIMARY_KEY)[0];
?>

<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Updated <?= \$_POST[PRIMARY_FIELD] ?></title>
</head>
<body>
   <form method="post">
      <input type="hidden" name="<?= PRIMARY_KEY ?>" value="<?= \$_POST[PRIMARY_KEY] ?>" >
      <input type="hidden" name="access" value="<?= UPDATE_ACCESS ?>" />

      <?php foreach(VISIBLE_FIELD as \$field) : ?>

      <label for="<?= \$field ?>"><?= \$field ?> :</label>
      <input type="text" id="<?= \$field ?>" placeholder="<?= \$field ?>" name="<?= \$field ?>" value="<?= htmlspecialchars(trim(\$_POST[\$field] ?? \$$DATANAME[\$field] ?? null)) ?>" required>
      
      <?php endforeach ?>

      <button type="submit" name="submit">Update</button>
   </form>
<?php
if(IS_SUBMIT){
   \$success = "✅ " . \$_POST[PRIMARY_FIELD] . " has been updated ✅";
   \$failed = "❌ failed to update " . \$_POST[PRIMARY_FIELD] . " ❌";

   \$result = runSqlCommand("update", PRIMARY_KEY, ...VISIBLE_FIELD);

   if (\$result  > 0) {
      header("Location: " . ENTRY_POINT, true, 302);
      exit;
   }
}
?> 
</body>
</html>
EOL

echo "[✓] file $DATANAME-database/pages/update-page.php [✓]"

# =========== $DATANAME-database/pages/delete-page.php ===========
cat <<EOL > "$DATANAME-database/pages/delete-page.php"
<?php require __DIR__ . "/../script/mysql-database.php";
checkFormAccess(DELETE_ACCESS, "post");
\$success = "✅ " . \$_POST[PRIMARY_FIELD] . " has been deleted ✅";
\$failed  = "❌ failed to delete " . \$_POST[PRIMARY_FIELD] . " ❌";

\$result = runSqlCommand("delete", PRIMARY_KEY);
if (\$result > 0) {
   header("Location: " . ENTRY_POINT, true, 302);
   exit;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <meta name="viewport" content="width=device-width, initial-scale=1.0">
   <title>Delete <?= \$_POST[PRIMARY_FIELD] ?></title>
</head>
<body>
</body>
</html>
EOL

echo "[✓] file $DATANAME-database/pages/delete-page.php [✓]"

mkdir -p "$DATANAME-database/script" 
echo "[✓] Folder $DATANAME-database/script [✓]"

# =========== $DATANAME-database/script/mysql-database.php  ===========
cat <<EOL > "$DATANAME-database/script/mysql-database.php"
<?php
declare(strict_types=1);
mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
require __DIR__ . "/helper/utils.php";

function checkFormAccess(string \$access, string \$method = "post"): void
{
   // adjust input data with  method request params
   \$isGetMethod = (strtolower(\$method) == "get");
   \$input = \$isGetMethod ? \$_GET : \$_POST;

   // @flag (invalid access, invalid method)
   \$invalidAccess= (!isset(\$input["access"]) || ((\$input["access"] ?? null) !== \$access));
   \$invalidMethod = (\$_SERVER["REQUEST_METHOD"] !== strtoupper(\$method));
 
   if (\$invalidMethod || \$invalidAccess) {
      // redirect to entry point
      header("Location: ".ENTRY_POINT, true, 302);
      exit;
   }
}

function runSqlCommand(string \$keyword, mixed ...\$fieldList): array | int 
{
   try {
      // @params (string sqlString, array values, string types, bool hasBindParams, bool isSelectCommand)
      extract(buildSqlComponent(\$keyword, \$fieldList));
      // @params (mysqli connection, mysqli_stmt statement)
      extract(prepareStatement(\$sqlString, \$types, \$values, \$hasBindParams));

      // @return (fetch assoc array) or @return (total affected row)
      \$result = \$isSelectCommand ? executeAndFetch(\$statement) : executeBoundStatement(\$statement);
      // close statement and connection
      closeDatabaseResource(\$connection, \$statement);
   } catch (Throwable \$error) {  
      exceptionHandler(\$error);
   }
   return \$result;
}

function buildSqlComponent(string \$keyword, array \$fieldList): array 
{
   // @params (string command, array fields)
   extract(normalizeParam(\$keyword, \$fieldList));

   // @return (bool isSelectCommand, bool hasBindParams) and @flag (bool hasPrimaryKey)
   extract(setSqlFlag(\$command, \$fields));

   // @params (array sortedField, array escapedField) only escape field not primary key
   extract(fieldsHandler(\$fields, \$hasPrimaryKey));
   
   // @return (array value, string types)
   extract(getInputData(\$sortedField));

   // @return sql string template
   \$sqlString = createSqlString(\$command, \$escapedField, \$hasBindParams);

   return [
      "sqlString" => \$sqlString,
      "values" => \$values, 
      "types" => \$types, 
      "hasBindParams" => \$hasBindParams,
      "isSelectCommand" => \$isSelectCommand,
   ];
}

function prepareStatement(string \$sqlString, string \$types, array \$values, bool \$hasBindParams) : array 
{
   // set exception thrower identifier
   \$identifier = "\n[ ".__FUNCTION__." ]";

   // @return (mysqli connection)
   \$conn = mysqli_connect(DB_HOST, DB_USER, DB_PASS, DB_NAME, DB_PORT, DB_SOCKET);
   if (!\$conn) throw new mysqli_sql_exception("Connection failed : ".mysqli_connect_error().\$identifier);

   // @return (mysqli_statement statement)
   \$stmt = mysqli_prepare(\$conn, \$sqlString);
   if (!\$stmt) throw new mysqli_sql_exception("Prepare failed : ".mysqli_error(\$conn).\$identifier);

   // only bind to hasBindParams flag
   if (\$hasBindParams && !mysqli_stmt_bind_param(\$stmt, \$types, ...\$values)) 
   throw new mysqli_sql_exception("failed to bind : ".mysqli_stmt_error(\$stmt).\$identifier);

   return ["connection" => \$conn, "statement" => \$stmt];
}

function executeBoundStatement(mysqli_stmt \$statement): int 
{
   // set exception thrower identifier
   \$identifier = "\n[ ".__FUNCTION__." ]";

   // execute bound statement
   if (!mysqli_stmt_execute(\$statement)) 
   throw new mysqli_sql_exception("Failed to executed : ".mysqli_stmt_error(\$statement).\$identifier);

   return mysqli_stmt_affected_rows(\$statement);
}

function executeAndFetch(mysqli_stmt \$statement): array 
{
   // set exception thrower identifier
   \$identifier = "\n[ ".__FUNCTION__." ]";

   // execute prepared statement without bind params
   if (!mysqli_stmt_execute(\$statement)) 
   throw new mysqli_sql_exception("Failed to execute : ".mysqli_stmt_error(\$statement).\$identifier);
   
   // @return fetch data result to array
   \$data =  mysqli_stmt_get_result(\$statement);
   \$result = [];
   
   while (\$row = mysqli_fetch_assoc(\$data)) {
      \$result[] = \$row;
   }

   if (empty(\$result)) 
   throw new mysqli_sql_exception("Data is empty".\$identifier);

   return \$result;
}

function closeDatabaseResource(mysqli \$connection, mysqli_stmt \$statement): true 
{
   // set exception thrower identifier
   \$identifier = "\n[ ".__FUNCTION__." ]";

   // close prepared statement
   if (!mysqli_stmt_close(\$statement))
   throw new mysqli_sql_exception("Failed to close statement\n".mysqli_stmt_error(\$statement).\$identifier);

   // close connection with database
   if (!mysqli_close(\$connection))
   throw new mysqli_sql_exception("Failed to close connection\n".mysqli_error(\$connection).\$identifier);

   return true;
}
EOL

echo "[✓] file $DATANAME-database/script/mysql-database.php [✓]"

mkdir -p "$DATANAME-database/script/helper" 
echo "[✓] Folder $DATANAME-database/script/helper [✓]"

# =========== $DATANAME-database/script/helper/global-variable.php ===========
cat <<EOL > "$DATANAME-database/script/helper/global-variable.php"
<?php

define("DB_HOST", "localhost");
define("DB_USER", "root");
define("DB_PASS", "");
define("DB_NAME", "$DATANAME");
define("DB_TABLE_NAME", "$TABLENAME");
define("DB_PORT", null);
define("DB_SOCKET", null);

define("PROJECT_ROOT", "$RELATIVE_PATH");
define("ENTRY_POINT", PROJECT_ROOT . DB_NAME);

define("DISPLAY_DB_NAME", ucfirst(strtolower(DB_NAME)));
define("LOWER_DISPLAY_DB_NAME", strtolower(DISPLAY_DB_NAME));

define("PRIMARY_FIELD", "$FIELD");
define("PRIMARY_KEY", "$PRIMARYKEY");
define("VISIBLE_FIELD", [PRIMARY_FIELD]);

define("CREATE_ACCESS", "create");
define("DELETE_ACCESS", "delete");
define("UPDATE_ACCESS", "update");

define("IS_SUBMIT", isset(\$_POST["submit"]));
EOL
echo "[✓] file $DATANAME-database/script/helper/global-variable.php [✓]"

# =========== $DATANAME-database/script/helper/utils.php ===========
cat <<EOL > "$DATANAME-database/script/helper/utils.php"
<?php
require __DIR__ . "/global-variable.php" ;

// ================================== build_sql_component utils ==================================

function normalizeParam(string \$keyword, array \$fieldList): array 
{
   // @return normalize keyword to lower case
   \$normalizedKeyword = strtolower(\$keyword);

   // unwrap nested array
   \$isNestedArray = (is_array(\$fieldList[0]) && count(\$fieldList) === 1);
   \$flatFieldList = \$isNestedArray ? \$fieldList[0] : \$fieldList;

   // @return normalize fieldList to lower case
   \$normalize = fn(\$field) => strtolower(\$field);
   \$normalizedField = array_map(\$normalize, \$flatFieldList);

   return ["command" => \$normalizedKeyword, "fields" => \$normalizedField];
}

function setSqlFlag(string \$command, array \$fields): array 
{
  // @return flag set (select command, has bind parameters, has primary key)
   \$SelectCommandFlag =  (\$command === "select");
   \$BindParamsFlag = !(count(\$fields) === 1 && is_string(\$fields[0]) && strtolower(\$fields[0]) === "all");
   \$includePrimaryKeyFlag = (in_array(PRIMARY_KEY, \$fields));

   return [
      "isSelectCommand" => \$SelectCommandFlag,
      "hasBindParams" => \$BindParamsFlag,
      "hasPrimaryKey" => \$includePrimaryKeyFlag 
   ];
}

function fieldsHandler(array \$fields, bool \$hasPrimaryKey): array 
{
   // unset primary key from field array
   \$filter = fn(\$field) => \$field !== PRIMARY_KEY;
   \$filteredField =  \$hasPrimaryKey ? array_filter(\$fields, \$filter) : \$fields;
   
   // @return escape fields from sql reserved word (no escape primary key)
   \$escapeReserveWord = fn(\$field) => "\`\$field\`";
   \$escapedReserveWord= array_map(\$escapeReserveWord, \$filteredField);

   // @return move primary key to end
   \$reorderField = \$hasPrimaryKey ? [...\$filteredField, PRIMARY_KEY] : \$filteredField;

   return ["sortedField" => \$reorderField, "escapedField" => \$escapedReserveWord ];
}

function getInputData(array \$sortedField): array 
{
   // adjust request method
   \$isGetMethod = \$_SERVER["REQUEST_METHOD"] === strtoupper("get");
   \$rawInput= \$isGetMethod ? \$_GET : \$_POST;

   // @return sanitize input from request method
   \$sanitizeInput = fn(\$field) => htmlspecialchars(trim(\$rawInput[\$field] ?? \$field));
   \$sanitizedInput = array_map(\$sanitizeInput, \$sortedField);

   // @return infer type each input
   \$inputTypes = inferInputType(\$sanitizedInput);

   return ["values" => \$sanitizedInput, "types" => \$inputTypes];
}

function inferInputType(array \$sanitizedInput): string 
{  
   // @return each input type (i = integer, b = blob, d = double, s = string)
   \$types = "";
   foreach(\$sanitizedInput as \$input) {
      \$isFloat = (str_contains((string)\$input, "."));
      \$isBlob = (is_resource(\$input) || strlen((string)\$input) > 1000);

      if (is_numeric(\$input)) {
         \$types .= \$isFloat ? "d" : "i";
      } elseif (\$isBlob) {
         \$types .= "b";
      } elseif (is_array(\$input)) {
         throw new InvalidArgumentException("input not support to binding\n[ ".__FUNCTION__." ]");
      } else {
         \$types .=  "s";
      }
   }
   return \$types;
}

function createSqlString(string \$command, array \$escapedField, bool \$hasBindParams): string 
{
   // @params (string columns, string placeholders, setClause)
   extract(createPlaceholder(\$escapedField));

   // @return create sql string template according command
   if (!\$hasBindParams) return "SELECT * FROM ".DB_TABLE_NAME;
   switch(\$command) {
      case "insert" :
         return sprintf("INSERT INTO %s (%s) VALUES (%s)", DB_TABLE_NAME, \$columns, \$placeholders);
      case "update" :
         return sprintf("UPDATE \`%s\` SET %s WHERE \`%s\` = ?", DB_TABLE_NAME, \$setClause, PRIMARY_KEY);
      case "delete" :
         return sprintf("DELETE FROM \`%s\` WHERE \`%s\` = ?", DB_TABLE_NAME, PRIMARY_KEY);
      case "select" :
         return sprintf("SELECT * FROM \`%s\` WHERE \`%s\` = ?", DB_TABLE_NAME, PRIMARY_KEY);
      default :
         throw new InvalidArgumentException(\$command." command is not found\n[ ".__FUNCTION__." ]");
   }
}

function createPlaceholder(array \$escapedField): array 
{
   // @return columns template (escape from sql reserved word)
   \$columnsPlaceholder = implode(", ", \$escapedField);
   // @return question mark placeholder for value
   \$valuePlaceholders = implode(", ", array_fill(0, count(\$escapedField), "?"));
   // @return clause placeholder for set
   \$setPlaceholder = implode(", ", array_map(fn(\$field) => "\$field = ?", \$escapedField));
   
   return [
      "columns" => \$columnsPlaceholder,
      "placeholders" => \$valuePlaceholders,
      "setClause" => \$setPlaceholder
   ];
}

// ================================== HELPER ==================================

function exceptionHandler (Throwable \$error) : string {
   if (\$error instanceof mysqli_sql_exception) {
      \$message =  "🔴 Database error 🔴\n" . \$error->getMessage();
   } elseif (\$error instanceof PDOException) {
      \$message = "🛢️ PDO error 🛢️\n" . \$error->getMessage();
   } elseif (\$error instanceof InvalidArgumentException) {
      \$message = "⚠️ Argumen tidak valid ⚠️\n" . \$error->getMessage();
   } elseif (\$error instanceof OutOfBoundsException) {
      \$message = "📏 Indeks di luar batas 📏\n" . \$error->getMessage();
   } elseif (\$error instanceof LengthException) {
      \$message = "📐 Panjang data tidak sesuai 📐\n" . \$error->getMessage();
   } elseif (\$error instanceof RuntimeException) {
      \$message = "🧨 Runtime exception 🧨\n" . \$error->getMessage();
   } elseif (\$error instanceof LogicException) {
      \$message = "🧠 Logic error 🧠\n" . \$error->getMessage();
   } elseif (\$error instanceof TypeError) {
      \$message = "❌ Tipe data salah ❌\n" . \$error->getMessage();
   } elseif (\$error instanceof ParseError) {
      \$message = "🔤 Kesalahan sintaksis 🔤\n" . \$error->getMessage();
   } elseif (\$error instanceof DivisionByZeroError) {
      \$message = "➗ Pembagian dengan nol ➗\n" . \$error->getMessage();
   } elseif (\$error instanceof AssertionError) {
      \$message = "🔒 Gagal pada assert() 🔒\n" . \$error->getMessage();
   } else {
      \$message = "💥 Error tidak diketahui 💥\n" . \$error->getMessage();
   }
   \$formatMessage =  php_sapi_name() === "cli" 
   ?  \$message 
   :  nl2br(htmlspecialchars("\n".\$message."\n"));

   echo strtoupper(\$formatMessage);
   exit;
}
EOL

echo "[✓] file $DATANAME-database/script/helper/utils.php [✓]"
echo ""
echo "[✓] SCRIPT DONE [✓]"