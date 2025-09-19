 module.exports = function override (config, env) {
     console.log('override')
     let loaders = config.resolve
     loaders.fallback = {
         "fs": false,
         "tls": false,
         "net": false,
         "http": require.resolve("stream-http"),
         "https": false,
         "zlib": require.resolve("browserify-zlib") ,
         "path": require.resolve("path-browserify"),
         "stream": require.resolve("stream-browserify"),
         "util": require.resolve("util/"),
         "crypto": require.resolve("crypto-browserify")
     }
     return config
 }

//  module.exports = {
//       devServer: function(configFunction) {
//         return function(proxy, allowedHost) {
//           const config = configFunction(proxy, allowedHost);
//           // Add your proxy configuration here
//           config.proxy = {
//             '/api': { // Any request starting with /api will be proxied
//               target: 'http://localhost:3000', // Your backend API server URL
//               changeOrigin: true, // Important for virtual hosting
//               secure: false, // Set to true if your backend uses HTTPS
//             },
//           }
//           return config
//         }
//       },
//     }


// const { override, addWebpackProxy } = require('customize-cra')

// module.exports = override(
//   addWebpackProxy({
//     '/api': {
//       target: 'http://localhost:3001', // バックエンドのAPIサーバーのURL
//       changeOrigin: true,
//       //pathRewrite: { '^/api': '' }, // 必要に応じてパスを書き換える
//     },
//   })
// )