const crypto = require("crypto");
const path = require("path");

try { require("dotenv").config({ path: path.join(process.env.HOME, ".finhay/credentials/.env") }); }
catch { console.error("ERROR: dotenv required. Run: npm install dotenv"); process.exit(1); }

const [method, endpoint, query] = process.argv.slice(2);
if (!method || !endpoint) { console.error("Usage: request.js METHOD PATH [QUERY]"); process.exit(1); }

const { FINHAY_API_KEY: apiKey, FINHAY_API_SECRET: apiSecret } = process.env;
const baseUrl = process.env.FINHAY_BASE_URL || "https://open-api.fhsc.com.vn";
if (!apiKey || !apiSecret) { console.error("ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required."); process.exit(1); }

const timestamp = String(Date.now());
const signature = crypto.createHmac("sha256", apiSecret).update(`${timestamp}\n${method}\n${endpoint}\n`).digest("hex");

fetch(`${baseUrl}${endpoint}${query ? `?${query}` : ""}`, {
  method,
  headers: {
    "X-FH-APIKEY": apiKey,
    "X-FH-TIMESTAMP": timestamp,
    "X-FH-NONCE": crypto.randomBytes(16).toString("hex"),
    "X-FH-SIGNATURE": signature,
  },
  signal: AbortSignal.timeout(30000),
}).then(async (res) => {
  const body = await res.text();
  if (res.status >= 400) { console.error(`ERROR: HTTP ${res.status}\n${body}`); process.exit(1); }
  const json = JSON.parse(body);
  if (json.error_code && json.error_code !== "0") { console.error(`ERROR: error_code=${json.error_code}\n${body}`); process.exit(1); }
  process.stdout.write(body);
}).catch((e) => { console.error(`ERROR: ${e.message}`); process.exit(1); });
