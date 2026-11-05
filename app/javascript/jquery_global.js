// ビュー内のインラインスクリプト（$ を使うもの）と、管理画面の AdminLTE 3 / Bootstrap 4 は
// グローバルの $ / jQuery を参照するため、他のモジュールより先に読み込んで公開する。
import jquery from "jquery"

window.$ = window.jQuery = jquery
