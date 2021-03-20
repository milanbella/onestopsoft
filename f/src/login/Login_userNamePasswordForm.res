let cFILE = "Login_userNamePasswordForm.res"
let componentName = "Login_userNamePasswordForm"

module User = {
  type t = {
    userName: string,
    userEmail: string,
    password: string,
  }
}

let registerUser = (user: User.t): Js.Promise.t<Belt.Result.t<Cf.Rest.t, Cf.Rest.e>> => {
  let encodeUser = () => {
    open Json.Encode
    object_(list{
      ("user_name", string(user.userName)),
      ("user_email", string(user.userEmail)),
      ("password", string(user.password))
    })
  }
  Cf.Rest.post("/api/create_user", Js.Json.stringify(encodeUser())) 
}


@react.component
let make = () => {
  let cFUNC = "make()"

  module FormData = {
    type t = {
      userName: string,
      userEmail: string,
      password: string,
      passwordVerify: string
    }

    let decode = (j: Js.Json.t): option<t> => {
      try {
        open Json.Decode
        Some({
          userName: field("userName", string, j),
          userEmail: field("userEmail", string, j),
          password: field("password", string, j),
          passwordVerify: field("passwordVerify", string, j)
        })
      } catch {
      | Json.Decode.DecodeError(msg) =>
        C_logger.error(cFILE, cFUNC,`decode error: ${msg}`)
        None
      }
    }
  }

  let t = Cf.Translation.useTranslate()
  let {Cf.HookForm.register, handleSubmit, errors} = Cf.HookForm.useForm();

  let (_, setErrorMsg) = React.useState(() => "")

  let handleFormData = (data: FormData.t) => {
    if data.password != data.passwordVerify {
      setErrorMsg(_ => "passwords do not match");
    } else {
      let user: User.t = {
        userEmail: data.userEmail,
        userName: data.userName,
        password: data.password
      }
      ignore(registerUser(user)
      -> Js.Promise.then_(res => {
        switch res {
        | Belt.Result.Ok(_) => Js.Promise.resolve(())
        | Belt.Result.Error({Cf.Rest.err, message}) => 
          setErrorMsg(_ => `${err}: ${message}`)
          Js.Promise.resolve(())
        }
      }, _)
      -> Js.Promise.catch(err => {
        C.Logger.errorE(cFILE, cFUNC, "registerUser() failed", err)
        Js.Promise.resolve(())
      }, _))
    }
  }

  let handleSubmitData = (~data: Js.Json.t, ~event as e) => {
    let cFUNC = "handleSubmitData()"
    ReactEvent.Form.preventDefault(e)
    Js.Console.log("@@@@@@@@@@@@@@@@@@@@@ cp 500: handleSubmitData()")
    Js.Console.log(data)

    let formData = FormData.decode(data); 
    switch(formData) {
    | Some(fd) => handleFormData(fd) 
    | None =>
        C.Logger.error(cFILE, cFUNC, "FormData.decode() failed")
        setErrorMsg(_ => "error");
    }
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
                <Cf.ErrorMessage msgKey={"passwords do not match"} />
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
