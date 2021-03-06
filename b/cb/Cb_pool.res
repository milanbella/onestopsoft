let cFILE = "Pool.res"

exception QueryError

let pool = Cb_pg.Pool.new()

Cb_pg.Pool.on(pool, "error", (err) => {
  let cFUN = "Pg.Pool.on()"
  Cb_logger.errorE(cFILE, cFUN, "error", err)
})

let query = (queryStr: string, params: array<Cb_pg.Query.param>): Js.Promise.t<Cb_pg.Query.result<'a>> => {
  let cFUNC = "query()"
  Js.Promise.make((~resolve, ~reject) => {
    Cb_pg.Pool.query(pool, queryStr, params, (err, result) => {
      switch err {
      | Some(e) => 
        Cb_logger.errorE(cFILE, cFUNC, `error, query: ${queryStr}`, e)
        reject(. QueryError)
      | None => resolve(. result) 
      }
    })
  })
} 

//@bs.send external connect: (t, (option<Js.Exn.t>, Client.t, done) => unit) => unit = "connect"

let connect = (cb: (option<Js.Exn.t>, Cb_pg.Client.t, Cb_pg.Pool.done) => unit): unit =>  {
  Cb_pg.Pool.connect(pool, cb)
}

