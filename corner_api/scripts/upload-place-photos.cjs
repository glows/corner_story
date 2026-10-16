const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const { spawnSync } = require('node:child_process');
const root = path.resolve(__dirname, '..');
const places = JSON.parse(fs.readFileSync(path.join(root, 'data/nyc_places.json'), 'utf8'));
const wrangler = path.join(root, 'node_modules/wrangler/bin/wrangler.js');
for (const place of places) {
  const file = path.resolve(root, place.image_upload_file);
  const hash = crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex').slice(0, 12);
  if (!place.image_r2_key.endsWith(`_${hash}.jpg`)) throw new Error(`Photo hash changed: ${place.id}`);
  const result = spawnSync(process.execPath, [wrangler, 'r2', 'object', 'put',
    `corner-editorial-media/${place.image_r2_key}`, '--file', file, '--remote',
    '--content-type', 'image/jpeg', '--cache-control', 'public, max-age=31536000, immutable'],
  { cwd: root, stdio: 'inherit' });
  if (result.status !== 0) process.exit(result.status || 1);
  console.log(`Uploaded ${place.id}`);
}
