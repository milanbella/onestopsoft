// This is useTranslation() hook isnspired by https://react.i18next.com/latest/usetranslation-hook

let cFILE = "Translation.re"


let modulesRootPath = "locales"

let fetchModule = (lang, moduleName) => {

  Fetch.fetch("/" ++ (modulesRootPath ++ ("/" ++ (lang ++ "/" ++ (moduleName ++ ".json")))))
  |> Js.Promise.then_(Fetch.Response.text)
}

let translateKey = C.Translation.makeTranslation(fetchModule)

let useTranslate = () => {
  let cFUN = "useTranslate()";

  (~key, ~bindings=?, ()) => {
    let (translatedKeyValue, setStatetranslatedKeyValue) = React.useState(() => "");
    ignore( 
      switch(bindings) {
      | Some(b) => translateKey(~key, ~bindings=b, ())
      | None => translateKey(~key, ()) 
      } |> Js.Promise.then_((translatedKeyValue) => {
            setStatetranslatedKeyValue(_ => translatedKeyValue);
            Js.Promise.resolve(());
          })
        |> Js.Promise.catch((exn) => {
            C.Logger.errorE(cFILE, cFUN, `failed to translate key '${key}'`, exn);
            Js.Promise.resolve(());
          })
    )
    React.string(translatedKeyValue)
  }

}
