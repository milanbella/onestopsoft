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

