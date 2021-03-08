@react.component
let make = (~msgKey: string, ~bindings: option<Js.Dict.t<string>> = ?) => {

  let (isDisplayed, setIsDisplayed) = React.useState(() => false)
  let (msg, setMsg) = React.useState(() => "")

  
  let promise = Cf_translation.translateKey(~key=msgKey, ~bindings=?bindings, ())
  -> Js.Promise.then_((msg) => Js.Promise.resolve(setMsg(_ => msg)), _)
  ignore(promise)

  let show = () => {
    if (isDisplayed) {
      <article className="message is-danger">
        <div className="message-header">
           <button className="delete" ariaLabel="delete" onClick={_ => setIsDisplayed(_ => false)}></button>
        </div>
        <div className="message-body">
          {React.string(msg)}
        </div>
      </article>
    } else {
      React.string("")
    }
  }

  <div>
    {show()}
  </div>
}
