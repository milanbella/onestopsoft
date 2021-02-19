type tRegisterOptions = {
  required: option<bool>,
  maxLength: option<int>,
}

let makeRegisterOptions = (~required: option<bool> = ?, ~maxLength: option<int> = ?, ()): tRegisterOptions => {
  let o: tRegisterOptions = {
    required: required,
    maxLength: maxLength,
  }
  o
} 



type tMouseEventHandler = ReactEvent.Mouse.t => unit
type tFormEventHandler = ReactEvent.Form.t => unit
external toMouseEventHandler: 'a => tMouseEventHandler = "%identity"
external toFormEventHandler: 'a => tFormEventHandler = "%identity"

type tUseForm<'registerOptions, 'data, 'submitErrors> = {
  //register: tRegisterOptions => Js.nullable<Dom.element> => unit,
  register: (. tRegisterOptions) => ReactDOM.Ref.callbackDomRef,
  handleSubmit: (~dataHandler: (~data: 'data, ~event: ReactEvent.Form.t) => unit, ~errorHandler: (~errors: 'submitErrors, ~event: ReactEvent.Form.t) => unit = ?, unit) => unit, 
}

@bs.module("react-hook-form") external useForm: unit => tUseForm<'registerOptions, 'data, 'submitErrors> = "useForm"

