const fs = require("fs");
const os = require("os");
const path = require("path");
const dotenv = require("dotenv");

const FINHAY_HOME = path.join(os.homedir(), ".finhay");
const CREDENTIALS_ENV = path.join(FINHAY_HOME, "credentials/.env");
const REF_ENV = path.join(FINHAY_HOME, "ref/.env");

const loadEnv = (p) => {
  try {
    dotenv.config({ path: p });
  } catch {
    console.error("ERROR: dotenv required. Run: npm install dotenv");
    process.exit(1);
  }
};

const readEnv = (p) => {
  if (!fs.existsSync(p)) return {};
  return dotenv.parse(fs.readFileSync(p, "utf8"));
};

const writeEnv = (p, e) => {
  const data = Object.entries(e).map(([k, v]) => `${k}=${v}`).join("\n") + "\n";
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p + ".tmp", data);
  fs.renameSync(p + ".tmp", p);
};

const setEnv = (e, k, v) => ({ ...e, [k]: String(v) });
const normToken = (v) => String(v).toUpperCase().replace(/[^A-Z0-9]+/g, "_");

module.exports = {
  CREDENTIALS_ENV,
  REF_ENV,
  loadEnv,
  normToken,
  readEnv,
  setEnv,
  writeEnv,
};
