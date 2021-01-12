set -xe
npm run build
npm run webpack
cp -rf assets/* ../b/public/
