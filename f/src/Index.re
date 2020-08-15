// Entry point

switch (ReactDOM.querySelector("#root")) {
| Some(root) => 
  ReactDOM.render(<UserNamePasswordForm />, root)
| None => 
  ()
}
