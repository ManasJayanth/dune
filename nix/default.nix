# paramaterised derivation with dependencies injected (callPackage style)
{ pkgs, stdenv, opam2nix }:
let
  strings = pkgs.lib.strings;
  args = {
    inherit (pkgs.ocaml-ng.ocamlPackages_4_12) ocaml;
    selection = ./opam-selection.nix;
    src = builtins.filterSource (path: type:
      if type == "directory" then
        (let name = baseNameOf path;
        in name != "_boot" && name != ".git" && name != "_build" && name
        != "_opam")
      else
        true) ../.;
  };
  opam-selection = opam2nix.build args;
  localPackages = let contents = builtins.attrNames (builtins.readDir ../.);
  in builtins.filter (strings.hasSuffix ".opam") contents;
  resolve = opam2nix.resolve args (localPackages ++ [
    # test deps
    "lwt"
    "bisect_ppx"
    "cinaps"
    "core_bench"
    "csexp"
    "js_of_ocaml"
    "js_of_ocaml-compiler"
    "mdx"
    "menhir"
    "merlin"
    "ocamlfind"
    "odoc"
    "ppx_expect"
    "ppx_inline_test"
    "ppxlib"
    "result"
    "utop"
  ]);

in (builtins.listToAttrs (builtins.map (fname:
  let packageName = strings.removeSuffix ".opam" fname;
  in {
    name = packageName;
    value = builtins.getAttr packageName opam-selection;
  }) localPackages)) // {
    inherit resolve;
    opam = opam-selection;
  }