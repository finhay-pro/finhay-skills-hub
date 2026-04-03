#!/usr/bin/env node
import path from "path";
import { execFile } from "child_process";
import { CREDENTIALS_ENV, loadEnv, readEnv, setEnv, writeEnv } from "./env-utils";

loadEnv(CREDENTIALS_ENV);
const pCred = CREDENTIALS_ENV;
const upperCase = str => String(str).toUpperCase();

// ===== helper: async request =====s
const request = (...args) =>
  new Promise((resolve, reject) => {
    execFile("node", [path.join(process.cwd(), "request.js"), ...args], { encoding: "utf8" }, (err, stdout, stderr) => {
      if (err) return reject(err);
      try {
        resolve(JSON.parse(stdout));
      } catch {
        reject(new Error(`Invalid JSON response: ${stdout}`));
      }
    });
  });

// ===== main =====
(async () => {
  try {
    await request("GET", "/users/health");
    let env = readEnv(pCred);
    const { USER_ID, SUB_ACCOUNT_NORMAL, SUB_ACCOUNT_MARGIN, FINHAY_API_KEY } = process.env;
    if (!FINHAY_API_KEY) throw new Error("FINHAY_API_KEY required");

    const endpoints = {
      subAccounts: uid => `/users/v1/users/${uid}/sub-accounts`,
    };

    if (!SUB_ACCOUNT_NORMAL || !SUB_ACCOUNT_MARGIN) {
      const subAccounts = (await request("GET", endpoints.subAccounts(USER_ID)))?.result || [];
      subAccounts.forEach(({ type = "unknown", id, sub_account_ext }) => {
        const key = upperCase(type);
        env = setEnv(env, `SUB_ACCOUNT_${key}`, id);
        env = setEnv(env, `SUB_ACCOUNT_EXT_${key}`, sub_account_ext);
      });

      writeEnv(pCred, env);
    }

    console.log("✅ Credentials updated successfully");
  } catch(e) {
    console.error("ERROR:", e.message);
    process.exit(1);
  }
})();