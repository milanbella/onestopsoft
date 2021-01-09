type t

@bs.send external status: (t, int) => unit = "status"
@bs.send external end: (t) => unit = "end"
