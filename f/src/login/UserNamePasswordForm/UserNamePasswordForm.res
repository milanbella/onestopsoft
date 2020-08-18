@react.component
let make = () =>
  <div className="content">
    <div className="box">
      <div className="field">
        <label className="label"> {React.string("User name or email")} </label>
        <div className="control"> <input type_="text" /> </div>
      </div>
      <div className="field">
        <label className="label"> {React.string("Password")} </label>
        <div className="control"> <input type_="password" /> </div>
      </div>
      <div className="field">
        <div className="control">
          <button className="button is-link"> {React.string("Submit")} </button>
        </div>
      </div>
    </div>
  </div>
