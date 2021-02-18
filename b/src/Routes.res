let router = Router.router()

let cFILE = "Routes.res"

let createUser = Router.post(router, "/api/create_user", (req, res) => {
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
      Logger.errorE(cFILE, cFUNC, "could not decode user", e)
      None
    }
  }

  let createNewUser = (user: User.t): Js.Promise.t<unit> => {
    Pool.query("insert ino users(id, user_name, user_email, passowrd) values(?, ?, ?, ?)", [Pg.Query.string(Uuid.id()), Pg.Query.string(user.userName), Pg.Query.string(user.userEmail), Pg.Query.string(Crypto.sha256(user.userEmail))])  
    -> Js.Promise.then_((_) => {
      Response.status(res, 200) 
      Response.sendObject(res, Js.Obj.empty()) 
      Js.Promise.resolve(())
    },_) 
    -> Js.Promise.catch((e) => {
      Logger.errorE(cFILE, cFUNC, "createNewUser() error", e)
      Response.status(res, 500) 
      Response.end(res) 
      Js.Promise.resolve(())
    },_)
  } 

  module CountResult = {
    type t = {
      count: int,
    }
  }

  let verifyUserName = (user: User.t): Js.Promise.t<unit> => {

    Pool.query("select count(*) from users where user_name = ?", [Pg.Query.string(user.userName)])  
    -> Js.Promise.then_((result: Pg.Query.result<CountResult.t>) => {
      if (result.rows[0].count > 0) {
        Js.Promise.resolve(Promise.Continue(()))
      } else {
        Js.Promise.resolve(Promise.Error(()))
      }
    },_) 
    -> Js.Promise.then_((cont) => {
      switch cont {
      | Promise.Error(_) => Js.Promise.resolve(())
      | Promise.Continue(_) => createNewUser(user)->Js.Promise.then_(() => Js.Promise.resolve(()), _)
      }
    },_)
    -> Js.Promise.catch((e) => {
      Logger.errorE(cFILE, cFUNC, "verifyUserName() error", e)
      Response.status(res, 500) 
      Response.sendText(res, "error")
      Js.Promise.resolve(())
    },_)
  }


  let verifyEmail = (user: User.t): Js.Promise.t<unit> => {

    Pool.query("select count(*) from users where email = ?", [Pg.Query.string(user.userEmail)])  
    -> Js.Promise.then_((result: Pg.Query.result<CountResult.t>) => {
      if (result.rows[0].count > 0) {
        Js.Promise.resolve(Promise.Continue(()))
      } else {
        Js.Promise.resolve(Promise.Error(()))
      }
    },_) 
    -> Js.Promise.then_((cont) => {
      switch cont {
      | Promise.Error(_) => Js.Promise.resolve(())
      | Promise.Continue(_) => verifyUserName(user) -> Js.Promise.then_(() => Js.Promise.resolve(()),_)
      }
    },_)
    -> Js.Promise.catch((e) => {
      Logger.errorE(cFILE, cFUNC, "verifyEmail() error", e)
      Response.status(res, 500) 
      Response.sendText(res, "error")
      Js.Promise.resolve(())
    },_)
  }

  switch Request.getJsonBody(req) {
  | Some(body) => 
    switch decodeUser(body) {
    | Some(user) => ignore(verifyEmail(user)) 
    | None => 
      Response.status(res, 400) 
      Response.sendText(res, "could not decode user")
    }
  | None => 
      Response.status(res, 400) 
      Response.sendText(res, "could not parse request body")
  }


})
