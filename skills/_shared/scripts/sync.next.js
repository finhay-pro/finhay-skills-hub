#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const os = require("os");
const dotenv = require("dotenv");

const REPO = "finhay-pro/finhay-skills-hub";
const BRANCH = "main";
const RAW = `https://raw.githubusercontent.com/${REPO}/${BRANCH}`;
const API = `https://api.github.com/repos/${REPO}`;
const TTL = 12 * 60 * 60 * 1000;

const nSkill = process.argv[2];
if (!nSkill) { console.error("Usage: sync <skill>"); process.exit(1); }

const ROOT = path.resolve(__dirname, "../../");
const SKILL_DIR = path.join(ROOT, nSkill);
const SHARED_DIR = path.join(ROOT, "_shared");
const REF_ENV = path.join(os.homedir(), ".finhay/ref/.env");

if (!fs.existsSync(path.join(SKILL_DIR, "SKILL.md"))) {
  console.error(`Skill not found: ${nSkill}`); process.exit(1);
}

// ===== helpers =====
// load .env
try { require("dotenv").config({ path: REF_ENV }); }
catch { console.error("ERROR: dotenv required. Run: npm install dotenv"); process.exit(1); }

const saveEnv = (env) => {
  const data = Object.entries(env).map(([k,v])=>`${k}=${v}`).join("\n") + "\n";
  fs.mkdirSync(path.dirname(REF_ENV), { recursive: true });
  fs.writeFileSync(REF_ENV + ".tmp", data);
  fs.renameSync(REF_ENV + ".tmp", REF_ENV);
};

const _content = async (url) => {
  const res = await fetch(url, { signal: AbortSignal.timeout(10000) });
  if (!res.ok) throw new Error(url);
  return (await res.text()).trim();
};

const _json = async (url) => {
  const res = await fetch(url, { signal: AbortSignal.timeout(15000) });
  if (!res.ok) throw new Error(url);
  return res.json();
};

const downloader = async (files, tmp) => {
  for (const f of files) {
    const buf = await fetch(`${RAW}/${f}`).then(r => r.arrayBuffer());
    const dest = path.join(tmp, f.replace("skills/", ""));
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, Buffer.from(buf));
  }
};

const replaceDir = (src, dest) => {
  if (!fs.existsSync(src)) return;
  fs.rmSync(dest, { recursive: true, force: true });
  fs.cpSync(src, dest, { recursive: true });
};

// ===== main =====
(async () => {
  const now = Date.now();
  const tree = await _json(`${API}/git/trees/${BRANCH}?recursive=1`);

  // ---- sync _shared ----
  const env = { ...process.env };
  const sharedKey = `SHARED_SYNC_AT`;
  if (!env[sharedKey] || now - env[sharedKey] > TTL) {
    const ver = await _content(`${RAW}/skills/_shared/.version`);
    const files = tree.tree.filter(f => f.type==="blob" && f.path.startsWith("skills/_shared/")).map(f=>f.path);

    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "sync-sh-"));
    await downloader(files, tmp);
    replaceDir(path.join(tmp, "_shared"), SHARED_DIR);
    fs.rmSync(tmp, { recursive: true, force: true });

    env[sharedKey] = now;
    console.log(`_shared: updated (${ver})`);
  }

  // ---- sync skill ----
  const skillKey = `SKILL_${nSkill.toUpperCase()}_SYNC_AT`;
  if (!env[skillKey] || now - env[skillKey] > TTL) {
    const ver = await _content(`${RAW}/skills/${nSkill}/.version`);
    const files = tree.tree.filter(f => f.type==="blob" && f.path.startsWith(`skills/${nSkill}/`)).map(f=>f.path);

    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), `sync-${nSkill}-`));
    await downloader(files, tmp);
    replaceDir(path.join(tmp, nSkill), SKILL_DIR);

    const link = path.join(SKILL_DIR, "_shared");
    try { fs.rmSync(link, { force:true }); fs.symlinkSync("../_shared", link); }
    catch { fs.cpSync(SHARED_DIR, link, { recursive:true }); }

    fs.rmSync(tmp, { recursive:true, force:true });

    env[skillKey] = now;
    console.log(`${nSkill}: synced (${ver})`);
  } else {
    console.log(`${nSkill}: up-to-date`);
  }

  saveEnv(env);
})().catch(e => { console.error("ERROR:", e.message); process.exit(1); });