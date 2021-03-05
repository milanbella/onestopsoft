type t

type cookieOptions = {
  maxAge: option<int>,
  secure: option<bool>,
  sameSite: option<bool>,
}

@bs.get external cookies: Cb_request.t => Js.Json.t = "cookies"
@bs.send external cookie: (Cb_response.t, string,  string, cookieOptions) => unit = "cookie"
