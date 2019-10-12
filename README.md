# Case insensitive, accent insensitive search engine

__Ufind__ is a small library that provides a case insentitive, accent
insensitive search in strings encoded in utf8. It is meant to be easy
to use, either for searching simple lists, or for digging in large
databases.

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

Ufind is based on [Ubase](https://github.com/sanette/ubase) for diacritics removal.

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


## Install

```
dune build
opam install .
```


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

Generating random list of 100000 strings. Time = 0.052620 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 0.101246 sec
Preprocessing items from list of 100000 elements. Time = 0.115431 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.048361 sec
Searching for probable string 'ïlo' in lazy sequence. Time = 0.124173 sec
Ïlo,Ïlo,Ïloc,Ïloj,Ïloc,Ïlog,Ïlovu,Hïlo,Ïloxù,Ïlodø,Fïlo,Ïlozø,Ïlodi,Zïlow,Ïlowel,Nïlod,Dïlov,Mïloq,Ïlogop,Fïlohi,Purïlo,Ómïloc,Polïlo,Ùfïloh,Öbïlom,Jèjïlo,Ïló,Ïló,Ïlö,Ïló,Ïlóq,Ïlót,Ïløg,Ïlól,Ïlöb,Ïlöw,Ïløg,Ïlók,Ïlöb,Ïlóq,Ïlös,Ïlósö,Ïlóre,Ïlórï,Ïlókè,Ïlóva,Ïlöbàd,Ïløxig,Ïlöciq,Ïlögùg,Ïlöcùw,Ïlózuz,Ïlölin,Ïlówyz,Nïló,Qïlö,Zïlø,Gïló,Fïlö,Nïlöl,Pïlöh,Hïlóm,Qïløk,Lïlóg,Bïløl,Bïløc,Hïløp,Pïlöf,Hïløz,Tïlóga,Hïlörè,Kïlóhí,Hïlóni,Pïlófe,Epïlø,Ulïlóv,Ivïlöb,Àkïlö,Édïló,Àlïlø,Øhïló,Ïmïlö,Øbïló,Mabïlö,Èjïlöw,Épïlöf,Gígïló,Qíjïlö,Vénïlø,Pïzïlö,Ilo,Ilo,Ilok,Ilox,Ilok,Ilor,Ilod,Iloqy,Bilo,Silo,Wilo,Ilory,Pilo,Piloc,Filon,Hilog,Ilotám,Iloháp,Ciloc,Xilozo,Xilowé,Milopá,Agilo,Esilo,Íhilo,Ewilon,Ícilo,Éjilo,Éqilok,Ùgilof,Ïtilof,Öfilos,Máfilo,Ílob,Ílov,Ílopí,Ílopé,Ílolà,Ílowaf,Ílodøk,Tílo,Kílo,Ezílo,Ugílok,Ilø,Iló,Ilö,Ilö,Iló,Ilö,Ilø,Iló,Ilø,Ilø,Ilö,Ilö,Ilø,Ilöb,Ilóm,Ilöm,Iløn,Ilöd,Ilør,Ilöp,Ilör,Ilør,Ilöz,Iløx,Iløcí,Iløhö,Ilóze,Ilölø,Ilóbà,Iløpà,Iløfèn,Ilöpif,Iløtèq,Ilødíj,Iløfyw,Ilójéb,Ilótap,Ilóqón,Ødílo,Ùwílo,Íwíloq,Ïkíloc,Xupílo,Xilö,Gilö,Kilø,Lilö,Wilø,Rilø,Giló,Siløv,Wiløn,Pilóx,Wiløf,Xilóg,Tilóbø,Filöze,Cilóti,Filøgí,Wilötø,Söjílo,Jógílo,Jùwílo,Yvilöv,Ezilóq,Èwilö,Ókilö,Àhiló,Èhiló,Àriló,Øliló,Ówilöl,Èliløl,Ùhilóh,Ólilól,Éfilóz,Àlilöz,Vïlilö,Röpilø,Héciló,Lídilö,Ílø,Ílö,Íló,Ílø,Íló,Íló,Ílö,Ílø,Ílö,Ílö,Íløq,Ílój,Ílós,Ílól,Íløm,Íløj,Ílöd,Ílór,Íløw,Ílóv,Íløz,Íløni,Ílólè,Ílönu,Ílósà,Íløro,Ílómï,Ílöfø,Ílówí,Ílødè,Ílönas,Ílöhel,Íløfoc,Ílóxan,Íløkïl,Ílömím,Ílófiv,Ílökáj,Ílówod,Ílømil,Ílöxøk,Gílö,Tílö,Mílö,Fílø,Síló,Gílö,Xíløx,Cílót,Tílóp,Lílöx,Víløk,Bíløwy,Tíløru,Dílømá,Hílóje,Vílóxí,Zílócí,Uhílö,Ipílø,Ajílö,Ycíló,Agílöq,Eqílók,Ezílöw,Ucílöt,Øxílø,Ébílö,Íxíló,Øjíló,Évílø,Ølíløp,Ásíløq,Épílóp,Øxíløk,Dykílø,Öxíløq,Jurílö,Ínílør,Ïxílöd,Lïfílö,Wígílö,Dèmíló,Sïjílö
Searching for probable string 'ïlo' in preprocessed sequence. Time = 0.049993 sec
Ïlo,Ïlo,Ïloc,Ïloj,Ïloc,Ïlog,Ïlovu,Hïlo,Ïloxù,Ïlodø,Fïlo,Ïlozø,Ïlodi,Zïlow,Ïlowel,Nïlod,Dïlov,Mïloq,Ïlogop,Fïlohi,Purïlo,Ómïloc,Polïlo,Ùfïloh,Öbïlom,Jèjïlo,Ïló,Ïló,Ïlö,Ïló,Ïlóq,Ïlót,Ïløg,Ïlól,Ïlöb,Ïlöw,Ïløg,Ïlók,Ïlöb,Ïlóq,Ïlös,Ïlósö,Ïlóre,Ïlórï,Ïlókè,Ïlóva,Ïlöbàd,Ïløxig,Ïlöciq,Ïlögùg,Ïlöcùw,Ïlózuz,Ïlölin,Ïlówyz,Nïló,Qïlö,Zïlø,Gïló,Fïlö,Nïlöl,Pïlöh,Hïlóm,Qïløk,Lïlóg,Bïløl,Bïløc,Hïløp,Pïlöf,Hïløz,Tïlóga,Hïlörè,Kïlóhí,Hïlóni,Pïlófe,Epïlø,Ulïlóv,Ivïlöb,Àkïlö,Édïló,Àlïlø,Øhïló,Ïmïlö,Øbïló,Mabïlö,Èjïlöw,Épïlöf,Gígïló,Qíjïlö,Vénïlø,Pïzïlö,Ilo,Ilo,Ilok,Ilox,Ilok,Ilor,Ilod,Iloqy,Bilo,Silo,Wilo,Ilory,Pilo,Piloc,Filon,Hilog,Ilotám,Iloháp,Ciloc,Xilozo,Xilowé,Milopá,Agilo,Esilo,Íhilo,Ewilon,Ícilo,Éjilo,Éqilok,Ùgilof,Ïtilof,Öfilos,Máfilo,Ílob,Ílov,Ílopí,Ílopé,Ílolà,Ílowaf,Ílodøk,Tílo,Kílo,Ezílo,Ugílok,Ilø,Iló,Ilö,Ilö,Iló,Ilö,Ilø,Iló,Ilø,Ilø,Ilö,Ilö,Ilø,Ilöb,Ilóm,Ilöm,Iløn,Ilöd,Ilør,Ilöp,Ilör,Ilør,Ilöz,Iløx,Iløcí,Iløhö,Ilóze,Ilölø,Ilóbà,Iløpà,Iløfèn,Ilöpif,Iløtèq,Ilødíj,Iløfyw,Ilójéb,Ilótap,Ilóqón,Ødílo,Ùwílo,Íwíloq,Ïkíloc,Xupílo,Xilö,Gilö,Kilø,Lilö,Wilø,Rilø,Giló,Siløv,Wiløn,Pilóx,Wiløf,Xilóg,Tilóbø,Filöze,Cilóti,Filøgí,Wilötø,Söjílo,Jógílo,Jùwílo,Yvilöv,Ezilóq,Èwilö,Ókilö,Àhiló,Èhiló,Àriló,Øliló,Ówilöl,Èliløl,Ùhilóh,Ólilól,Éfilóz,Àlilöz,Vïlilö,Röpilø,Héciló,Lídilö,Ílø,Ílö,Íló,Ílø,Íló,Íló,Ílö,Ílø,Ílö,Ílö,Íløq,Ílój,Ílós,Ílól,Íløm,Íløj,Ílöd,Ílór,Íløw,Ílóv,Íløz,Íløni,Ílólè,Ílönu,Ílósà,Íløro,Ílómï,Ílöfø,Ílówí,Ílødè,Ílönas,Ílöhel,Íløfoc,Ílóxan,Íløkïl,Ílömím,Ílófiv,Ílökáj,Ílówod,Ílømil,Ílöxøk,Gílö,Tílö,Mílö,Fílø,Síló,Gílö,Xíløx,Cílót,Tílóp,Lílöx,Víløk,Bíløwy,Tíløru,Dílømá,Hílóje,Vílóxí,Zílócí,Uhílö,Ipílø,Ajílö,Ycíló,Agílöq,Eqílók,Ezílöw,Ucílöt,Øxílø,Ébílö,Íxíló,Øjíló,Évílø,Ølíløp,Ásíløq,Épílóp,Øxíløk,Dykílø,Öxíløq,Jurílö,Ínílør,Ïxílöd,Lïfílö,Wígílö,Dèmíló,Sïjílö

Test List OK.

```
