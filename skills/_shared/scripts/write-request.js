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

const args = process.argv.slice(2);
const dryRun = args.includes("--dry-run");
const filtered = args.filter((a) => a !== "--dry-run");
const [method, endpoint, bodyJson, query] = filtered;

if (!method || !endpoint || !bodyJson) {
  console.error("Usage: write-request.js METHOD PATH BODY_JSON [QUERY] [--dry-run]");
  process.exit(1);
}

if (method.toUpperCase() === "GET") {
  console.error("ERROR: write-request.js does not support GET. Use request.js instead.");
  process.exit(1);
}

try { JSON.parse(bodyJson); } catch {
  console.error("ERROR: BODY_JSON is not valid JSON."); process.exit(1);
}

const { FINHAY_API_KEY: apiKey, FINHAY_API_SECRET: apiSecret } = process.env;
const baseUrl = process.env.FINHAY_BASE_URL || "https://open-api.fhsc.com.vn";
if (!apiKey || !apiSecret) { console.error("ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required."); process.exit(1); }

const timestamp = String(Date.now());
const nonce = crypto.randomBytes(16).toString("hex");
const bodyHash = crypto.createHash("sha256").update(bodyJson, "utf8").digest("hex");
const payload = `${timestamp}\n${method.toUpperCase()}\n${endpoint}\n${bodyHash}`;
const signature = crypto.createHmac("sha256", apiSecret).update(payload).digest("hex");

const url = `${baseUrl}${endpoint}${query ? `?${query}` : ""}`;
const headers = {
  "Content-Type": "application/json",
  "X-FH-APIKEY": apiKey,
  "X-FH-TIMESTAMP": timestamp,
  "X-FH-NONCE": nonce,
  "X-FH-SIGNATURE": signature,
  "X-FH-BODYHASH": bodyHash,
};

if (dryRun) {
  const maskedHeaders = { ...headers, "X-FH-APIKEY": headers["X-FH-APIKEY"].slice(0, 8) + "********" };
  console.log("=== DRY RUN ===");
  console.log(`${method.toUpperCase()} ${url}`);
  console.log("Headers:", JSON.stringify(maskedHeaders, null, 2));
  console.log("Body:", bodyJson);
  console.log("Signing payload:", JSON.stringify(payload));
  console.log("Body hash:", bodyHash);
  console.log("===============");
  process.exit(0);
}

fetch(url, {
  method: method.toUpperCase(),
  headers,
  body: bodyJson,
  signal: AbortSignal.timeout(30000),
}).then(async (res) => {
  const body = await res.text();
  if (res.status >= 400) { console.error(`ERROR: HTTP ${res.status}\n${body}`); process.exit(1); }
  let json;
  try { json = JSON.parse(body); } catch {
    console.error(`ERROR: Non-JSON response\n${body}`); process.exit(1);
  }
  if (json.error_code && json.error_code !== "0" && json.error_code !== null) {
    console.error(`ERROR: error_code=${json.error_code}\n${body}`); process.exit(1);
  }
  process.stdout.write(body);
}).catch((e) => { console.error(`ERROR: ${e.message}`); process.exit(1); });
