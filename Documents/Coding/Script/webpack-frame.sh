#!/bin/bash

# Tangkap Ctrl + C dan keluar dengan pesan
trap "echo -e '\n❌ Script dibatalkan'; exit" INT

# 🧑‍💻 Minta input dari user
read -p "Masukkan GitHub Username: " USERNAME
read -p "Masukkan nama proyek: " PROJECT_NAME

# Cek input kosong
if [ -z "$PROJECT_NAME" ]; then
  echo "Nama proyek tidak boleh kosong!"
  exit 1
fi

# Buat struktur folder
mkdir -p "$PROJECT_NAME/src/template"
mkdir -p "$PROJECT_NAME/src/scss/modules"
mkdir -p "$PROJECT_NAME/src/script/app"
mkdir -p "$PROJECT_NAME/src/assets"/{image,font}
mkdir -p "$PROJECT_NAME/config"

# Buat file webapack.common.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/config/webpack.common.js"
/* ============================
   COMMON WEBPACK CONFIG
   ============================ */

import HtmlWebpackPlugin from "html-webpack-plugin";

export default {
  entry: {
    support: { import: "./src/script/support.js" },
    style: { import: "./src/script/style.js", dependOn: "support" },
    main: { import: "./src/script/index.js", dependOn: "support" },
  },
  optimization: {
    splitChunks: {
      chunks: "all",
    },
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/template/index.html",
      publicPath: "",
    }),
  ],
  module: {
    rules: [
      {
        test: /\.html$/i,
        loader: "html-loader",
      },
      {
        test: /\.(?:js|mjs|cjs)$/,
        exclude: /node_modules/,
        use: {
          loader: "babel-loader",
          options: {
            cacheDirectory: true,
            presets: [
              [
                "@babel/preset-env",
                {
                  targets: {
                    ie: "11", // Tambah ini agar mendukung IE11
                  },
                  useBuiltIns: "usage", // Tambahkan polyfill hanya yang digunakan
                  corejs: "3.36", // Versi core-js terbaru (pastikan sudah diinstal)
                  debug: false, // true jika ingin lihat log transpile saat build
                },
              ],
            ],
          },
        },
      },
    ],
  },
};
EOL

echo "[✓] webpack.common.js [✓]"

# Buat file webpack.dev.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/config/webpack.dev.js"
/* ============================
   DEVELOPMENT WEBPACK CONFIG
   ============================ */

import config from "./webpack.common.js";
import { merge } from "webpack-merge";
import path from "path";
import { fileURLToPath } from "url";
import * as sass from "sass";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export default merge(config, {
  mode: "development",
  devtool: "source-map",
  devServer: {
    static: {
      directory: path.join(__dirname, "../src"),
    },
    hot: true,
    compress: true,
    port: 3000,
    liveReload: true,
  },
  output: {
    filename: "script/[name]/[name].js",
    path: path.resolve(__dirname, "../dev"),
    publicPath: "",
    clean: true,
  },
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|gif|svg|webp)$/i,
        type: "asset/resource",
        generator: {
          filename: "assets/[name][ext]",
        },
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          "style-loader",
          "css-loader",
          {
            loader: "sass-loader",
            options: {
              sourceMap: true,
              sassOptions: {
                quietDeps: true,
              },
              implementation: sass,
            },
          },
        ],
      },
    ],
  },
});
EOL

echo "[✓] webpack.dev.js [✓]"

# Buat file webpack.prod.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/config/webpack.prod.js"
/* ============================
   PRODUCTION WEBPACK CONFIG
   ============================ */

import config from "./webpack.common.js";
import { merge } from "webpack-merge";
import path from "path";
import { fileURLToPath } from "url";
import { glob } from "glob";
import { PurgeCSSPlugin } from "purgecss-webpack-plugin";
import MiniCssExtractPlugin from "mini-css-extract-plugin";
import CssMinimizerPlugin from "css-minimizer-webpack-plugin";

// Konversi __dirname (karena tidak tersedia di ES6 module)
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const PATHS = {
  src: path.join(__dirname, "../src"),
};

