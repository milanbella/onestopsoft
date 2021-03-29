set -xe
rm -rf node_modules
rm -f package-lock.json
npm install
npm run clean
npm run sync
npm run build
