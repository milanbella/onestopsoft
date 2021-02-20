@react.component
let make = (~msg: string) => {
    <span className="has-text-danger"> {React.string(msg)} </span>
}
