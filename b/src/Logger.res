let debug = (fileNme, funcName, message) => {
  Js.Console.log(`DEBUG: ${fileNmae}:${funcName}: ${message}`) 
}

let debugA = (fileNme, funcName, message, attrs: Js.Dict<string>) => {
  Js.Console.log1(`DEBUG: ${fileNmae}:${funcName}: ${message}`, attrs) 
}

let info = (fileNme, funcName, message) => {
  Js.Console.error(`INFO: ${fileNmae}:${funcName}: ${message}`); 
}

let infoA = (fileNme, funcName, message, attrs: Js.Dict<string>) => {
  Js.Console.error1(`INFO: ${fileNmae}:${funcName}: ${message}`, attrs); 
}

let warn = (fileNme, funcName, message) => {
  Js.Console.warn(`WARN: ${fileNmae}:${funcName}: ${message}`); 
}

let warnA = (fileNme, funcName, message, attrs: Js.Dict<string>) => {
  Js.Console.warn1(`WARN: ${fileNmae}:${funcName}: ${message}`, attrs); 
}

let error = (fileNme, funcName, message) => {
  Js.Console.error(`ERROR: ${fileNmae}:${funcName}: ${message}`); 
}

let errorA = (fileNme, funcName, message, attrs: Js.Dict<string>) => {
  Js.Console.error1(`ERROR: ${fileNmae}:${funcName}: ${message}`, attrs); 
}
