# Case insensitive, accent insensitive search engine

__Ufind__ is a small [ocaml](https://ocaml.org/) library that
provides a case insentitive, accent insensitive search in strings
encoded in utf8. It is meant to be easy to use, either for searching
simple lists, or for digging in large databases.

Accents and more general diacritics are recognized for all Latin
 characters.  For other alphabets, searching will remain accent
 sensitive.

__Ufind__ will give you a list of matching strings, and this is a
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

For searching a substring in a list of strings, we only need two lines
of code.  Here we use the `sample` list of names that can be found in
the test directory.

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

_In fact, for a simple list like this, there is an even simpler way of
doing this, see [filter_list](docs/index.html#val-filter_list), but
the example above will scale immediately to large databases and more
complex searches_

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

Generating random list of 100000 strings. Time = 0.049362 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 0.092299 sec
Preprocessing items from list of 100000 elements. Time = 0.105708 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.055390 sec
Searching for probable string 'ïlo' in lazy sequence. Time = 0.094692 sec
Ïlo,Ïlo,Ïlod,Rïlo,Bïlo,Qïlo,Pïlox,Hïlon,Gïlob,Fïlop,Ïloxöf,Xïloko,Lïlohï,Mïlosa,Fïlodø,Ejïloq,Özïlo,Éhïlo,Tyqïlo,Àqïlol,Fójïlo,Ïló,Ïlø,Ïlø,Ïlø,Ïlø,Ïló,Ïló,Ïlö,Ïló,Ïløc,Ïlóq,Ïløm,Ïlöh,Ïløs,Ïlös,Ïløf,Ïlöw,Ïlósí,Ïlóno,Ïlósu,Ïlógó,Ïlósö,Ïlöföt,Ïlótàd,Kïló,Vïlö,Vïló,Pïlö,Rïló,Pïlö,Qïló,Gïlö,Bïlö,Jïlø,Pïlø,Gïlö,Sïlöf,Lïlöf,Tïlóm,Mïlóc,Rïløh,Dïlóv,Rïløt,Xïlømo,Jïlóve,Kïlódè,Dïlökí,Fïlödi,Ycïlø,Azïlø,Ufïlö,Uhïlø,Apïløl,Ïpïlø,Ídïlö,Àrïlø,Ùsïló,Óxïlø,Ánïlö,Ókïlø,Ùwïlö,Ùfïlø,Ötïlö,Girïlö,Íxïløv,Øwïløz,Xicïlø,Íxïlöv,Øzïlól,Ábïløl,Xáwïlö,Fèhïló,Föfïló,Ilo,Ilo,Ilo,Ilo,Ilo,Ilov,Iloc,Nilo,Zilo,Qilo,Iloxï,Filot,Ilokov,Ilopóc,Miloh,Piloq,Viloh,Kilor,Ilofóz,Filoci,Silolé,Émilo,Ehilor,Ópilo,Ébilok,Økilox,Öcilok,Ébilol,Ávilor,Ílo,Ílo,Ílo,Ílo,Íloj,Ílox,Ílolöf,Ílokop,Íloröd,Jílo,Gílo,Cílow,Míloje,Ymílo,Uqílol,Iló,Iló,Ilø,Iló,Iló,Ilø,Ilö,Ilö,Ilø,Ilö,Ilöp,Ilöd,Ilöm,Ilöm,Iløz,Ilötu,Iløwè,Ilöxá,Ilödï,Ilöpo,Iløko,Iløwó,Ilózà,Ilóvo,Ilópø,Ilógö,Iløzi,Ilóryf,Iløjád,Ilófor,Ilövàf,Ilócág,Ilönul,Ilöjur,Ilömök,Iløtók,Ïfílo,Topílo,Ïhílob,Siló,Filó,Nilø,Lilø,Kiló,Jiló,Qiló,Liløv,Viløn,Hilón,Jilós,Filön,Jiløl,Qilóvy,Piløje,Wilócé,Nilórï,Hilöma,Wilórø,Piløré,Xilöpé,Miløgï,Dèlílo,Ucilø,Ogiló,Isilö,Enilö,Imilø,Isiló,Ipilóp,Iriløb,Ililöm,Ùxiló,Zetilö,Geriló,Bujiló,Zawilö,Cisiló,Írilök,Ásilój,Gémilö,Wítiló,Íló,Ílø,Ílø,Íló,Ílö,Ílø,Ílö,Ílö,Ílók,Íløc,Ílöt,Ílöx,Ílóz,Ílóh,Ílög,Ílöc,Ílóg,Ílóg,Ílóvè,Ílówe,Ílóxá,Íløré,Ílóke,Ílöwí,Ílöpóm,Ílólög,Íløkep,Ílövïb,Ílødïj,Ílóhév,Ílózáj,Ílóduw,Jílø,Vílø,Cíló,Pílö,Vílö,Vílóp,Qíløq,Díløs,Bílóf,Qílöq,Sílør,Bílöm,Zílów,Nílówu,Vílögi,Tílöze,Wílólø,Qílømi,Bílösí,Sílörá,Gílöty,Rílópa,Xílócu,Ajílø,Ahíló,Yvílóc,Uqílöx,Utílók,Èpíló,Álílø,Ácílö,Àxílö,Ùfíló,Íxíló,Öpíló,Èsílø,Øtíló,Voxílø,Ùwílól,Ínílóv,Ùbílóm,Óríløz,Ruwíló,Ósílöj,Éfílør,Bèmílø,Nögíló,Lïníló
Searching for probable string 'ïlo' in preprocessed sequence. Time = 0.053558 sec
Ïlo,Ïlo,Ïlod,Rïlo,Bïlo,Qïlo,Pïlox,Hïlon,Gïlob,Fïlop,Ïloxöf,Xïloko,Lïlohï,Mïlosa,Fïlodø,Ejïloq,Özïlo,Éhïlo,Tyqïlo,Àqïlol,Fójïlo,Ïló,Ïlø,Ïlø,Ïlø,Ïlø,Ïló,Ïló,Ïlö,Ïló,Ïløc,Ïlóq,Ïløm,Ïlöh,Ïløs,Ïlös,Ïløf,Ïlöw,Ïlósí,Ïlóno,Ïlósu,Ïlógó,Ïlósö,Ïlöföt,Ïlótàd,Kïló,Vïlö,Vïló,Pïlö,Rïló,Pïlö,Qïló,Gïlö,Bïlö,Jïlø,Pïlø,Gïlö,Sïlöf,Lïlöf,Tïlóm,Mïlóc,Rïløh,Dïlóv,Rïløt,Xïlømo,Jïlóve,Kïlódè,Dïlökí,Fïlödi,Ycïlø,Azïlø,Ufïlö,Uhïlø,Apïløl,Ïpïlø,Ídïlö,Àrïlø,Ùsïló,Óxïlø,Ánïlö,Ókïlø,Ùwïlö,Ùfïlø,Ötïlö,Girïlö,Íxïløv,Øwïløz,Xicïlø,Íxïlöv,Øzïlól,Ábïløl,Xáwïlö,Fèhïló,Föfïló,Ilo,Ilo,Ilo,Ilo,Ilo,Ilov,Iloc,Nilo,Zilo,Qilo,Iloxï,Filot,Ilokov,Ilopóc,Miloh,Piloq,Viloh,Kilor,Ilofóz,Filoci,Silolé,Émilo,Ehilor,Ópilo,Ébilok,Økilox,Öcilok,Ébilol,Ávilor,Ílo,Ílo,Ílo,Ílo,Íloj,Ílox,Ílolöf,Ílokop,Íloröd,Jílo,Gílo,Cílow,Míloje,Ymílo,Uqílol,Iló,Iló,Ilø,Iló,Iló,Ilø,Ilö,Ilö,Ilø,Ilö,Ilöp,Ilöd,Ilöm,Ilöm,Iløz,Ilötu,Iløwè,Ilöxá,Ilödï,Ilöpo,Iløko,Iløwó,Ilózà,Ilóvo,Ilópø,Ilógö,Iløzi,Ilóryf,Iløjád,Ilófor,Ilövàf,Ilócág,Ilönul,Ilöjur,Ilömök,Iløtók,Ïfílo,Topílo,Ïhílob,Siló,Filó,Nilø,Lilø,Kiló,Jiló,Qiló,Liløv,Viløn,Hilón,Jilós,Filön,Jiløl,Qilóvy,Piløje,Wilócé,Nilórï,Hilöma,Wilórø,Piløré,Xilöpé,Miløgï,Dèlílo,Ucilø,Ogiló,Isilö,Enilö,Imilø,Isiló,Ipilóp,Iriløb,Ililöm,Ùxiló,Zetilö,Geriló,Bujiló,Zawilö,Cisiló,Írilök,Ásilój,Gémilö,Wítiló,Íló,Ílø,Ílø,Íló,Ílö,Ílø,Ílö,Ílö,Ílók,Íløc,Ílöt,Ílöx,Ílóz,Ílóh,Ílög,Ílöc,Ílóg,Ílóg,Ílóvè,Ílówe,Ílóxá,Íløré,Ílóke,Ílöwí,Ílöpóm,Ílólög,Íløkep,Ílövïb,Ílødïj,Ílóhév,Ílózáj,Ílóduw,Jílø,Vílø,Cíló,Pílö,Vílö,Vílóp,Qíløq,Díløs,Bílóf,Qílöq,Sílør,Bílöm,Zílów,Nílówu,Vílögi,Tílöze,Wílólø,Qílømi,Bílösí,Sílörá,Gílöty,Rílópa,Xílócu,Ajílø,Ahíló,Yvílóc,Uqílöx,Utílók,Èpíló,Álílø,Ácílö,Àxílö,Ùfíló,Íxíló,Öpíló,Èsílø,Øtíló,Voxílø,Ùwílól,Ínílóv,Ùbílóm,Óríløz,Ruwíló,Ósílöj,Éfílør,Bèmílø,Nögíló,Lïníló

Test List OK.

Searching 'hán' from text. Time = 0.000579 sec
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

Writing file /tmp/ufind-test-62f905.txt.
Searching 'ell' from file /tmp/ufind-test-62f905.txt. Time = 0.000348 sec
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
