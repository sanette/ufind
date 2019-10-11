# Case insensitive, accent insensitive search engine

__Ufind__ is a small library that provides a case insentitive, accent
insensitive search in strings encoded in utf8. It is meant to be easy
to use, either for searching simple lists, or for digging in large
databases.

Accents are more general diacritics are recognized for all Latin
 characters.  For other alphabets, searching will remain accent
 sensitive.

*)

## Example

Here `sample` is a list of names that can be found in the test directory.

First we prepare the data:

```ocaml
# let items = Ufind.items_from_names sample;;
val items : string Ufind.search_item Seq.t = <fun>
```

And then we may search:

```ocaml
# let result = Ufind.select_data items "ap";;
val result : string list =
  ["Olivia Apodaca"; "Gi\195\161p \196\144\195\180ng Ngh\225\187\139"]
# List.iter print_endline result;;
Olivia Apodaca
Giáp Đông Nghị
- : unit = ()                 
```

## Install

`dune build`

`opam install .`