export default merge(config, {
  mode: "production",
  output: {
    filename: "script/[name]/[name]-[chunkhash].js",
    path: path.resolve(__dirname, "../public"),
    clean: true,
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "css/[name]-[contenthash].css",
    }),
    new PurgeCSSPlugin({
      paths: glob.sync(`${PATHS.src}/**/*`, { nodir: true }),
      safelist: () => true,
    }),
  ],
  module: {
    rules: [
      {
        test: /\.(png|jpe?g|gif|svg|webp)$/i,
        type: "asset/resource",
        generator: {
          filename: "assets/[name]-[contenthash][ext]",
        },
      },
      {
        test: /\.s[ac]ss$/i,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader",
          {
            loader: "sass-loader",
            options: {
              sassOptions: {
                quietDeps: true,
              },
            },
          },
        ],
      },
    ],
  },
  optimization: {
    minimizer: [`...`, new CssMinimizerPlugin()],
  },
});

const scanned = glob.sync(`${PATHS.src}/**/*.{html,js}`, { nodir: true });
console.log("Files scanned by PurgeCSS:", scanned);
EOL

echo "[✓] webpack.prod.js [✓]"

# Buat file app.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/script/app/app.js"
/* ============================
   APPLICATION JAVASCRIPT
   ============================ */
const clickHandler = (event) => alert("HAPPY CODING");

export { clickHandler };
EOL

echo "[✓] app.js [✓]"

# Buat file index.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/script/index.js"
/* ============================
   MAIN JS
   ============================ */
import { clickHandler } from "./app/app.js";

const button = document.querySelector("button");

button.addEventListener("click", clickHandler);
EOL

echo "[✓] index.js [✓]"

# Buat file style.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/script/style.js"
/* ============================
   CUSTOM STYLE IN JS
   ============================ */
import "../scss/index.scss";
EOL

# Buat file support.js dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/script/support.js"
/* ============================
   JAVASCRIPT LIBRARY (EX:BOOTSTRAP)
   ============================ */
EOL

echo "[✓] support.js [✓]"

# Buat file buttons.scss dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/scss/modules/_buttons.scss"
/* ============================
   SCSS BUTTONS 
   ============================ */

@use "./mixins" as m;

button {
  font-size: 3rem;
  cursor: pointer;
  @include m.flexbox($dir: row);
  @include m.shape(rectangle, 300px, 30px);
  @include m.background(rgb(22, 182, 22), $txt: white, $btn: true);
}
EOL

echo "[✓] _buttons.scss [✓]"

# Buat file _layout.scss dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/scss/modules/_layout.scss"
/* ============================
   SCSS LAYOUT 
   ============================ */

@use "./mixins" as m;

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body,
html {
  height: 100vh;
}

