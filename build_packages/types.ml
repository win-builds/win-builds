type package = {
  dir : string;
  package : string;
  variant : string option;
  dependencies : package list;
  mutable build : bool;
}
