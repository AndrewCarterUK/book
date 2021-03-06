open! Core_kernel
open! Import
open! Filename
open Poly

let%test _ = split_extension "/foo/my_file" = ("/foo/my_file", None)
let%test _ = split_extension "/foo/my_file.txt" = ("/foo/my_file", Some "txt")
let%test _ = split_extension "/foo/my_file.1.txt" = ("/foo/my_file.1", Some "txt")
let%test _ = split_extension "/home/c.falls/my_file" = ("/home/c.falls/my_file", None)

let%test _ =
  split_extension "/home/c.falls/my_file.txt" = ("/home/c.falls/my_file", Some "txt")
;;

let%test _ =
  split_extension "/home/c.falls/my_file.1.txt" = ("/home/c.falls/my_file.1", Some "txt")
;;

let%test _ = split_extension "my_file" = ("my_file", None)
let%test _ = split_extension "my_file.txt" = ("my_file", Some "txt")
let%test _ = split_extension "my_file.1.txt" = ("my_file.1", Some "txt")
let%test _ = split_extension "/my_file" = ("/my_file", None)
let%test _ = split_extension "/my_file.txt" = ("/my_file", Some "txt")
let%test _ = split_extension "/my_file.1.txt" = ("/my_file.1", Some "txt")

let%test_unit _ =
  List.iter
    ~f:(fun (path, pieces) ->
      [%test_result: string] ~expect:path (of_parts pieces);
      [%test_result: string list] ~expect:pieces (parts path))
    [ "/tmp/foo/bar/baz", [ "/"; "tmp"; "foo"; "bar"; "baz" ]
    ; ".", [ "." ]
    ; "/", [ "/" ]
    ; "./foo", [ "."; "foo" ]
    ]
;;

let%test _ = parts "/tmp/foo/bar/baz/" = [ "/"; "tmp"; "foo"; "bar"; "baz" ]
let%test _ = parts "//tmp//foo//bar" = [ "/"; "tmp"; "foo"; "bar" ]
let%test _ = parts "" = [ "." ]
let%test _ = parts "./" = [ "." ]
let%test _ = parts "./." = [ "." ]
let%test _ = parts "././." = [ "."; "." ]
let%test _ = parts "foo" = [ "."; "foo" ]
let%test _ = parts "./foo/" = [ "."; "foo" ]
let%test _ = parts "./foo/." = [ "."; "foo"; "." ]
let%test _ = of_parts [ "."; "."; "." ] = "././."

(* Assert type equality. *)
let _f (x : int Filename.Map.t) : int String.Map.t = x

let%expect_test "V1" =
  let examples =
    [ "/foo/my_file.1.txt"
    ; "/home/c.falls/my_file.1.txt"
    ; "/tmp/foo/bar/baz"
    ; "//tmp//foo//bar"
    ; "././."
    ]
  in
  print_and_check_stable_type [%here] (module Stable.V1) examples;
  [%expect
    {|
    (bin_shape_digest d9a8da25d5656b016fb4dbdc2e4197fb)
    ((sexp   /foo/my_file.1.txt)
     (bin_io "\018/foo/my_file.1.txt"))
    ((sexp   /home/c.falls/my_file.1.txt)
     (bin_io "\027/home/c.falls/my_file.1.txt"))
    ((sexp   /tmp/foo/bar/baz)
     (bin_io "\016/tmp/foo/bar/baz"))
    ((sexp   //tmp//foo//bar)
     (bin_io "\015//tmp//foo//bar"))
    ((sexp   ././.)
     (bin_io "\005././.")) |}]
;;

(* Assert type equality between stable and unstable map types *)
let _f (x : int Filename.Map.t) : int Stable.V1.Map.t = x
