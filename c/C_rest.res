let cFILE = "C_rest.res"
module Request = {

  module User = {
    type t = {
      userName: string,
      userEmail: string,
      password: string,
    }
  }

  let encodeUser = (d: User.t): Js.Json.t => {
    open Json.Encode
    object_(list{
      ("userName", string(d.userName)),
      ("userEmail",string(d.userEmail)),
      ("password", string(d.password)),
    })
  }

  let decodeUser = (j: Js.Json.t): option<User.t> => {
    let cFUNC = "decodeUser()"
    try {
      open Json.Decode
      Some({
        userName: field("userName", string, j),
        userEmail: field("userEmail", string, j),
        password: field("password", string, j),
      })
    } catch {
    | Json.Decode.DecodeError(msg) =>
      C_logger.error(cFILE, cFUNC,`decode error: ${msg}`)
      None
    }
  }

}

module Reply = {
  type t = {
    ok: bool,
    err: option<string>,
    message: option<string>,
    data: option<string>
  }

  let _encode = (d: t): Js.Json.t => {
    open Json.Encode
    object_(list{
        ("ok", bool(d.ok)),
        ("err", nullable(string)(d.err)),
        ("message", nullable(string)(d.message)),
        ("data", nullable(string)(d.data)) 
      })
  }

  exception Data_encoder_parameter_missing

  let encode = (~ok: bool, ~err: option<string> = ?, ~message: option<string> = ?, ~data: option<string> = ?, ()): Js.Json.t => {
    _encode({
      ok: ok,
      err: err,
      message: message,
      data: data
    })
  }

  let decodeReply = (j: Js.Json.t): option<t> => {
    let cFUNC = "decodeReply()"
    try {
      open Json.Decode
      Some({
          ok: field("ok", bool, j),
          err: field("err", optional(string), j),
          message: field("message", optional(string), j),
          data: field("data", optional(string), j)
       })
    } catch {
    | Json.Decode.DecodeError(msg) =>
      C_logger.error(cFILE, cFUNC,`decode error: ${msg}`)
      None
    }
  }

  let decode = (~reply: string, ()): option<t> => {
    let cFUNC = "decode()"
    let json: option<Js.Json.t> = try {
      Some(Js.Json.parseExn(reply)) 
    } catch {
    | err =>
      C_logger.errorE(cFILE, cFUNC, "Js.Json.parseExn() failed", err)
      None
    }
    switch json {
    | Some(j) => decodeReply(j)
    | None => None
    }
  }

}

