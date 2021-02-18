type t

let cFILE = "Request.res"

@bs.get external body: t => string = "body"

let getJsonBody = (req): option<Js.Json.t> => {
  let cFUN = "getJsonBody()"
  let s = body(req)
  try {
    Some(Js.Json.parseExn(s))
  } catch {
  | e =>
    Logger.errorE(cFILE, cFUN, "error parsing json request body", e) 
    None
  }
}

