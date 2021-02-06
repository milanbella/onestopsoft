type t

@bs.get external session: Request.t => t = "session"


let get: (t, string) => Js.Json.t = %raw(`
  function (session, attribute) {
    return session[attribute];
  }
`)


let put: (t, string, Js.Json.t) => unit = %raw(`
  function (session, attribute, value) {
    session[attribute] = value;
  }
`)
