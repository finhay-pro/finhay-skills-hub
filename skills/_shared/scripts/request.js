const crypto = require("crypto");
const { loadEnv, CREDENTIALS_ENV, readEnv, setEnv, writeEnv} = require("./env-utils");
const { decode } = require("./http-utils");
loadEnv(CREDENTIALS_ENV);
const env = readEnv(CREDENTIALS_ENV);

const [method, endpoint, param, body] = process.argv.slice(2);
if (!method || !endpoint) { 
  process.stderr.write("Usage: METHOD PATH [param] [BODY]\n"); 
  process.exit(1); 
}

const { FINHAY_API_KEY: apiKey, FINHAY_API_SECRET: apiSecret } = process.env;
const baseUrl = process.env.FINHAY_BASE_URL || "https://open-api.fhsc.com.vn";
if (!apiKey || !apiSecret) { 
  process.stderr.write("ERROR: API key/secret missing\n"); 
  process.exit(1); 
}

// HMAC signature
const createSig = () => {
  const ts = Date.now().toString();
  const sig = crypto.createHmac("sha256", apiSecret)
    .update(`${ts}\n${method}\n${endpoint}\n`).digest("hex");
  return { ts, sig };
};

// Build query string
const formatqueries = (q) => q ? `?${q}` : "";

// Call API
const callApi = async (param, body) => {
  const { ts, sig } = createSig();
  const url = `${baseUrl}${endpoint}${formatqueries(param)}`;
  const headers = {
    "X-FH-APIKEY": apiKey,
    "X-FH-TIMESTAMP": ts,
    "X-FH-NONCE": crypto.randomBytes(16).toString("hex"),
    "X-FH-SIGNATURE": sig,
    "Content-Type": "application/json",
  };
  return fetch(url, { method, headers, body: body || undefined, signal: AbortSignal.timeout(30000) });
};

const sub = (headers) => JSON.parse(decode(headers.get("x-userinfo")||""))?.sub;
(async () => {
  try {
    const res = await callApi(param, body);
    process.stdout.write(await res.text());
    const uid = sub(res.headers);

    if (!env['USER_ID'] || env['USER_ID'] !== uid) {
      env = setEnv(env, 'USER_ID', uid);
      writeEnv(CREDENTIALS_ENV, env);
    }
  } catch(e) {
    process.stderr.write(`ERROR: ${e.message}\n`);
    process.exit(1);
  }
})();