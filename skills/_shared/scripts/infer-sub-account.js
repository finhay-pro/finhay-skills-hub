const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const credPath = path.join(process.env.HOME, ".finhay/credentials/.env");
const get = (env, key) => env.match(new RegExp(`^${key}=(.+)$`, "m"))?.[1];
const save = (env, key, value) =>
  env.split("\n").filter(l => !l.startsWith(`${key}=`)).concat(`${key}=${value}`).filter(Boolean).join("\n") + "\n";
const run = (...args) => JSON.parse(execFileSync("node", [path.join(__dirname, "request.js"), ...args], { encoding: "utf8" }));

try {
  let env = fs.readFileSync(credPath, "utf8");

  let userId = get(env, "USER_ID");
  if (!userId) {
    const apiKey = get(env, "FINHAY_API_KEY");
    if (!apiKey) { console.error("ERROR: FINHAY_API_KEY required"); process.exit(1); }

    const owner = run("GET", `/auth/v1/openapi/api-keys/${apiKey}/owner`);
    if (!owner.data?.userId) { console.error("ERROR: userId missing in response"); process.exit(1); }

    userId = String(owner.data.userId);
    env = save(env, "USER_ID", userId);
    fs.writeFileSync(credPath, env);
  }

  const profile = run("GET", `/account/users/${userId}/profile`);
  const subs = (profile.result || profile).sub_accounts || [];
  if (!subs.length) { console.error("ERROR: No sub-accounts"); process.exit(1); }

  subs.forEach(a => env = save(env, `SUB_ACCOUNT_${a.account_type}`, a.sub_account_ext));
  fs.writeFileSync(credPath, env);
} catch (e) { console.error(`ERROR: ${e.message}`); process.exit(1); }
