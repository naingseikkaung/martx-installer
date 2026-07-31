const fs = require("fs");

const [sourcePng, outputIco] = process.argv.slice(2);
if (!sourcePng || !outputIco) throw new Error("Usage: node create-ico.js <source.png> <output.ico>");
const png = fs.readFileSync(sourcePng);
// ICO supports PNG payloads directly. The source logo is square and Windows
// uses the embedded PNG at the appropriate shell size.
const header = Buffer.alloc(6);
header.writeUInt16LE(0, 0);
header.writeUInt16LE(1, 2);
header.writeUInt16LE(1, 4);
const directory = Buffer.alloc(16);
directory.writeUInt8(0, 0); // width 256 (0 means 256)
directory.writeUInt8(0, 1); // height 256 (0 means 256)
directory.writeUInt8(0, 2);
directory.writeUInt8(0, 3);
directory.writeUInt16LE(1, 4);
directory.writeUInt16LE(32, 6);
directory.writeUInt32LE(png.length, 8);
directory.writeUInt32LE(22, 12);
fs.writeFileSync(outputIco, Buffer.concat([header, directory, png]));
