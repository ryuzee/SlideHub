// jQuery プラグイン（sticky-kit, jquery-lazyload など）とビュー内のインラインスクリプトは
// グローバルの $ / jQuery を参照するため、他のモジュールより先に読み込んで公開する。
import jquery from "jquery"

window.$ = window.jQuery = jquery
