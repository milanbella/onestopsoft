let cFILE = "Translation.re"

exception ModuleLoadingFailedExn
exception KeyValueParseInternalErrorExn

let modulesRootPath = "locales"
let currentLanguage = ref("en")
let defaultModuleName = "translation"
let defaultKeyValue = "?notFound?"

type rec tModuleKeyValue = StringKeyValue(string) | DictionaryKeyValue(Js.Dict.t<tModuleKeyValue>)

type tKey = {
  moduleName: option<string>,
  path: list<string>,
}

type tModule = {
  lang: string,
  moduleName: string,
  keys: Js.Dict.t<tModuleKeyValue>,
}

type tModuleState =
  | ModuleIsNotLoaded(tModule)
  | ModuleIsLoading(Js.Promise.t<tModule>)
  | ModuleIsLoaded(tModule)
  | ModuleLoadingFailed

let moduleCash: Js.Dict.t<tModuleState> = Js.Dict.empty()

exception WrongJsonFormat

let jsonDecodeModule = {
  let rec decodeModuleKeyValue = json => {
    open Js.Json
    switch classify(json) {
    | JSONString(s) => StringKeyValue(s)
    | JSONObject(_) => DictionaryKeyValue(json |> Json.Decode.dict(decodeModuleKeyValue))
    | _ => raise(WrongJsonFormat)
    }
  }
  Json.Decode.dict(decodeModuleKeyValue)
}

let fetchModule = (lang, moduleName) => {
  let cFUN = "fetchModule()"

  Fetch.fetch("/" ++ (modulesRootPath ++ ("/" ++ (lang ++ (moduleName ++ ".json")))))
  |> Js.Promise.then_(Fetch.Response.text)
  |> Js.Promise.then_(text => text |> Json.parseOrRaise |> jsonDecodeModule |> Js.Promise.resolve)
  |> Js.Promise.catch(err => {
    Js.Console.error2(j`$cFILE:$cFUN: error while loading lang "$lang" _module "$moduleName"`, err)
    Js.Promise.reject(ModuleLoadingFailedExn)
  })
}

