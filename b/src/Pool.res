let cFILE = "Pool.res"

exception QueryError

let pool = Pg.Pool.new()

Pg.Pool.on(pool, "error", (err) => {
  let cFUN = "Pg.Pool.on()"
  Logger.errorE(cFILE, cFUN, "error", err)
})

let query = (queryStr: string, params: array<Pg.Query.param>): Js.Promise.t<Pg.Query.result<'a>> => {
  let cFUNC = "query()"
  Js.Promise.make((~resolve, ~reject) => {
    Pg.Pool.query(pool, queryStr, params, (err, result) => {
      switch err {
      | Some(e) => 
        Logger.errorE(cFILE, cFUNC, `error, query: ${queryStr}`, err)
        reject(. QueryError)
      | None => resolve(. result) 
      }
    })
  })
} 

//@bs.send external connect: (t, (option<Js.Exn.t>, Client.t, done) => unit) => unit = "connect"

let connect = (cb: (option<Js.Exn.t>, Pg.Client.t, Pg.Pool.done) => unit): unit =>  {
  Pg.Pool.connect(pool, cb)
}

