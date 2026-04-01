#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const os = require("os");
const {
  REF_ENV,
  loadEnv,
  normToken,
  readEnv,
  writeEnv,
} = require("./env-utils");
const { download, json, text } = require("./http-utils");

const REPO = "finhay-pro/finhay-skills-hub";
const BRANCH = "main";
const RAW = `https://raw.githubusercontent.com/${REPO}/${BRANCH}`;
const API = `https://api.github.com/repos/${REPO}`;
const TTL = 12 * 60 * 60 * 1000;

const skillsDir = (dir) => {
  try {
    return path.basename(dir) === "skills";
  } catch {
    return false;
  }
};

const nSkill = process.argv[2];
if (!nSkill) { console.error("Usage: sync.sh <skill>"); process.exit(1); }

let ROOT = __dirname;
while (!skillsDir(ROOT)) {
  const parent = path.dirname(ROOT);
  if (parent === ROOT) {
    console.error("Error: Could not find skills directory in the path hierarchy.");
    process.exit(1);
  }
  ROOT = parent;
}
const SKILL_DIR = path.join(ROOT, nSkill);
const SHARED_DIR = path.join(ROOT, "_shared");

if (!fs.existsSync(path.join(SKILL_DIR, "SKILL.md"))) {
  console.error(`Skill not found: ${nSkill}`); process.exit(1);
}

// ===== helpers =====
loadEnv(REF_ENV);

const replaceDir = (src, dest) => {
  if (!fs.existsSync(src)) return;
  fs.rmSync(dest, { recursive: true, force: true });
  fs.cpSync(src, dest, { recursive: true });
};

// ===== main =====
(async () => {
  const now = Date.now();
  const tree = await json(`${API}/git/trees/${BRANCH}?recursive=1`);

  // ---- sync _shared ----
  const env = readEnv(REF_ENV);
  const sharedKey = `SHARED_SYNC_AT`;
  if (!env[sharedKey] || now - env[sharedKey] > TTL) {
    const ver = await text(`${RAW}/skills/_shared/.version`);
    const files = tree.tree.filter(f => f.type === "blob" && f.path.startsWith("skills/_shared/")).map(f => f.path);

    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), "sync-sh-"));
    await download({ files, baseUrl: RAW, outDir: tmp });
    replaceDir(path.join(tmp, "_shared"), SHARED_DIR);
    fs.rmSync(tmp, { recursive: true, force: true });

    env[sharedKey] = now;
    console.log(`_shared: updated (${ver})`);
  }

  // ---- sync skill ----
  const skillKey = `SKILL_${normToken(nSkill)}_SYNC_AT`;
  if (!env[skillKey] || now - env[skillKey] > TTL) {
    const ver = await text(`${RAW}/skills/${nSkill}/.version`);
    const files = tree.tree.filter(f => f.type === "blob" && f.path.startsWith(`skills/${nSkill}/`)).map(f => f.path);

    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), `sync-${nSkill}-`));
    await download({ files, baseUrl: RAW, outDir: tmp });
    replaceDir(path.join(tmp, nSkill), SKILL_DIR);
    fs.rmSync(tmp, { recursive: true, force: true });

    env[skillKey] = now;
    console.log(`${nSkill}: synced (${ver})`);
  } else {
    console.log(`${nSkill}: up-to-date`);
  }

  writeEnv(REF_ENV, env);
})().catch(e => { console.error("ERROR:", e.message); process.exit(1); });
