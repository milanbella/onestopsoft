let router = Cb.Router.router()

let cFILE = "Routes.res"

let createUser = Cb.Router.post(router, "/api/create_user", (req, res) => {
  let cFUNC = "createUser()"

  module User = {
    type t = {
      userName: string,
      userEmail: string,
      password: string,
    }
  }

  let decodeUser = (json): option<User.t> => {
    try {
      open Json.Decode
      let user: User.t = {
        userName: json |> field("user_name", string), 
        userEmail: json |> field("user_email", string), 
        password: json |> field("password", string), 
      }
      Some(user)
    } catch {
    | e => 
      Cb.Logger.errorE(cFILE, cFUNC, "could not decode user", e)
      None
    }
  }

  let createNewUser = (user: User.t): Js.Promise.t<unit> => {
    Cb.Pool.query("insert ino users(id, user_name, user_email, passowrd) values(?, ?, ?, ?)", [Cb.Pg.Query.string(Cb.Uuid.id()), Cb.Pg.Query.string(user.userName), Cb.Pg.Query.string(user.userEmail), Cb.Pg.Query.string(Cb.Crypto.sha256(user.userEmail))])  
    -> Js.Promise.then_((_) => {
      Cb.Response.status(res, 200) 
      Cb.Response.sendObject(res, Js.Obj.empty()) 
      Js.Promise.resolve(())
    },_) 
    -> Js.Promise.catch((e) => {
      Cb.Logger.errorE(cFILE, cFUNC, "createNewUser() error", e)
      Cb.Response.status(res, 500) 
      Cb.Response.end(res) 
      Js.Promise.resolve(())
    },_)
  } 

  module CountResult = {
    type t = {
      count: int,
    }
  }

  let verifyUserName = (user: User.t): Js.Promise.t<unit> => {

    Cb.Pool.query("select count(*) from users where user_name = ?", [Cb.Pg.Query.string(user.userName)])  
    -> Js.Promise.then_((result: Cb.Pg.Query.result<CountResult.t>) => {
      if (result.rows[0].count > 0) {
        Js.Promise.resolve(Cb.Promise.Continue(()))
      } else {
        Js.Promise.resolve(Cb.Promise.Error(()))
      }
    },_) 
    -> Js.Promise.then_((cont) => {
      switch cont {
      | Cb.Promise.Error(_) => Js.Promise.resolve(())
      | Cb.Promise.Continue(_) => createNewUser(user)->Js.Promise.then_(() => Js.Promise.resolve(()), _)
      }
    },_)
    -> Js.Promise.catch((e) => {
      Cb.Logger.errorE(cFILE, cFUNC, "verifyUserName() error", e)
      Cb.Response.status(res, 500) 
      Cb.Response.sendText(res, "error")
      Js.Promise.resolve(())
    },_)
  }


  let verifyEmail = (user: User.t): Js.Promise.t<unit> => {

    Cb.Pool.query("select count(*) from users where email = ?", [Cb.Pg.Query.string(user.userEmail)])  
    -> Js.Promise.then_((result: Cb.Pg.Query.result<CountResult.t>) => {
      if (result.rows[0].count > 0) {
        Js.Promise.resolve(Cb.Promise.Continue(()))
      } else {
        Js.Promise.resolve(Cb.Promise.Error(()))
      }
    },_) 
    -> Js.Promise.then_((cont) => {
      switch cont {
      | Cb.Promise.Error(_) => Js.Promise.resolve(())
      | Cb.Promise.Continue(_) => verifyUserName(user) -> Js.Promise.then_(() => Js.Promise.resolve(()),_)
      }
    },_)
    -> Js.Promise.catch((e) => {
      Cb.Logger.errorE(cFILE, cFUNC, "verifyEmail() error", e)
      Cb.Response.status(res, 500) 
      Cb.Response.sendText(res, "error")
      Js.Promise.resolve(())
    },_)
  }

  switch Cb.Request.getJsonBody(req) {
  | Some(body) => 
    switch decodeUser(body) {
    | Some(user) => ignore(verifyEmail(user)) 
    | None => 
      Cb.Response.status(res, 400) 
      Cb.Response.sendText(res, "could not decode user")
    }
  | None => 
      Cb.Response.status(res, 400) 
      Cb.Response.sendText(res, "could not parse request body")
  }


})
