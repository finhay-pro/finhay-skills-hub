#!/usr/bin/env node

const path = require("path");
const { execFileSync } = require("child_process");
const {
  CREDENTIALS_ENV,
  loadEnv,
  readEnv,
  setEnv,
  writeEnv,
} = require("./env-utils");

const pCred = CREDENTIALS_ENV;
loadEnv(pCred);

// ===== helpers =====
const request = (...args) => JSON.parse(execFileSync("node", [path.join(__dirname, "request.js"), ...args], { encoding: "utf8" }));
const upperCase = str => String(str).toUpperCase();

// ===== main =====
(async () => {
  let env = readEnv(pCred);

  let uid = process.env.USER_ID;
  if (!uid) {
    const apiKey = process.env.FINHAY_API_KEY;
    if (!apiKey) { console.error("ERROR: FINHAY_API_KEY required"); process.exit(1); }

    const response = request("GET", `/users/oa/me`);
    const owner = response.result;
    uid = owner?.uid;
    const subAccounts = owner?.sub_accounts || [];
    if (!uid) { console.error("ERROR: userId missing in response"); process.exit(1); }
    env = setEnv(env, "USER_ID", uid);
    subAccounts.forEach(sba => {
      const subAccountType = sba.type || "unknown";
      env = setEnv(env, `SUB_ACCOUNT_${upperCase(subAccountType)}`, sba.id);
      env = setEnv(env, `SUB_ACCOUNT_EXT_${upperCase(subAccountType)}`, sba.sub_account_ext);
    });
    writeEnv(pCred, env);
  }
  console.log("✅ Credentials updated successfully");
})().catch(e => {
  console.error("ERROR:", e.message);
  process.exit(1);
});
