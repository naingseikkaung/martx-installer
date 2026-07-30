const fs = require("fs");
const path = require("path");

const root = path.resolve(process.argv[2]);
if (!root) throw new Error("Usage: node verify-package.js <stage-root>");
const required = ["runtime/node.exe", "service/nssm.exe", "backend/server.js", "backend/src", "backend/node_modules", "frontend/dist/index.html"];
const forbidden = ["tools", "keys", "backend/data", ".env", ".sqlite", ".sqlite-wal", ".sqlite-shm", "test-results"];
for (const item of required) if (!fs.existsSync(path.join(root, item))) throw new Error(`Missing package item: ${item}`);
const violations = [];
function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    const rel = path.relative(root, full).replaceAll(path.sep, "/").toLowerCase();
    if (forbidden.some((part) => rel.includes(part))) violations.push(rel);
    if (entry.isDirectory()) walk(full);
  }
}
walk(root);
if (violations.length) throw new Error(`Forbidden package paths:\n${violations.join("\n")}`);
console.log(`Package verification passed: ${root}`);
