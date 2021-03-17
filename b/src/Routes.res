let router = Cb.Router.router()

let cFILE = "Routes.res"

let createUser = Cb.Router.post(router, "/api/create_user", (req, res) => {
  let cFUNC = "createUser()"

  let createNewUser = (user: C.Rest.Request.User.t): Js.Promise.t<Belt.Result.t<Js.Json.t, Js.Json.t>>  => {
    Cb.Pool.query("insert ino users(id, user_name, user_email, passowrd) values(?, ?, ?, ?)", [Cb.Pg.Query.string(Cb.Uuid.id()), Cb.Pg.Query.string(user.userName), Cb.Pg.Query.string(user.userEmail), Cb.Pg.Query.string(Cb.Crypto.sha256(user.userEmail))])  
    -> Js.Promise.then_((_) => {
      Js.Promise.resolve(Belt.Result.Ok(C.Rest.Reply.reply(~ok=true, ())))
    },_) 
    -> Js.Promise.catch((e) => {
      C.Logger.errorE(cFILE, cFUNC, "createNewUser() error", e)
      Js.Promise.reject(Cb.Exception.Error("createNewUser() error"))
    },_)
  } 

  module CountResult = {
    type t = {
      count: int,
    }
  }

  let verifyUserName = (user: C.Rest.Request.User.t): Js.Promise.t<Belt.Result.t<Js.Json.t, Js.Json.t>> => {

    Cb.Pool.query("select count(*) from users where user_name = ?", [Cb.Pg.Query.string(user.userName)])  
    -> Js.Promise.then_((result: Cb.Pg.Query.result<CountResult.t>) => {
      if result.rows[0].count > 0 {
        Cb.Translation.translateKey(~key="rest_create_user.user_already_exists", ())
        -> Js.Promise.then_(message => {
          Js.Promise.resolve(Belt.Result.Error(C.Rest.Reply.reply(~ok=false, ~err="user_already_exists", ~message=message, ())))
        }, _)
      } else {
        createNewUser(user)
      }
    },_) 
    -> Js.Promise.catch((e) => {
      C.Logger.errorE(cFILE, cFUNC, "verifyUserName() error", e)
      Js.Promise.reject(Cb.Exception.Error("verifyUserName() error"))
    },_)
  }


  let verifyEmail = (user: C.Rest.Request.User.t): Js.Promise.t<Belt.Result.t<Js.Json.t, Js.Json.t>> => {

    Cb.Pool.query("select count(*) from users where email = ?", [Cb.Pg.Query.string(user.userEmail)])  
    -> Js.Promise.then_((result: Cb.Pg.Query.result<CountResult.t>) => {
      if (result.rows[0].count > 0) {
        Cb.Translation.translateKey(~key="rest_create_user.email_already_exists", ())
         -> Js.Promise.then_((message) => {
          Js.Promise.resolve(Belt.Result.Error(C.Rest.Reply.reply(~ok=false, ~err="email_already_exists", ~message=message, ())))
        }, _)
          } else {
            verifyUserName(user)
          }
        },_) 
    -> Js.Promise.catch((e) => {
      C.Logger.errorE(cFILE, cFUNC, "verifyEmail() error", e)
      Js.Promise.reject(Cb.Exception.Error("verifyEmail() error"))
    },_)
  }

  switch Cb.Request.getJsonBody(req) {
  | Ok(body) => 
    switch C.Rest.Request.decodeUser(body) {
    | Some(user) =>
      verifyEmail(user) 
      -> Js.Promise.then_((result) => {
        switch result {
        | Belt.Result.Ok(reply) => Js.Promise.resolve(Cb.Response.sendJson(res, reply))
        | Belt.Result.Error(reply) => Js.Promise.resolve(Cb.Response.sendJson(res, reply))
        } 
      }, _)
      -> Js.Promise.catch((e) => {
        C.Logger.errorE(cFILE, cFUNC, "verifyEmail() error", e)
        Cb.Response.status(res, 500) 
        Js.Promise.resolve(Cb.Response.sendJson(res, C.Rest.Reply.reply(~ok=false, ~err="error", ())))
      },_)
    | None =>
        Cb.Response.status(res, 400) 
        Js.Promise.resolve(Cb.Response.sendJson(res, C.Rest.Reply.reply(~ok=false, ~err="could not json decode payload", ())))
    }
  | Error(reply) => 
      Cb.Response.status(res, 400) 
      Js.Promise.resolve(Cb.Response.sendJson(res, reply))
  }

})
