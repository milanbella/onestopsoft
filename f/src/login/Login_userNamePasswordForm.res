let componentName = "Login_userNamePasswordForm"

module User = {
  type t = {
    userName: string,
    userEmail: string,
    password: string,
  }
}

let registerUser = (user: User.t): Js.Promise.t<Belt.Result.t<unit, string>> => {
  let encodeUser = () => {
    open Json.Encode
    object_(list{
      ("user_name", string(user.userName)),
      ("user_email", string(user.userEmail)),
      ("password", string(user.password))
    })
  }
  let init = Fetch.RequestInit.make(
    ~method_=Post,
    ~body = Fetch.BodyInit.make(Js.Json.stringify(encodeUser())),
    ()
  )
  Fetch.fetchWithInit("/api/create_user", init)
  -> Js.Promise.then_((response) => {
    if Fetch.Response.ok(response) {
      Js.Promise.resolve(Belt.Result.Ok(()))
    } else {
      Fetch.Response.text(response) -> Js.Promise.then_((msg) => Js.Promise.resolve(Belt.Result.Error(msg)), _)
    }
  }, _)
}

@react.component
let make = () => {
  let t = Cf.Translation.useTranslate()
  //let { register, handleSubmit } = HookForm.useForm();
  let {Cf.HookForm.register, handleSubmit, errors} = Cf.HookForm.useForm();

  let handleSubmitData = (~data as user: User.t, ~event as e) => {
    ReactEvent.Form.preventDefault(e)
    Js.Console.log("@@@@@@@@@@@@@@@@@@@@@ cp 500: handleSubmitData()")
    Js.Console.log(user)
  }

  let showError = (field: string, vtype: string, msg: string) => {
    switch Js.Dict.get(errors, field) {
    | Some(err) =>
        if err["type"] == vtype {
          Js.Console.log("error: " ++ field)
          <Cf.FormFieldError msg={msg} />
        } else {
          React.string("")
        }
    | None => React.string("")
    }
  }

  <div className="container">
    <form onSubmit={handleSubmit(. ~dataHandler=handleSubmitData)}>
      <div className="card">
        <header className="card-header">
           <p className="card-header-title is-centered is-justify-content-center has-background-dark has-text-white">{t(~key=`${componentName}.New user registration`, ())}</p>
        </header>
        <div className="card-content">
            <div className="columns is-justify-content-center">
              <div className="column is-narrow">
                <div className="field">
                  <label className="label" > {t(~key=`${componentName}.user name`, ())}</label>
                  <div className="control"> <input type_="text" name="userName" ref={ReactDOM.Ref.callbackDomRef(register(. Cf.HookForm.makeRegisterOptions(~required=true, ())))} /> </div>
                  {showError("userName", "required", "user name is required")}
                </div>
                <div className="field">
                  <label className="label"> {t(~key=`${componentName}.email`, ())}</label>
                  <div className="control"> <input type_="text"  name="userEmail" ref={ReactDOM.Ref.callbackDomRef(register(. Cf.HookForm.makeRegisterOptions(~required=true, ~pattern=%re("/\w+@\w+/"), ())))}/> </div>
                  {showError("userEmail", "required", "user email is required")}
                  {showError("userEmail", "pattern", "wrong format")}
                </div>
                <div className="field">
                  <label className="label"> {t(~key=`${componentName}.password`, ())} </label>
                  <div className="control"> <input type_="password" name="password" ref={ReactDOM.Ref.callbackDomRef(register(. Cf.HookForm.makeRegisterOptions(~required=true, ())))} /> </div>
                  {showError("password", "required", "password is required")}
                </div>
                <div className="field">
                  <label className="label"> {t(~key=`${componentName}.passwordVerify`, ())} </label>
                  <div className="control"> <input type_="passwordVerify" name="passwordVerify" ref={ReactDOM.Ref.callbackDomRef(register(. Cf.HookForm.makeRegisterOptions(~required=true, ())))} /> </div>
                  {showError("passwordVerify", "required", "please reatype password")}
                </div>
                <Cf.ErrorMessage msg={"Passwords do not natch"} />
              </div>
            </div>
        </div>
        <footer className="card-footer">
          <div className="card-footer-item">
              <button className="button is-primary is-fullwidth" type_="submit"> {t(~key=`${componentName}.submit`, ())} </button>
          </div>
        </footer>
      </div>
    </form>
  </div>
}
