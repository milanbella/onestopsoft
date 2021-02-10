type t 
type handler = (Request.t, Response.t) => unit

@bs.module("express") external router: () => t = "Router" 

@bs.send external get: (t, string, handler) => unit = "get" 
@bs.send external post: (t, string, handler) => unit = "get" 

