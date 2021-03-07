type tShowingCompenent = Login_userNamePasswordForm
  | Login_main 

type t = {
  showingComponent: tShowingCompenent
}

let state: t = {
  showingComponent: Login_userNamePasswordForm
}

type tAction = 
  ChangeShowingComponent(tShowingCompenent) |
  Noop

let reducer = (state: t, action: tAction): t => {
  switch action {
  | ChangeShowingComponent(c) => {showingComponent: c} 
  | Noop => state
  }
} 

