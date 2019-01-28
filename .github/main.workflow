workflow "Main" {
  on = "push"
  resolves = [ "Shell Check" ]
}

action "Shell Check" {
  uses = "moorara/actions/shellcheck@master"
  args = "./install"
}
