type t

let cFILE = "Request.res"

@bs.get external body: t => string = "body"

let getJsonBody = (req): Js.Json.t => {
  let cFUN = "getJsonBody()"
  let s = body(req)
  let j = try Js.Json.parseExn(s) catch {
  | - => Logger.error(cFILE, cFUN, "jsom parse syntax error, cannot parse request body")
  }
}
