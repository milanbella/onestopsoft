let debug = (fileName, funcName, message) => {
  Js.Console.log(`DEBUG: ${fileName}:${funcName}: ${message}`) 
}

let debugA = (fileName, funcName, message, attrs: Js.Dict.t<string>) => {
  Js.Console.log2(`DEBUG: ${fileName}:${funcName}: ${message}`, attrs) 
}

let info = (fileName, funcName, message) => {
  Js.Console.error(`INFO: ${fileName}:${funcName}: ${message}`); 
}

let infoA = (fileName, funcName, message, attrs: Js.Dict.t<string>) => {
  Js.Console.error2(`INFO: ${fileName}:${funcName}: ${message}`, attrs); 
}

let warn = (fileName, funcName, message) => {
  Js.Console.warn(`WARN: ${fileName}:${funcName}: ${message}`); 
}

let warnA = (fileName, funcName, message, attrs: Js.Dict.t<string>) => {
  Js.Console.warn2(`WARN: ${fileName}:${funcName}: ${message}`, attrs); 
}

let error = (fileName, funcName, message) => {
  Js.Console.error(`ERROR: ${fileName}:${funcName}: ${message}`); 
}

let errorA = (fileName, funcName, message, attrs: Js.Dict.t<string>) => {
  Js.Console.error2(`ERROR: ${fileName}:${funcName}: ${message}`, attrs); 
}
