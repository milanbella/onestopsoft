type tRegisterOptions = {
  required: option<bool>
  maxLength: option<int>
}

let makeRegisterOptions = (~required: option<bool> = ?, ~maxLength: option<int> = ?, ()): tRegisterOptions => {
  let o: tRegisterOptions = {
    required: required,
    maxLength: maxLength,
  }
  o
} 

type tUseForm<'data> = {
  register: tRegisterOptions => (Js.nullable<Dom.element> => unit)
  handleSubmit: ('data => unit) => unit, 
}

@bs.module("react-hook-form") external useForm: unit => tUseForm<'data> = "useForm"

