let router = Router.router()

let createUser = Router.post(router, "create_user", (req, res) => {

  module User = {
    type t = {
      userName: string,
      userEmail: string,
      password: string,
    }
  }

  let parseBody = (json) => {
    open Json.Decode
    let user: User.t = {
      userName: json |> field("user_name", string), 
      userEmail: json |> field("user_email", string), 
      password: json |> field("password", string), 
    }
  }

  let body = Request.getJsonBody(req, res)

  let user = parseBody(body)

})
