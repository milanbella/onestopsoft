let componentName = "UserNamePasswordForm"

@react.component
let make = () => {
  let t = Translation.useTranslate()

  <div className="content">
    <div className="box">
      <div className="field">
        <label className="label"> {t(~key=`${componentName}.User name or email`, ())}{React.string(":")} </label>
        <div className="control"> <input type_="text" /> </div>
      </div>
      <div className="field">
        <label className="label"> {t(~key=`${componentName}.Password`, ())} </label>
        <div className="control"> <input type_="password" /> </div>
      </div>
      <div className="field">
        <div className="control">
          <button className="button is-link"> {t(~key=`${componentName}.Submit`, ())} </button>
        </div>
      </div>
    </div>
  </div>
}
