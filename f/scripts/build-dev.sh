set -xe
npm run sync
npm run build
npm run webpack
cp html/*.html ../b/public/
cp -r locales/ ../b/public/
cp -rf assets/* ../b/public/
