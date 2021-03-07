@react.component
let make = (~msg: string) => {

  let (isDisplayed, setIsDisplayed) = React.useState(() => true)

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
