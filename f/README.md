Never edit any rescript file in `./c` folder edit instead same file in `../c` folder.
`./c` folder files are being copied from common `../c` folder by `npm run sync`.

To build run:

```
npm run sync && npm run build
```

