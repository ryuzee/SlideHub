// esbuild でバンドルし app/assets/builds/application.js に出力する（package.json の build スクリプト）。
// レイアウトで defer を付けて読み込むので、ビューに書くスクリプトは DOMContentLoaded のあとに動かす。
// アイコン（Font Awesome）は CDN の CSS で出すので、ここには入れない。
// 日付の選択（moment と tempus-dominus）は、使う画面だけで date_picker.js を読み込む
import "./jquery_global"
import "./image_fallback"
import Rails from "@rails/ujs"
import * as bootstrap from "bootstrap"
import Cookies from "js-cookie"
import ClipboardJS from "clipboard"

Rails.start()

// ビュー内のインラインスクリプトから使うライブラリ
window.bootstrap = bootstrap
window.Cookies = Cookies
window.ClipboardJS = ClipboardJS
