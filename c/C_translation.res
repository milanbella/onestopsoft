// This is useTranslation() hook isnspired by https://react.i18next.com/latest/usetranslation-hook which did not behave well with reason-react

let cFILE = "C_translation.re"

exception ModuleLoadingFailedExn
exception KeyValueParseInternalErrorExn
exception AsserionFailedExn
exception WrongJsonFormat

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

type tStringMatch = {
  match: Js.Null.t<array<string>>,
  index: int,
}

type tFetchModule = (string, string) => Js.Promise.t<string>

let makeTranslation = (fetchModuleFn: tFetchModule) => {
  let moduleCash: Js.Dict.t<tModuleState> = Js.Dict.empty()

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

    fetchModuleFn(lang, moduleName)
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

    let result = {
      moduleName: moduleName,
      path: Belt.List.reverse(path),
    }

    result
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

  let interpolateKeyValue = (keyValue, ~bindings=?, ()) => {
    let rgx = Js.Re.fromString("\\${(\\w+)}");

    let rec doit = (restStr, bindings, result) => {
      let m = restStr -> stringMatch(rgx);
      switch (m.match -> Js.Null.toOption) {
      | Some(groups) =>
        let s1 = restStr -> Js.String2.slice(~from=0, ~to_=m.index);
        switch(bindings) {
        | Some(_bindings) =>
          switch(_bindings -> Js.Dict.get(groups[1])) {
          | Some(s) => 
            let s2 = s;
            let s3 = restStr -> Js.String2.sliceToEnd(~from=(m.index + groups[0] -> Js.String2.length))
            doit(s3, Some(_bindings), result ++ s1 ++ s2)
          | None =>
            let s2 = groups[0];
            let s3 = restStr -> Js.String2.sliceToEnd(~from=(m.index + groups[0] -> Js.String2.length))
            doit(s3, Some(_bindings), result ++ s1 ++ s2)
          }
        | None =>
            let s2 = groups[0];
            let s3 = restStr -> Js.String2.sliceToEnd(~from=(m.index + groups[0] -> Js.String2.length))
            doit(s3, None, result ++ s1 ++ s2)
         }
      | None =>
        result ++ restStr;
      }
    }
    doit(keyValue, bindings, "")
  }


  let translateKey = (~key: string, ~bindings=?, ()) => {
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

        let rec scanKeys = (keys, values, idx, pathItem, pathRest) => {
          switch (pathItem) {
          | None => None
          | Some(pathItem) =>
            if (idx + 1 > keys -> Array.length) {
              None;
            } else {
              let k = keys[idx];
              if (k == pathItem) {
                let v = values[idx];
                switch(v) {
                | StringKeyValue(s) => 
                  switch (pathRest) {
                  | Some(path) =>
                    if (path -> Belt.List.length == 0) {
                      Some(s);
                    } else {
                      None;
                    }
                  | None => raise(AsserionFailedExn)
                  }
                | DictionaryKeyValue(d) =>
                  let _keys = d;
                  switch(pathRest) {
                  | Some(path) => 
                    let res = resolveKey(_keys, path);
                    switch(res) {
                    | Some(s) => Some(s)
                    | None => scanKeys(keys, values, idx+1,   Some(pathItem), pathRest)
                    }
                  | None => raise(AsserionFailedExn);
                  }
                }
              } else {
                scanKeys(keys, values, idx+1, Some(pathItem), pathRest)
              }
            }
          }
        }

         scanKeys(keys, values, 0, pathItem, pathRest);
      }
    }

    getModuleFromCash(currentLanguage.contents, moduleName)
    |> Js.Promise.then_((_module) => {
        let resolvedKeyValue = resolveKey(_module.keys, parsedKey.path);
        switch(resolvedKeyValue) {
        | Some(v) => 
          switch(bindings) {
          | Some(_b) => interpolateKeyValue(v, ~bindings=_b, ()) -> Js.Promise.resolve; 
          | None => interpolateKeyValue(v, ()) -> Js.Promise.resolve;
          }
        | None => Js.Promise.resolve(defaultKeyValue);
        }
      })
    |> Js.Promise.catch((exn) => {
        Js.Console.error2(j`${cFILE}:${cFUN} getModuleFromCash() failed`, exn);
        Js.Console.error(j`${cFILE}:${cFUN} key not found: ${key}`);
        Js.Promise.resolve(defaultKeyValue);
      })
  }

  translateKey
}
