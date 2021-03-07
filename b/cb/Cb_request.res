type t

let cFILE = "Request.res"

@bs.get external body: t => string = "body"

let getJsonBody = (req): Belt.Result.t<Js.Json.t, Js.Json.t> => {
  let cFUN = "getJsonBody()"
  let s = body(req)
  try {
    Belt.Result.Ok(Js.Json.parseExn(s))
  } catch {
  | e =>
    Cb_logger.errorE(cFILE, cFUN, "error parsing json request body", e) 
    Belt.Result.Error(C.Rest.Reply.reply(~ok=false, ~err="could not parse request json  body", ()))
  }
}

