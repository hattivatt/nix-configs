{ inputs, ... }:
{
  flake-file.inputs = {
    kosync = {
      url = "git+https://codeberg.org/cmooon/kosync";
    };
  };
}
