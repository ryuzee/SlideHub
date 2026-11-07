// 日付の選択（検索画面など）。使う画面だけで、application.js のあとに読み込む（どちらも defer）
import moment from "moment"
import * as tempusDominus from "@eonasdan/tempus-dominus/dist/js/tempus-dominus.min"

window.moment = moment
window.tempusDominus = tempusDominus
