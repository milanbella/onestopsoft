module Fs = {
  @bs.module("fs") external readFileSync: (string, string) => string = "readFileSync"
}
