/**
 * Import function triggers from their respective submodules:
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const express = require("express");
const { createProxyMiddleware } = require("http-proxy-middleware");
const cors = require("cors");

const app = express();
app.use(cors({ origin: true }));

// ✅ Replace with your Laravel backend URLN

const backendUrl = "https://database-4b12a.web.app";  


// ✅ Proxy requests to Laravel backend
app.use(
  "/api",  
  createProxyMiddleware({
    target: backendUrl,
    changeOrigin: true,
  })
);

// ✅ Rename the function to avoid conflict
exports.laravelProxy = functions.https.onRequest(app);  // Changed from `app` to `laravelProxy`

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
