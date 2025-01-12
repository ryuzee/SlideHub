const { environment } = require('@rails/webpacker');
const webpack = require('webpack');

environment.plugins.append(
    'Provide',
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery',
        Popper: ['@popperjs/core', 'default'],
    })
);

environment.plugins.append(
    'Provide',
    new webpack.ProvidePlugin({
        Cookies: 'js-cookie/src/js.cookie.js'
    })
);

environment.plugins.append(
    'Provide',
    new webpack.ProvidePlugin({
        Clipboard: 'clipboard/dist/clipboard.js'
    })
);

environment.plugins.append(
    'Provide',
    new webpack.ProvidePlugin({
        tempusDominus: '@eonasdan/tempus-dominus/dist/js/tempus-dominus.min.js'
    })
);

environment.loaders.append('expose', {
    test: require.resolve('jquery'), // jQuery のパスを指定
    use: [
        {
            loader: 'expose-loader',
            options: {
                exposes: ['$', 'jQuery'], // $ と jQuery をグローバルに設定
            },
        },
    ],
});

module.exports = environment;
