/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

require("jquery")
require("admin-lte/dist/js/adminlte.min")
require("rails-ujs")
window.moment = require("moment")
require("@popperjs/core/dist/umd/popper.min")
window.tempusDominus = require("@eonasdan/tempus-dominus/dist/js/tempus-dominus.min")
require("@fortawesome/fontawesome-free/js/fontawesome.min")
require("@fortawesome/fontawesome-free/js/solid.min")
require("mousetrap/mousetrap.min")
require("sticky-kit/dist/sticky-kit")
require("jquery-lazyload/jquery.lazyload")
require("jquery-match-height/dist/jquery.matchHeight")

window.Cookies = require("js-cookie")
window.Clipboard = require("clipboard/dist/clipboard")

import 'stylesheets/admin.scss'