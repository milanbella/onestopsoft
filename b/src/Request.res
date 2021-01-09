type t

let cFILE = "Request.res"

@bs.get external body: t => string = "body"

let getJsonBody = (req, res): Js.Json.t => {
  let cFUN = "getJsonBody()"
  let s = body(req)
  try Js.Json.parseExn(s) catch {
  | _ => 
	  Logger.error(cFILE, cFUN, "jsom parse syntax error, cannot parse request body")
	  Response.status(res, 400)
	  Response.end(res)
	  raise(Exception.BAD_REQUEST)
  }
}
