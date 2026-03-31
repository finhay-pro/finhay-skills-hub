const crypto = require("crypto");
const fs = require("fs");
const path = require("path");

const credPath = path.join(process.env.HOME, ".finhay/credentials/.env");
if (fs.existsSync(credPath)) {
  for (const line of fs.readFileSync(credPath, "utf8").split("\n")) {
    const m = line.match(/^([A-Z_]+)=(.+)$/);
    if (m && !process.env[m[1]]) process.env[m[1]] = m[2];
  }
}

const [method, endpoint, query] = process.argv.slice(2);
if (!method || !endpoint) { console.error("Usage: request.js METHOD PATH [QUERY]"); process.exit(1); }

const { FINHAY_API_KEY: apiKey, FINHAY_API_SECRET: apiSecret } = process.env;
const baseUrl = process.env.FINHAY_BASE_URL || "https://open-api.fhsc.com.vn";
if (!apiKey || !apiSecret) { console.error("ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required."); process.exit(1); }

const timestamp = String(Date.now());
const signature = crypto.createHmac("sha256", apiSecret).update(`${timestamp}\n${method}\n${endpoint}\n`).digest("hex");

(async () => {
  const res = await fetch(`${baseUrl}${endpoint}${query ? `?${query}` : ""}`, {
    method,
    headers: {
      "X-FH-APIKEY": apiKey,
      "X-FH-TIMESTAMP": timestamp,
      "X-FH-NONCE": crypto.randomBytes(16).toString("hex"),
      "X-FH-SIGNATURE": signature,
    },
    signal: AbortSignal.timeout(30000),
  });
  const body = await res.text();
  if (res.status >= 400) { console.error(`ERROR: HTTP ${res.status}\n${body}`); process.exit(1); }
  const json = JSON.parse(body);
  if (json.error_code && json.error_code !== "0") { console.error(`ERROR: error_code=${json.error_code}\n${body}`); process.exit(1); }
  process.stdout.write(body);
})().catch((e) => { console.error(`ERROR: ${e.message}`); process.exit(1); });
