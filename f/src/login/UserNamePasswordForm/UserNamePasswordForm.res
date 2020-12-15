@react.component
let make = () => {
  let t = Translation.useTranslate()

  <div className="content">
    <div className="box">
      <div className="field">
        <label className="label"> {t(~key="scope1.scope3.scope4.User name or email2", ~bindings=Js.Dict.fromArray([("var1", "foo1"), ("var2", "foo2")]), ())} </label>
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
}
