type t 
type handler = (Cb_request.t, Cb_response.t) => unit

@bs.module("express") external router: () => t = "Router" 

@bs.send external get: (t, string, handler) => unit = "get" 
@bs.send external post: (t, string, handler) => unit = "get" 

