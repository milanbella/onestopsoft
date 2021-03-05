// This is useTranslation() hook isnspired by https://react.i18next.com/latest/usetranslation-hook 
let cFILE = "Cb_translate.res"

let modulesRootPath = "locales"

let fetchModule = (lang: string, moduleName: string): Js.Promise.t<string> => {
  let cFUNC = "fetchModule()"

  let path = `${modulesRootPath}/${lang}/${moduleName}.json`
  try {
    let txt = Cb_node.Fs.readFileSync(path, "utf8")
    Js.Promise.resolve(txt)
  } catch {
  | Js.Exn.Error(obj) =>
    switch Js.Exn.message(obj) {
    | Some(m) => 
      Cb_logger.errorE(cFILE, cFUNC, "error while reading form file", obj)
      Js.Promise.reject(Cb_exception.BAD_FILE)
    | None =>
      Cb_logger.error(cFILE, cFUNC, "error while reading form file")
      Js.Promise.reject(Cb_exception.BAD_FILE)
    }
  | _ =>
    Cb_logger.error(cFILE, cFUNC, "error while reading form file")
    Js.Promise.reject(Cb_exception.BAD_FILE)
  }
}

let translateKey = C.Translation.makeTranslation(fetchModule)
