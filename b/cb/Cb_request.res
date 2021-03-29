type t

let cFILE = "Cb_request.res"

//@bs.get external body: t => string = "body"
@bs.get external body: t => Js.Json.t = "body"

let getJsonBody = (req): Belt.Result.t<Js.Json.t, Js.Json.t> => {
  //let cFUN = "getJsonBody()"
  Belt.Result.Ok(body(req))
  /*
  let s = body(req)
  try {
    Belt.Result.Ok(Js.Json.parseExn(s))
  } catch {
  | e =>
    C_logger.errorE(cFILE, cFUN, "error parsing json request body", e) 
    Belt.Result.Error(C.Rest.Reply.encode(~ok=false, ~err="could not parse request json  body", ()))
  }
  */
}

