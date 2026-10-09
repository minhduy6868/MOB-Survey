const { spawnSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const webApk = path.join('pwa', 'downloads', 'trovey.apk');
const builtApk = path.join('android', 'app', 'build', 'outputs', 'apk', 'debug', 'app-debug.apk');

if (fs.existsSync(webApk)) {
  fs.unlinkSync(webApk);
  console.log('removed nested APK from webDir before cap sync');
}

function run(cmd, args, cwd) {
  const env = { ...process.env };
  env.JAVA_HOME = 'C:\\Program Files\\Java\\jdk-22';
  env.Path = `${env.JAVA_HOME}\\bin;${env.Path}`;
  const result = spawnSync(cmd, args, { cwd, stdio: 'inherit', shell: true, env });
  if (result.status !== 0) process.exit(result.status || 1);
}

run('npx', ['cap', 'sync', 'android'], process.cwd());
run('.\\gradlew.bat', ['assembleDebug', '--no-daemon'], path.join(process.cwd(), 'android'));

fs.mkdirSync(path.dirname(webApk), { recursive: true });
fs.copyFileSync(builtApk, webApk);
const bytes = fs.statSync(webApk).size;
console.log(`pwa/downloads/trovey.apk  ${(bytes / 1024 / 1024).toFixed(1)} MiB`);
if (bytes > 25 * 1024 * 1024) {
  console.error('APK still over Cloudflare 25 MiB file limit');
  process.exit(1);
}
