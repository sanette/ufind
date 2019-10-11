# Case insensitive, accent insensitive search engine

__Ufind__ is a small library that provides a case insentitive, accent
insensitive search in strings encoded in utf8. It is meant to be easy
to use, either for searching simple lists, or for digging in large
databases.

Accents are more general diacritics are recognized for all Latin
 characters.  For other alphabets, searching will remain accent
 sensitive.

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


## Result of test

```
$ dune runtest
        test alias test/runtest

Searching for 'giap' :
Giáp Đông Nghị

Searching for 'an' :
Anica Kolenc
Jana Bojčić
Anaïs Lemieux
Thando Banda
Teagan Jones
Ermanis Bendorfs
Stanojka Ljubičić
Lukman Saefullah
Silviana Nedelcu
Ellis Kuswandari
Alexandria-Cécile Ferrand
Agnethe Johannessen
Juan Sebastián Emilio Saucedo Tijerina
Štěpán Fiala

Simple Test OK.

Generating random list of 100000 strings. Time = 0.048346 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 0.109502 sec
Preprocessing items from list of 100000 elements. Time = 0.136379 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.051092 sec
Searching for probable string 'ïlo' in lazy sequence. Time = 0.112244 sec
Ïlo,Ïlo,Ïlo,Ïlov,Ïlot,Ïlod,Ïlot,Ïlohí,Ïloxé,Ïlogo,Ïlofïd,Ïlobuw,Ïloxöw,Ïlø,Ïlø,Ïló,Ïlø,Ïlö,Ïló,Ïló,Ïló,Ïløw,Ïløw,Ïlöm,Ïlóm,Ïlól,Ïlór,Ïlój,Ïlów,Ïløj,Ïløni,Ïlóvï,Ïløró,Ïlótó,Ïlólö,Ïlójy,Ïlølè,Ïlødu,Ïlöno,Ïlømàd,Ïløgóz,Ïlónyk,Ïlógøp,Ilo,Ilo,Ilo,Ilor,Ilor,Ilor,Ilodí,Ilopu,Ilowid,Ílo,Ílo,Ílo,Ílo,Ílow,Ílokï,Ílobo,Ílosù,Ílofèr,Ílohøb,Ílofàt,Ílokev,Íloböq,Iló,Ilö,Ilö,Ilø,Ilø,Ilø,Ilöc,Ilóp,Iløn,Ilós,Ilös,Ilöq,Ilöf,Ilón,Ilölé,Ilómö,Ilóvo,Ilóhé,Ilöbe,Iløka,Ilözí,Iløví,Ilölàs,Ilógár,Iløzux,Ilödíz,Ilöwiz,Ilöjøf,Ilövév,Iløzàp,Ílø,Ílø,Íló,Ílö,Íló,Ílø,Íló,Íló,Ílø,Ílöc,Ílöb,Íløs,Ílöcó,Ílózí,Íløbà,Ílóvy,Ílónu,Íløpù,Ílózöz,Ílófùm,Ílöféb,Íløcïj,Ílöpéb,Íløjeh
Searching for probable string 'ïlo' in preprocessed sequence. Time = 0.048474 sec
Ïlo,Ïlo,Ïlo,Ïlov,Ïlot,Ïlod,Ïlot,Ïlohí,Ïloxé,Ïlogo,Ïlofïd,Ïlobuw,Ïloxöw,Ïlø,Ïlø,Ïló,Ïlø,Ïlö,Ïló,Ïló,Ïló,Ïløw,Ïløw,Ïlöm,Ïlóm,Ïlól,Ïlór,Ïlój,Ïlów,Ïløj,Ïløni,Ïlóvï,Ïløró,Ïlótó,Ïlólö,Ïlójy,Ïlølè,Ïlødu,Ïlöno,Ïlømàd,Ïløgóz,Ïlónyk,Ïlógøp,Ilo,Ilo,Ilo,Ilor,Ilor,Ilor,Ilodí,Ilopu,Ilowid,Ílo,Ílo,Ílo,Ílo,Ílow,Ílokï,Ílobo,Ílosù,Ílofèr,Ílohøb,Ílofàt,Ílokev,Íloböq,Iló,Ilö,Ilö,Ilø,Ilø,Ilø,Ilöc,Ilóp,Iløn,Ilós,Ilös,Ilöq,Ilöf,Ilón,Ilölé,Ilómö,Ilóvo,Ilóhé,Ilöbe,Iløka,Ilözí,Iløví,Ilölàs,Ilógár,Iløzux,Ilödíz,Ilöwiz,Ilöjøf,Ilövév,Iløzàp,Ílø,Ílø,Íló,Ílö,Íló,Ílø,Íló,Íló,Ílø,Ílöc,Ílöb,Íløs,Ílöcó,Ílózí,Íløbà,Ílóvy,Ílónu,Íløpù,Ílózöz,Ílófùm,Ílöféb,Íløcïj,Ílöpéb,Íløjeh

Test List OK.

```
