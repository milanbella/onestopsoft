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
  let {HookForm.register, handleSubmit, errors} = HookForm.useForm();

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
          <FormError msg={msg} />
        } else {
          React.string("")
        }
    | None => React.string("")
    }
  }

  let passwordVerifyError = () => {
    <FormError msg="passwords does't match" />
  }

  <form onSubmit={_ => handleSubmit(. ~dataHandler=handleSubmitData)}>
    <div className="content">
      <div className="box">
        <div className="field">
          <label className="label" > {t(~key=`${componentName}.user name`, ())}{React.string(":")} </label>
          <div className="control"> <input type_="text" name="userName" ref={ReactDOM.Ref.callbackDomRef(register(. HookForm.makeRegisterOptions(~required=true, ())))} /> </div>
          {showError("userName", "required", "user name is required")}
        </div>
        <div className="field">
          <label className="label"> {t(~key=`${componentName}.email`, ())}{React.string(":")} </label>
          <div className="control"> <input type_="text"  name="userEmail" ref={ReactDOM.Ref.callbackDomRef(register(. HookForm.makeRegisterOptions(~required=true, ~pattern=%re("/\w+@\w+/"), ())))}/> </div>
          {showError("userEmail", "required", "user email is required")}
          {showError("userEmail", "pattern", "wrong format")}
        </div>
        <div className="field">
          <label className="label"> {t(~key=`${componentName}.password`, ())} </label>
          <div className="control"> <input type_="password" name="password" ref={ReactDOM.Ref.callbackDomRef(register(. HookForm.makeRegisterOptions(~required=true, ())))} /> </div>
          {showError("password", "required", "password is required")}
        </div>
        <div className="field">
          <label className="label"> {t(~key=`${componentName}.passwordVerify`, ())} </label>
          <div className="control"> <input type_="passwordVerify" name="passwordVerify" ref={ReactDOM.Ref.callbackDomRef(register(. HookForm.makeRegisterOptions(~required=true, ())))} /> </div>
          {showError("passwordVerify", "required", "please reatype password")}
        </div>
        <div className="field">
          <div className="control">
            <button className="button" type_="submit"> {t(~key=`${componentName}.submit`, ())} </button>
          </div>
        </div>
      </div>
    </div>
  </form>
}
