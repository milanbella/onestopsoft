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
  let t = Translation.useTranslate()
  //let { register, handleSubmit } = HookForm.useForm();
  let {HookForm.register, handleSubmit} = HookForm.useForm();

  handleSubmit((user: User.t) => {
    ignore(registerUser(user))
  })

  <div className="content">
    <div className="box">
      <div className="field">
        <label className="label" > {t(~key=`${componentName}.user name`, ())}{React.string(":")} </label>
        <div className="control"> <input type_="text" name="userName" ref={ReactDOM.Ref.callbackDomRef(register(HookForm.makeRegisterOptions()))} /> </div>
      </div>
      <div className="field">
        <label className="label"> {t(~key=`${componentName}.email`, ())}{React.string(":")} </label>
        <div className="control"> <input type_="text"  name="userEmail" ref={ReactDOM.Ref.callbackDomRef(register(HookForm.makeRegisterOptions()))}/> </div>
      </div>
      <div className="field">
        <label className="label"> {t(~key=`${componentName}.password`, ())} </label>
        <div className="control"> <input type_="password" name="password" ref={ReactDOM.Ref.callbackDomRef(register(HookForm.makeRegisterOptions()))} /> </div>
      </div>
      <div className="field">
        <div className="control">
          <button className="button is-link" > {t(~key=`${componentName}.submit`, ())} </button>
        </div>
      </div>
    </div>
  </div>
}
