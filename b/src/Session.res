type t

type cookieOptions = {
  maxAge: option<int>,
  secure: option<bool>,
  sameSite: option<bool>,
}

@bs.get external cookies: Request.t => Js.Json.t = "cookies"
@bs.send external cookie: (Response.t, string,  string, cookieOptions) => unit = "cookie"
