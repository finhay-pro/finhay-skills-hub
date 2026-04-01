#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const pCred = path.join(process.env.HOME, ".finhay/credentials/.env");

// load .env
try { require("dotenv").config({ path: pCred }); }
catch { console.error("ERROR: dotenv required. Run: npm install dotenv"); process.exit(1); }

// ===== helpers =====
const saveEnv = (env, key, value) =>
  env
    .split("\n")
    .filter(l => !l.startsWith(`${key}=`))
    .concat(`${key}=${value}`)
    .filter(Boolean)
    .join("\n") + "\n";

const writeEnv = (p, data) => { fs.writeFileSync(p + ".tmp", data); fs.renameSync(p + ".tmp", p); }

const request = (...args) => JSON.parse(execFileSync("node", [path.join(__dirname, "request.js"), ...args], { encoding: "utf8" }));

// ===== main =====
(async () => {
  let env = fs.existsSync(pCred) ? fs.readFileSync(pCred, "utf8") : "";

  let uid = process.env.USER_ID;
  if (!uid) {
    const apiKey = process.env.FINHAY_API_KEY;
    if (!apiKey) { console.error("ERROR: FINHAY_API_KEY required"); process.exit(1); }

    const owner = request("GET", `/accounts-agent/v1/openapi/api-keys/owner`);
    const subAccounts = owner.data?.sub_accounts || [];
    env = saveEnv(env, "USER_ID", owner.data?.uid);
    subAccounts.forEach(sba => {
      env = saveEnv(env, `SUB_ACCOUNT_${sba.type}`, sba.id);
    });
    if (!uid) { console.error("ERROR: userId missing in response"); process.exit(1); }
    writeEnv(pCred, env);
  }
  console.log("✅ Credentials updated successfully");
})().catch(e => {
  console.error("ERROR:", e.message);
  process.exit(1);
});