.container {
  width: 100%;
  height: 100%;
  @include m.flexbox($dir: column);
  @include m.background(#292929);
}
EOL

echo "[✓] _layout.scss [✓]"

# Buat file _mixins.scss dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/scss/modules/_mixins.scss"
/* ============================
   SCSS Mixins
   ============================ */
@use "sass:color";
@use "sass:map";
@use "./variables" as var;

@mixin flexbox($j: center, $a: center, $dir: row) {
  display: flex;
  justify-content: $j;
  align-items: $a;
  @if $dir == column {
    flex-direction: $dir;
  }
}

@mixin text-truncate {
  overflow: hidden;
  white-space: nowrap;
  text-overflow: ellipsis;
}

@mixin background($bg, $txt: false, $btn: false, $lighten: false) {
  @if $btn {
    @include button-bg($bg, $lighten);
  } @else {
    background-color: $bg;
  }
  @if $txt {
    color: $txt;
  }
}

@mixin button-bg($color, $light) {
  background-color: $color;
  &:hover {
    background-color: color.adjust($color, $lightness: if($light, 10%, -15%));
  }
}

@mixin shape($shape, $width, $radius: 0px) {
  @if $shape == circle {
    aspect-ratio: 1/1;
    width: $width;
    border-radius: 50%;
  } @else if $shape == square {
    aspect-ratio: 1/1;
    width: $width;
  } @else {
    aspect-ratio: 16/9;
    width: $width;
    border-radius: $radius;
  }
}
EOL

echo "[✓] _mixins.scss.scss [✓]"

# Buat file _variables.scss dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/scss/modules/_variables.scss"
/* ============================
   SCSS VARIABLE 
   ============================ */
EOL

echo "[✓] _variables.scss [✓]"

# Buat file index.scss dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/scss/index.scss"
@use "./modules/layout";
@use "./modules/buttons";
EOL

echo "[✓] index.scss [✓]"

# Buat file index.html dengan isi default
cat <<'EOL' > "$PROJECT_NAME/src/template/index.html"
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Document</title>
  </head>
  <body>
    <div class="container">
      <button>SETUP DONE</button>
    </div>
  </body>
</html>
EOL

echo "[✓] template.html [✓]"

# Buat file index.html dengan isi default
cat <<'EOL' > "$PROJECT_NAME/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Redirecting...</title>
  <script>
    window.location.href = 'public/index.html';
  </script>
</head>
<body>
  <p>Redirecting...</p>
</body>
</html>
EOL

echo "[✓] index.html [✓]"

# Masuk ke folder proyek
cd "$PROJECT_NAME"

# Inisialisasi npm
npm init -y

echo "[✓] npm init [✓]"

# Ubah package.json agar sesuai kebutuhan
if command -v jq >/dev/null 2>&1; then
  jq --arg name "$PROJECT_NAME" '
    .name = $name |
    .version = "1.0.0" |
    .description = "" |
    .main |= empty |
    .private = true |
    .type = "module" |
    .scripts = {
      build: "webpack --config config/webpack.prod.js",
      dev: "webpack --config config/webpack.dev.js",
      serve: "webpack serve --config config/webpack.dev.js"
    } |
    .keywords = [] |
    .author = "" |
    .license = "MIT"
  ' package.json > package.tmp.json && mv package.tmp.json package.json
else
  echo "⚠️  Warning: jq not installed. Skipping safe package.json modification."
fi

echo "[✓] Update package.JSON [✓]"

# Instal semua dependensi
npm install -D @babel/core @babel/preset-env babel-loader core-js css-loader css-minimizer-webpack-plugin html-loader html-webpack-plugin mini-css-extract-plugin purgecss-webpack-plugin sass sass-loader style-loader webpack webpack-cli webpack-dev-server webpack-merge --verbose

echo "[✓] npm install [✓]"

# Initial Project Setup
cat <<EOF > README.md
<h1 align="center">⚙ Project Setup ⚙</h1>

This project is configured with:

- **🛠 Webpack**
- **📜 Babel**
- **🎨 Sass**
- **📖 ES6 Modules**

---

## Usage ⚙

> **Steps:**  
> - [Download this repository](https://github.com/$USERNAME/$PROJECT_NAME/archive/refs/heads/main.zip)  
> - Extract file $PROJECT_NAME.zip
> - Open terminal at repository $PROJECT_NAME 
> - Install dependencies

### 📂 Install all project dependencies, run:

\`\`\`sh
npm install -D @babel/core @babel/preset-env babel-loader core-js css-loader css-minimizer-webpack-plugin html-loader html-webpack-plugin mini-css-extract-plugin purgecss-webpack-plugin sass sass-loader style-loader webpack webpack-cli webpack-dev-server webpack-merge --verbose
\`\`\`

### 🌎 Run in development server (localhost:3000):

\`\`\`sh
npm run serve
\`\`\`

### 🛠 Development mode:

\`\`\`sh
npm run dev
\`\`\`

### 🚀 Build for production:

\`\`\`sh
npm run build
\`\`\`

---

<p align="center">
  <sub>CREATE ON $(date "+%d %B %Y" | tr '[:lower:]' '[:upper:]')</sub>
</p>
EOF

echo "[✓] README.md [✓]"

echo "node_modules/" > .gitignore
echo "dist/" >> .gitignore
echo "dev/" >> .gitignore
echo "public/" >> .gitignore
echo ".vscode/" >> .gitignore
echo "# system files" >> .gitignore
echo ".DS_Store" >> .gitignore
echo "Thumbs.db" >> .gitignore

echo "[✓] .gitignore [✓]"

# Buka folder di VS Code
code .

echo "[✓] Struktur proyek berhasil dibuat di folder $PROJECT_NAME [✓]"