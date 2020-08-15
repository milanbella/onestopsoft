let cFILE = "Translation.re"; 

exception FetchModuleFailed;
exception ModuleLoadingFailedExn;

let modulesRootPath = "locales";

type tModuleKeyValue = StringKeyValue(string) | DictionaryKeyValue(Js.Dict.t(tModuleKeyValue)); 

type tKey = {
  moduleName: option(string),
  path: list(string),
}

type tModule = {
  lang: string,
  moduleName: string,
  keys: Js.Dict.t(tModuleKeyValue),
}

type tModuleState = ModuleIsNotLoaded(tModule) | ModuleIsLoading(Js.Promise.t(tModule)) | ModuleIsLoaded(tModule) | ModuleLoadingFailed;

let moduleCash: Js.Dict.t(tModuleState) = Js.Dict.empty()

exception WrongJsonFormat;

let jsonDecodeModule = {

  let rec decodeModuleKeyValue  = (json) => {
    open Js.Json;
    switch(classify(json)) {
    | JSONString(s) => StringKeyValue(s)
    | JSONObject(_) => DictionaryKeyValue(json |> Json.Decode.dict(decodeModuleKeyValue)) 
    | _ => raise(WrongJsonFormat) 
    }
  }
  Json.Decode.dict(decodeModuleKeyValue);
}

let fetchModule = (lang, moduleName) => {
  let cFUN = "fetchModule()";

  Fetch.fetch("/" ++ modulesRootPath ++ "/" ++ lang ++ moduleName ++ ".json")
  |> Js.Promise.then_(Fetch.Response.text)
  |> Js.Promise.then_((text) => {
    text 
      |> Json.parseOrRaise
      |> jsonDecodeModule
      |> Js.Promise.resolve
    })
  |> Js.Promise.catch((err) => {
    Js.Console.error2({j|$cFILE:$cFUN: error while loading lang "$lang" _module "$moduleName"|j}, err);
    Js.Promise.reject(FetchModuleFailed);
  })
}

let rec getModuleFromCash = (lang, moduleName) => {
  let cFUN = "getModuleFromCash()";

  let fetch = () => {
    let promise = fetchModule(lang, moduleName)
    |> Js.Promise.then_((keys) => {
        let _module = {
          lang: lang,
          moduleName: moduleName,
          keys: keys,
        }
        moduleCash -> Js.Dict.set(lang ++ moduleName, ModuleIsLoaded(_module));
        Js.Promise.resolve(_module);
      })
    |> Js.Promise.catch((err) => {
      Js.Console.error2({j|$cFILE:$cFUN: error while loading lang "$lang" module "$moduleName"|j}, err);
      moduleCash -> Js.Dict.set(lang ++ moduleName, ModuleLoadingFailed);
      Js.Promise.reject(FetchModuleFailed);
    })
    moduleCash -> Js.Dict.set(lang ++ moduleName, ModuleIsLoading(promise));
    promise
  }

  switch (moduleCash -> Js.Dict.get(lang ++ moduleName)) {
  | Some(moduleState) => 
    switch (moduleState) {
    | ModuleIsNotLoaded(_) => fetch()
    | ModuleIsLoading(_module) => _module 
    | ModuleIsLoaded(_module) => Js.Promise.resolve(_module)
    | ModuleLoadingFailed => Js.Promise.reject(ModuleLoadingFailedExn)
    }
  | None => 
    let _module = {
      lang: lang,
      moduleName: moduleName,
      keys: Js.Dict.empty(),
    }
    moduleCash -> Js.Dict.set(lang ++ moduleName, ModuleIsNotLoaded(_module));
    getModuleFromCash(lang, moduleName);
  }
}



let parseKey = (key: string) => {
  open Js.String2;

  let rec parsePath = (keyStr, path) => {
    let idx = keyStr -> indexOf(".");
    if (idx > -1) {
      parsePath(keyStr -> sliceToEnd(~from=idx+1), [keyStr -> slice(~from=0, ~to_=idx), ...path]);
    } else {
      [keyStr, ...path] -> List.rev;
    }
  }

  let parseModuleNme = (keyStr) => {
    let idx = keyStr -> indexOf(":");
    if (idx > -1) {
      (Some(keyStr -> slice(~from=0, ~to_=idx)), keyStr -> sliceToEnd(~from=idx+1));
    } else {
      (None, keyStr);
    }
  }

  let (moduleName, keyStr) = parseModuleNme(key) 
  let path = parsePath(keyStr, []);

  {
    moduleName: moduleName,
    path: path,
  }

}