let getModuleFromCash = (lang, moduleName) => {
  let cFUN = "getModuleFromCash()"

  let fetch = () => {
    let promise = fetchModule(lang, moduleName) |> Js.Promise.then_(keys => {
      let _module = {
        lang: lang,
        moduleName: moduleName,
        keys: keys,
      }
      moduleCash->Js.Dict.set(lang ++ moduleName, ModuleIsLoaded(_module))
      Js.Promise.resolve(_module)
    }) |> Js.Promise.catch(err => {
      Js.Console.error2(j`$cFILE:$cFUN: error while loading lang "$lang" module "$moduleName"`, err)
      moduleCash->Js.Dict.set(lang ++ moduleName, ModuleLoadingFailed)
      Js.Promise.reject(ModuleLoadingFailedExn)
    })
    moduleCash->Js.Dict.set(lang ++ moduleName, ModuleIsLoading(promise))
    promise
  }

  switch moduleCash->Js.Dict.get(lang ++ moduleName) {
  | Some(moduleState) =>
    switch moduleState {
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
    moduleCash->Js.Dict.set(lang ++ moduleName, ModuleIsNotLoaded(_module))
    fetch()
  }
}

let parseKey = (key: string) => {
  open Js.String2

  let rec parsePath = (keyStr, path) => {
    let idx = keyStr->indexOf(".")
    if idx > -1 {
      parsePath(keyStr->sliceToEnd(~from=idx + 1), list{keyStr->slice(~from=0, ~to_=idx), ...path})
    } else {
      list{keyStr, ...path}->List.rev
    }
  }

  let parseModuleNme = keyStr => {
    let idx = keyStr->indexOf(":")
    if idx > -1 {
      (Some(keyStr->slice(~from=0, ~to_=idx)), keyStr->sliceToEnd(~from=idx + 1))
    } else {
      (None, keyStr)
    }
  }

  let (moduleName, keyStr) = parseModuleNme(key)
  let path = parsePath(keyStr, list{})->List.rev

  {
    moduleName: moduleName,
    path: path,
  }
}

type tStringMatch = {
  match: Js.Null.t<array<string>>,
  index: int,
}

let stringMatch: (string, Js.Re.t) => tStringMatch = %raw(`
  function (str, regex) {
    let m = str.match(regex);
    if (m === null) {
      return {
        match: null,
        index: -1,
      }
    } else {
      return {
        match: m,
        index: m.index,
      }
    }
  }
`)

let translateKey = (key: string) => {
  let cFUN = "translateKey()";
  let parsedKey = parseKey(key);
  let moduleName = switch(parsedKey.moduleName) {
  | Some(v) => if v -> Js.String2.trim == "" { defaultModuleName } else { v }
  | None => defaultModuleName
  }

  let rec resolveKey = (_keys, path) => {
    if (path -> List.length == 0) {
      None;
    } else {
      let pathItem = path -> Belt.List.head;
      let pathRest = path -> Belt.List.tail;
      let keys = _keys -> Js.Dict.keys;
      let values = _keys -> Js.Dict.values;

      let rec scanKeys = (keys, values, pathItem, pathRest, idx) => {
        switch (pathItem) {
        | None => None
        | Some(pathItem) =>
          let i = idx + 1;
          if (i + 1 > keys -> Array.length) {
            None;
          } else {
            let k = keys[i];
            if (k == pathItem) {
              let v = values[i];
              switch(v) {
              | StringKeyValue(s) =>
                switch(pathRest) {
                | Some(_) => None
                | None =>  Some(s)
                }
              | DictionaryKeyValue(d) =>
                let _keys = d;
                switch(pathRest) {
                | Some(path) => 
                    let res = resolveKey(_keys, path);
                    switch(res) {
                    | Some(s) => Some(s)
                    | None => scanKeys(keys, values, Some(pathItem), pathRest, i)
                    }
                | None => scanKeys(keys, values, Some(pathItem), pathRest, i)
                }
              }
            } else {
              scanKeys(keys, values, Some(pathItem), pathRest, i)
            }
          }
        }
      }

       scanKeys(keys, values, pathItem, pathRest, -1);
    }
  }

  getModuleFromCash(currentLanguage.contents, moduleName)
  |> Js.Promise.then_((_module) => {
      let resolvedKeyValue = resolveKey(_module.keys, parsedKey.path);
      switch(resolvedKeyValue) {
      | Some(v) => Js.Promise.resolve(v); 
      | None => Js.Promise.resolve(defaultKeyValue);
      }
    })
  |> Js.Promise.catch((exn) => {
      Js.Console.error2(j`${cFILE}:${cFUN} getModuleFromCash() failed`, exn);
      Js.Console.error(j`${cFILE}:${cFUN} key not found: ${key}`);
      Js.Promise.resolve(defaultKeyValue);
    })
}

/*
let interpolateKeyValue = (keyValue, bindings ) = {
  let break = ref(false);

  type vmatch = {
    name: string,
    startIdx: int,
    endIdx: int,
  }

  let doit = (keyValue, bindings, resultStr) => {
    let idx = keyValue -> Js.String2.search([%re "/\\${\\w+}"]);
    if (idx > -1) {
      let s1 = keyValue -> Js.String2.slice(0, idx);
      let m = keyValue -> Js.String2.match([%re "/\\w+"]);
      if (m -> Js.Array.length < 1) {
        exception KeyValueParseInternalErrorExn;
      } else {
        let s2 = m[0];
        let s3 = 
      }
      let s2
    }
  }


  let matches = List(vmatch);


  while (!break^) {
    if (m -> Js.Array.length > 1) {
      [


  }
}
*/
