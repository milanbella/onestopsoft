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
  type t<'a> = {
    ok: bool,
    err: option<string>,
    message: option<string>,
    data: option<'a>
  }

  let toError = (reply: t<'a>): (string, string) => {
    let toString = (str: option<string>): string => {
      switch str {
      | Some(str) => str
      | None => ""
      }
    }

    if reply.ok {
      ("", "")
    } else {
      (toString(reply.err), toString(reply.message))
    }
  }

  let _encode = (d: t<'a>, dataEncoder: option<Json.Encode.encoder<'a>>): Js.Json.t => {
    open Json.Encode
    switch dataEncoder {
    | Some(de) => object_(list{
        ("ok", bool(d.ok)),
        ("err", nullable(string)(d.err)),
        ("message", nullable(string)(d.message)),
        ("data", nullable(de)(d.data)) 
      })
    | None => object_(list{
        ("ok", bool(d.ok)),
        ("err", nullable(string)(d.err)),
        ("message", nullable(string)(d.message)),
        ("data", Js.Json.null) 
      })
    }
  }

  exception Data_encoder_parameter_missing

  let encode = (~ok: bool, ~err: option<string> = ?, ~message: option<string> = ?, ~data: option<'a> = ?,  ~dataEncoder: option<Json.Encode.encoder<'a>> =?, ()): Js.Json.t => {
    switch data {
    | Some(_) => 
      switch dataEncoder {
      | Some(encoder) =>
        _encode({
          ok: ok,
          err: err,
          message: message,
          data: data
        }, Some(encoder))
      | None => 
        raise(Data_encoder_parameter_missing)
      }
    | None => 
        _encode({
          ok: ok,
          err: err,
          message: message,
          data: data
        }, None)

    }
  }

  let decodeReply = (j: Js.Json.t, dataDecoder: option<Json.Decode.decoder<'a>>): option<t<'a>> => {
    let cFUNC = "decodeReply()"
    try {
      open Json.Decode
      switch dataDecoder {
      | Some(de) => Some({
          ok: field("ok", bool, j),
          err: field("err", optional(string), j),
          message: field("message", optional(string), j),
          data: field("data", optional(de), j)
        })
      | None => Some({
          ok: field("ok", bool, j),
          err: field("err", optional(string), j),
          message: field("message", optional(string), j),
          data: None
        })
      }
    } catch {
    | Json.Decode.DecodeError(msg) =>
      C_logger.error(cFILE, cFUNC,`decode error: ${msg}`)
      None
    }
  }

  let decode = (~reply: string, ~dataDecoder: option<Json.Decode.decoder<'a>> = ?, () ): option<t<'a>> => {
    let cFUNC = "decode()"
    let json: option<Js.Json.t> = try {
      Some(Js.Json.parseExn(reply)) 
    } catch {
    | err =>
      C_logger.errorE(cFILE, cFUNC, "Js.Json.parseExn() failed", err)
      None
    }
    switch json {
    | Some(j) => decodeReply(j, dataDecoder)
    | None => None
    }
  }

}

