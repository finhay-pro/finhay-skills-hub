const fs = require("fs");
const path = require("path");

const text = async (url, timeoutMs = 10000) => {
  const res = await fetch(url, { signal: AbortSignal.timeout(timeoutMs) });
  if (!res.ok) throw new Error(url);
  return (await res.text()).trim();
};

const json = async (url, timeoutMs = 15000) => {
  const res = await fetch(url, { signal: AbortSignal.timeout(timeoutMs) });
  if (!res.ok) throw new Error(url);
  return res.json();
};

const write = (dest, data) => {
  const temp = `${dest}.tmp`;
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(temp, data);
  fs.renameSync(temp, dest);
};

const download = async ({ files, baseUrl, outDir, stripPrefix = "skills/", timeoutMs = 15000 }) => {
  for (const file of files) {
    const res = await fetch(`${baseUrl}/${file}`, { signal: AbortSignal.timeout(timeoutMs) });
    if (!res.ok) throw new Error(`Failed to download ${file}: HTTP ${res.status}`);

    const buf = await res.arrayBuffer();
    const dest = path.join(outDir, file.replace(stripPrefix, ""));
    write(dest, Buffer.from(buf));
  }
};

module.exports = {
  download,
  json,
  text,
  write
};
