type tRegisterOptions = {
  required: option<bool>,
  min: option<int>,
  max: option<int>,
  minLength: option<int>,
  maxLength: option<int>,
  pattern: option<Js.Re.t>,
}

let makeRegisterOptions = (
  ~required: option<bool> = ?, 
  ~min: option<int> = ?, 
  ~max: option<int> = ?, 
  ~minLength: option<int> = ?,  
  ~maxLength: option<int> = ?, 
  ~pattern: option<Js.Re.t> = ?, 
  ()): tRegisterOptions => {
  {
    required: required,
    min: min,
    max: max,
    minLength: minLength,
    maxLength: maxLength,
    pattern: pattern
  }
} 

module Error = {
  type t = {
    "type": string 
  }
}

type tOnSubmit = ReactEvent.Form.t => unit

type tUseForm = {
  register: (. tRegisterOptions) => ReactDOM.Ref.callbackDomRef,
  handleSubmit: (. ~dataHandler: (~data: Js.Json.t, ~event: ReactEvent.Form.t) => unit) => tOnSubmit, 
  watch: unit,
  errors: Js.Dict.t<Error.t>
}

@bs.module("react-hook-form") external useForm: unit => tUseForm = "useForm"

