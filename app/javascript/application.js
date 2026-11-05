// esbuild でバンドルし app/assets/builds/application.js に出力する（package.json の build スクリプト）
import "./jquery_global"
import Rails from "@rails/ujs"
import "bootstrap"
import moment from "moment"
import * as tempusDominus from "@eonasdan/tempus-dominus/dist/js/tempus-dominus.min"
import "@fortawesome/fontawesome-free/js/fontawesome.min"
import "@fortawesome/fontawesome-free/js/solid.min"
import "mousetrap/mousetrap.min"
import "sticky-kit/dist/sticky-kit"
import "jquery-lazyload/jquery.lazyload"
import "jquery-match-height/dist/jquery.matchHeight"
import Cookies from "js-cookie"
import Clipboard from "clipboard/dist/clipboard"

Rails.start()

// ビュー内のインラインスクリプトから使うライブラリ
window.moment = moment
window.tempusDominus = tempusDominus
window.Cookies = Cookies
window.Clipboard = Clipboard
