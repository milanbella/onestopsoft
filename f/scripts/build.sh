set -xe
rm -rf node_modules
rm -f package-lock.json
npm install
rm -r ../b/public/*
cp -r locales/ ../b/public/
cp index.html ../b/public/
npm run clean
npm run build
npm run webpack
npm run css-build
cp -r assets/* ../b/public/

