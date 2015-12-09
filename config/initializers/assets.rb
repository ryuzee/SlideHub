# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += ['sticky-footer-navbar.css']
Rails.application.config.assets.precompile += ['jquery-1.10.2.min.js']
Rails.application.config.assets.precompile += ['jquery.lazyload.js']
Rails.application.config.assets.precompile += ['jquery.sticky-kit.min.js']
Rails.application.config.assets.precompile += ['mousetrap.min.js']
Rails.application.config.assets.precompile += ['js.cookie-2.0.4.min.js']
Rails.application.config.assets.precompile += %w( *.svg *.eot *.woff *.ttf )

NonStupidDigestAssets.whitelist = [/glyphicons-halflings-regular\.(eot|svg|woff|ttf)/]
NonStupidDigestAssets.whitelist += ['jquery-1.10.2.min.js']
NonStupidDigestAssets.whitelist += ['jquery.lazyload.js']
NonStupidDigestAssets.whitelist += ['mousetrap.min.js']
