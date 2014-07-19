type package = {
  dir : string;
  package : string;
  variant : string option;
  dependencies : package list;
  version : string;
  build : int;
  sources : string list;
  outputs : string list;
  mutable to_build : bool;
}
