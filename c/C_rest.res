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
      Js.Console.error(`${cFILE}:${cFUNC} decode error: ${msg}`)
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



  let encodeReply = (d: t<'a>, dataEncoder: Json.Encode.encoder<'a>): Js.Json.t => {
    open Json.Encode
    object_(list{
      ("ok", bool(d.ok)),
      ("err", nullable(string)(d.err)),
      ("message", nullable(string)(d.message)),
      ("data", nullable(dataEncoder)(d.data)) 
    })
  }

  let decodeReply = (j: Js.Json.t, dataDecoder: Json.Decode.decoder<'a>): option<t<'a>> => {
    let cFUNC = "decodeReply()"
    try {
      open Json.Decode
      Some({
        ok: field("ok", bool, j),
        err: field("err", optional(string), j),
        message: field("message", optional(string), j),
        data: field("data", optional(dataDecoder), j)
      })
    } catch {
    | Json.Decode.DecodeError(msg) =>
      Js.Console.error(`${cFILE}:${cFUNC} decode error: ${msg}`)
      None
    }
  }

  exception Data_encoder_parameter_missing

  let reply = (~ok: bool, ~err: option<string> = ?, ~message: option<string> = ?, ~data: option<'a> = ?,  ~dataEncoder: option<Json.Encode.encoder<'a>> =?, ()): Js.Json.t => {
    switch data {
    | Some(_) => 
      switch dataEncoder {
      | Some(encoder) =>
        encodeReply({
          ok: ok,
          err: err,
          message: message,
          data: data
        }, encoder)
      | None => 
        raise(Data_encoder_parameter_missing)
      }
    | None => 
        encodeReply({
          ok: ok,
          err: err,
          message: message,
          data: data
        }, () => Js.Json.null)

    }
  }
}

