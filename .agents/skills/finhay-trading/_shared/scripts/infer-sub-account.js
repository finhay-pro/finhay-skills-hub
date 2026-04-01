const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const credPath = path.join(process.env.HOME, ".finhay/credentials/.env");
const env = fs.readFileSync(credPath, "utf8");
const userId = env.match(/^USER_ID=(.+)$/m)?.[1];
if (!userId) { console.error("ERROR: USER_ID required"); process.exit(1); }

const data = JSON.parse(execFileSync("node", [path.join(__dirname, "request.js"), "GET", `/account/users/${userId}/profile`], { encoding: "utf8" }));
const subs = (data.result || data).sub_accounts || [];
if (!subs.length) { console.error("ERROR: No sub-accounts"); process.exit(1); }

const lines = env.split("\n").filter(l => !l.startsWith("SUB_ACCOUNT_"));
subs.forEach(a => lines.push(`SUB_ACCOUNT_${a.account_type}=${a.sub_account_ext}`));
fs.writeFileSync(credPath, lines.filter(Boolean).join("\n") + "\n");
