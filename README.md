# Case insensitive, accent insensitive search engine

__Ufind__ is a small [ocaml](https://ocaml.org/) library that
provides a case insentitive, accent insensitive search in strings
encoded in utf8. It is meant to be easy to use, either for searching
simple lists, or for digging in large databases.

Accents and more general diacritics are recognized for all Latin
 characters.  For other alphabets, searching will remain accent
 sensitive.

__Ufind__ will give you a list of matching strings, and this this is a
_ranking_: exact matches will be ranked first, and then substrings
and/or strings obtained by modifying the accents will have a lower
ranking.

The notion of "exact match" is actually parameterizable. It can be a
strict equality of strings, but also a case-insensitive equality, see
["Casefolding"](https://sanette.github.io/ufind/#casefolding) in the
doc.

## Documentation

The API can be found [here](https://sanette.github.io/ufind/).

Ufind is based on [Ubase](https://sanette.github.io/ubase/) for diacritics removal.

Internally, it uses Gray's code for iterating efficiently through all
possible accented versions of a word.

## Example

For searching a substring in a list of strings, you only need two
lines of code.  Here we use the `sample` list of names that can be
found in the test directory.

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

The string "Olivia Apodaca" came first, because the substring "ap" is
present without any accent substitution. If we searched "áp" instead,
the order of the results would have been inverted.

See also the `test` directory for more examples.

## Install

```
dune build
opam install .
```

## Interfacing MYSQL

See [ufind_mysql.md](https://github.com/sanette/ufind/blob/master/ufind_mysql.md)

## Test results

```
$ dune runtest
        test alias test/runtest

Searching for 'giap' :
Giáp Đông Nghị

Searching for 'an' :
Jana Bojčić
Anica Kolenc
Anaïs Lemieux
Thando Banda
Teagan Jones
Stanojka Ljubičić
Ermanis Bendorfs
Lukman Saefullah
Silviana Nedelcu
Ellis Kuswandari
Alexandria-Cécile Ferrand
Agnethe Johannessen
Juan Sebastián Emilio Saucedo Tijerina
Štěpán Fiala

Simple Test OK.

Generating random list of 100000 strings. Time = 0.046291 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 0.104921 sec
Preprocessing items from list of 100000 elements. Time = 0.114353 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.049042 sec
Searching for probable string 'ïlo' in lazy sequence. Time = 0.102672 sec
Ïlo,Ïlo,Ïlo,Ïlo,Ïlo,Ïlop,Wïlo,Ïlolà,Jïlo,Ïlomó,Ïlomy,Sïlov,Ïlosàl,Ïlolag,Ïlocïk,Nïlot,Ïlosík,Cïloc,Nïlowí,Tïlogó,Esïlo,Ejïlox,Éhïlo,Edïlod,Ørïlov,Diqïlo,Áfïlof,Básïlo,Jösïlo,Lørïlo,Jàkïlo,Qïsïlo,Síqïlo,Ïló,Ïlø,Ïlø,Ïlö,Ïlö,Ïlø,Ïló,Ïló,Ïlø,Ïløs,Ïlør,Ïlód,Ïlóp,Ïlök,Ïlóx,Ïlöba,Ïlóci,Ïlödo,Ïlögàs,Ïlómób,Ïløzup,Ïlørùn,Ïløquv,Ïlórïd,Lïlö,Bïlö,Zïlö,Vïló,Pïlø,Xïlö,Rïló,Rïló,Zïlög,Sïlóg,Dïløj,Wïlös,Vïlöv,Qïlón,Nïlød,Wïlód,Pïlöqà,Gïløré,Qïlöfo,Rïlöfø,Cïlójo,Fïlóho,Ulïlø,Igïlø,Akïlø,Iqïløn,Orïløj,Egïlös,Ókïlö,Ézïlø,Ékïlø,Àmïlø,Èwïló,Èbïlö,Øtïlö,Fokïlø,Óbïløp,Àtïlöj,Àzïlöv,Àcïlóm,Tamïlø,Àhïlöw,Fujïlö,Bödïlö,Sídïló,Søcïló,Ilo,Ilo,Ilof,Lilo,Wilo,Ilowí,Iloge,Bilol,Ilotíj,Tilov,Ilofïr,Ilojog,Wilocu,Tiloli,Jilocè,Liloly,Hilotu,Izilom,Xuwilo,Jíhilo,Ílo,Ílo,Ílo,Ílok,Ílojá,Ílonø,Ílowí,Ílocè,Ílodøm,Dílo,Zílo,Rílo,Pílo,Kílo,Wílor,Sílowù,Tílorí,Líloru,Orílo,Uzílol,Ylílok,Ilö,Ilö,Ilø,Ilö,Iló,Ilö,Iló,Ilö,Ilög,Iløt,Ilós,Ilóq,Ilód,Ilöz,Ilóme,Ilósa,Ilömù,Ilöbàc,Ilögöd,Ilömøj,Ilómaz,Ilórík,Ørílo,Ïtílo,Hoxílo,Viló,Rilö,Cilø,Tilø,Dilö,Siló,Miló,Filø,Kilø,Wilø,Hiló,Giløx,Niløb,Qiløg,Nilóv,Biløs,Giløs,Kiløn,Diløm,Gilöb,Lilós,Kilóc,Lilöj,Hiløp,Kiløhø,Qilötà,Ciløwá,Silóci,Milöto,Qilömó,Silófo,Pilønà,Pápílo,Yjilö,Azilø,Oxilø,Ejilót,Àfilø,Ørilø,Ïdiló,Ïdiló,Èhiløp,Jahiló,Ïbiløh,Áhiløg,Modilø,Ékilöl,Àsiløx,Lèvilö,Sùwilö,Ílö,Íló,Ílø,Ílö,Íló,Íló,Íløk,Ílóx,Íløc,Íløj,Ílöh,Ílöd,Ílöc,Íløt,Ílóv,Ílöz,Ílóp,Ílós,Íløh,Íløq,Íløk,Ílöwï,Ílöxù,Ílörà,Ílóhù,Ílóve,Íløqï,Ílóze,Ílómù,Ílójög,Ílójag,Xíló,Níló,Hílø,Nílø,Gílö,Hílöl,Nílök,Kíløm,Xílöv,Fílök,Xílóf,Lílóh,Vílømø,Bílöwi,Qílöny,Cílöjï,Qíløha,Ohíló,Yníló,Osíló,Oqílö,Uwílón,Öhíló,Ècílø,Ídílø,Ívílø,Èhílø,Èsílö,Ùrílø,Ézíløh,Ídíløk,Àxílød,Ùbílód,Ønílód,Míbílö,Føcílö,Qïnílö,Møjílö,Qírílö,Qókíló,Sámíló,Sítílø
Searching for probable string 'ïlo' in preprocessed sequence. Time = 0.048762 sec
Ïlo,Ïlo,Ïlo,Ïlo,Ïlo,Ïlop,Wïlo,Ïlolà,Jïlo,Ïlomó,Ïlomy,Sïlov,Ïlosàl,Ïlolag,Ïlocïk,Nïlot,Ïlosík,Cïloc,Nïlowí,Tïlogó,Esïlo,Ejïlox,Éhïlo,Edïlod,Ørïlov,Diqïlo,Áfïlof,Básïlo,Jösïlo,Lørïlo,Jàkïlo,Qïsïlo,Síqïlo,Ïló,Ïlø,Ïlø,Ïlö,Ïlö,Ïlø,Ïló,Ïló,Ïlø,Ïløs,Ïlør,Ïlód,Ïlóp,Ïlök,Ïlóx,Ïlöba,Ïlóci,Ïlödo,Ïlögàs,Ïlómób,Ïløzup,Ïlørùn,Ïløquv,Ïlórïd,Lïlö,Bïlö,Zïlö,Vïló,Pïlø,Xïlö,Rïló,Rïló,Zïlög,Sïlóg,Dïløj,Wïlös,Vïlöv,Qïlón,Nïlød,Wïlód,Pïlöqà,Gïløré,Qïlöfo,Rïlöfø,Cïlójo,Fïlóho,Ulïlø,Igïlø,Akïlø,Iqïløn,Orïløj,Egïlös,Ókïlö,Ézïlø,Ékïlø,Àmïlø,Èwïló,Èbïlö,Øtïlö,Fokïlø,Óbïløp,Àtïlöj,Àzïlöv,Àcïlóm,Tamïlø,Àhïlöw,Fujïlö,Bödïlö,Sídïló,Søcïló,Ilo,Ilo,Ilof,Lilo,Wilo,Ilowí,Iloge,Bilol,Ilotíj,Tilov,Ilofïr,Ilojog,Wilocu,Tiloli,Jilocè,Liloly,Hilotu,Izilom,Xuwilo,Jíhilo,Ílo,Ílo,Ílo,Ílok,Ílojá,Ílonø,Ílowí,Ílocè,Ílodøm,Dílo,Zílo,Rílo,Pílo,Kílo,Wílor,Sílowù,Tílorí,Líloru,Orílo,Uzílol,Ylílok,Ilö,Ilö,Ilø,Ilö,Iló,Ilö,Iló,Ilö,Ilög,Iløt,Ilós,Ilóq,Ilód,Ilöz,Ilóme,Ilósa,Ilömù,Ilöbàc,Ilögöd,Ilömøj,Ilómaz,Ilórík,Ørílo,Ïtílo,Hoxílo,Viló,Rilö,Cilø,Tilø,Dilö,Siló,Miló,Filø,Kilø,Wilø,Hiló,Giløx,Niløb,Qiløg,Nilóv,Biløs,Giløs,Kiløn,Diløm,Gilöb,Lilós,Kilóc,Lilöj,Hiløp,Kiløhø,Qilötà,Ciløwá,Silóci,Milöto,Qilömó,Silófo,Pilønà,Pápílo,Yjilö,Azilø,Oxilø,Ejilót,Àfilø,Ørilø,Ïdiló,Ïdiló,Èhiløp,Jahiló,Ïbiløh,Áhiløg,Modilø,Ékilöl,Àsiløx,Lèvilö,Sùwilö,Ílö,Íló,Ílø,Ílö,Íló,Íló,Íløk,Ílóx,Íløc,Íløj,Ílöh,Ílöd,Ílöc,Íløt,Ílóv,Ílöz,Ílóp,Ílós,Íløh,Íløq,Íløk,Ílöwï,Ílöxù,Ílörà,Ílóhù,Ílóve,Íløqï,Ílóze,Ílómù,Ílójög,Ílójag,Xíló,Níló,Hílø,Nílø,Gílö,Hílöl,Nílök,Kíløm,Xílöv,Fílök,Xílóf,Lílóh,Vílømø,Bílöwi,Qílöny,Cílöjï,Qíløha,Ohíló,Yníló,Osíló,Oqílö,Uwílón,Öhíló,Ècílø,Ídílø,Ívílø,Èhílø,Èsílö,Ùrílø,Ézíløh,Ídíløk,Àxílød,Ùbílód,Ønílód,Míbílö,Føcílö,Qïnílö,Møjílö,Qírílö,Qókíló,Sámíló,Sítílø

Test List OK.

Searching 'hán' from text. Time = 0.000578 sec
position #307 = Hán
position #29 = tháng
position #1161 = tháng
position #1402 = tháng
position #1501 = tháng
position #1569 = kháng
position #1674 = kháng
position #2417 = tháng
position #11 = Phan
position #357 = Phan
position #726 = Phan
position #1083 = Phan
position #1205 = Phan
position #1727 = Phan
position #1809 = Phan
position #1998 = Phan
position #2222 = Phan
position #2397 = Phan
position #195 = thân
position #1180 = thành
position #1820 = thành
position #1955 = thành
position #2039 = thành

Test Text OK.

Writing file /tmp/ufind-test-37fb47.txt.
Searching 'ell' from file /tmp/ufind-test-37fb47.txt. Time = 0.000393 sec
position #319 = elle
position #750 = elle
position #1012 = elle
position #1522 = elle
position #1568 = elle
position #955 = belle
position #766 = elle-même
position #1432 = qu’elle
position #962 = quoiqu’elle

Test Channel OK.

```
