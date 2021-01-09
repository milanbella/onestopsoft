set -xe
rm -r ../b/public/*
cp -r locales/ ../b/public/
cp index.html ../b/public/
npm run build
npm run webpack
npm run css-build

