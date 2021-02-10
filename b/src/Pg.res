module Query = {
  type param
  type result<'a> = {
    rows: array<'a>
  }

  external string: string => param = "%identity" 
  external int: int => param = "%identity" 
  external float: float => param = "%identity" 
}

module Client = {
  type t
  @bs.send external query: (t, string, array<Query.param>, (option<Js.Exn.t>, Query.result<'a>) => unit) => unit = "query" 
}

module User = {
  type t = {
    name: string,
    email: string
  }
}

let testClient = (client) => {
  Client.query(client, "INSERT INTO users(name, email) VALUES($1, $2) RETURNING *", [Query.string("brianc"), Query.string("brian.m.carlson@gmail.com")], 
  (err, res: Query.result<User.t>) => {
    switch err {
    | Some(e) => Js.log(Js.Exn.stack(e))
    | None => Js.log(res.rows[0].name) 
    }
  })  
}

module Pool = {
  type t
  type done = () => unit
  type connectionOptions = {
    host: option<string>,
    port: option<int>,
    database: option<string>,
    user: option<string>,
    password: option<string>

  }

  @bs.new @bs.module("pg") external new: (~options: connectionOptions = ?, ()) => t = "Pool"
  @bs.send external on: (t, string, (Js.Exn.t) => unit) => unit = "on"
  @bs.send external connect: (t, (option<Js.Exn.t>, Client.t, done) => unit) => unit = "connect"

  @bs.send external query: (t, string, array<Query.param>, (option<Js.Exn.t>, Query.result<'a>) => unit) => unit = "query" 
}

