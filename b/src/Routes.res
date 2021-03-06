let router = Cb.Router.router()

let cFILE = "Routes.res"


let createUser = Cb.Router.post(router, "/api/create_user", (req, res) => {
  let cFUNC = "createUser()"

  let createNewUser = (user: User.t): Js.Promise.t<Belt.Result.t<Js.Json.t, Js.Json.t>>  => {
    Cb.Pool.query("insert ino users(id, user_name, user_email, passowrd) values(?, ?, ?, ?)", [Cb.Pg.Query.string(Cb.Uuid.id()), Cb.Pg.Query.string(user.userName), Cb.Pg.Query.string(user.userEmail), Cb.Pg.Query.string(Cb.Crypto.sha256(user.userEmail))])  
    -> Js.Promise.then_((_) => {
      Belt.Result.Ok(C.Rest.Reply.reply(~ok=true, ()))
    },_) 
    -> Js.Promise.catch((e) => {
      Cb.Logger.errorE(cFILE, cFUNC, "createNewUser() error", e)
      Js.Promise.reject(e)
    },_)
  } 

  module CountResult = {
    type t = {
      count: int,
    }
  }

  let verifyUserName = (user: User.t): Js.Promise.t<Belt.Result.t<Js.Json.t, Js.Json.t>> => {

    Cb.Pool.query("select count(*) from users where user_name = ?", [Cb.Pg.Query.string(user.userName)])  
    -> Js.Promise.then_((result: Cb.Pg.Query.result<CountResult.t>) => {
      if result.rows[0].count > 0 {
        Js.Promise.resolve(Belt.Result.Error(C.Rest.Reply.reply(~ok=false, ~err="user_already_exists", ~message=Cb.Translation.translateKey("rest_create_user.user_already_exists", ()), ())))
      } else {
        createNewUser(user)
      }
    },_) 
    -> Js.Promise.catch((e) => {
      Cb.Logger.errorE(cFILE, cFUNC, "verifyUserName() error", e)
      Js.Promise.reject(e)
    },_)
  }


  let verifyEmail = (user: User.t): Js.Promise.t<Belt.Result.t<Js.Json.t, Js.Json.t>> => {

    Cb.Pool.query("select count(*) from users where email = ?", [Cb.Pg.Query.string(user.userEmail)])  
    -> Js.Promise.then_((result: Cb.Pg.Query.result<CountResult.t>) => {
      if (result.rows[0].count > 0) {
        Js.Promise.resolve(Belt.Result.Error(C.Rest.Reply.reply(~ok=false, ~err="email_already_exists", ~message=Cb.Translation.translateKey("rest_create_user.email_already_exists"), ())))
      } else {
        verifyUserName(user)
      }
    },_) 
    -> Js.Promise.catch((e) => {
      Cb.Logger.errorE(cFILE, cFUNC, "verifyEmail() error", e)
      Js.Promise.reject(e)
    },_)
  }

  switch Cb.Request.getJsonBody(req) {
  | Ok(body) => 
    switch C.Rest.Request.decodeUser(body) {
    | Some(user) =>
      verifyEmail(user) 
      -> Js.Promise.then_((result) => {
        switch result {
        | Belt.Result.Ok(reply) => Cb.Response.sendJson(res, reply) 
        | Belt.Result.Error(reply) => Cb.response.sendJson(res, reply)
        } 
      }, _)
      -> Js.Promise.catch((e) => {
        Cb.Response.status(res, 500) 
        Cb.Response.sendJson(res, C.Rest.Reply.reply(~ok=false, ~err="error", ()))
      },_)
    | None =>
        Cb.Response.status(res, 400) 
        Cb.Response.sendJson(res, C.Rest.Reply.reply(~ok=false, ~err="could not json decode payload", ()))
    }
  | Error(reply) => 
      Cb.Response.status(res, 400) 
      Cb.Response.sendJson(res, reply)
  }

})
