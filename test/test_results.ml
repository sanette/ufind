(***********)
(* example *)


(* SIMPLE TESTS

# let aaa = from_utf8_string_with_count "Jérôme";;
val aaa : bytes * (int * (subs * string)) list =
  ("Jerome", [(4, (Uchar, "o")); (1, (Uchar, "e"))])
# let subs = snd aaa;;
val subs : (int * (subs * string)) list =
  [(4, (Uchar, "o")); (1, (Uchar, "e"))]
# apply_subs subs "Jérôme";;
- : bytes = "Jerome"
# let all = power_list subs;;
val all : (int * (subs * string)) list list =
  [[]; [(1, (Uchar, "e"))]; [(4, (Uchar, "o"))];
   [(4, (Uchar, "o")); (1, (Uchar, "e"))]]
# List.map (fun sub -> apply_subs sub "Jérôme") all;;
- : bytes list =
["J\195\169r\195\180me"; "Jer\195\180me"; "J\195\169rome"; "Jerome"]

*)


(* Aina Jokimies
 * Ekaterina Sjeničić
 * Lambert Dahlberg
 * Juan Sebastián Emilio Saucedo Tijerina
 * Lia Victória Martins Neves
 * Garron Ruppersberger
 * Sven-Olov Larsson
 * Quincy Gutkowski
 * Thando Banda
 * Koray Kahveci
 * Štěpán Fiala
 * Amina Cummerata
 * Agnethe Johannessen
 * Jana Bojčić
 * Elliot Reinger
 * Evģenijs Veidenbaums
 * Adrienne Wohlgemut
 * David Boucher
 * Stanojka Ljubičić
 * Jacquelyn Rowe
 * Đurđevka Ičelić
 * Valerija Lambić
 * Ilona Vavřík
 * Zita Neureuther
 * Olivia Apodaca
 * Anica Kolenc
 * Oláh Milla
 * Isaac Trujillo
 * Anaïs Lemieux
 * Alexandria-Cécile Ferrand
 * Lukman Saefullah
 * Ermanis Bendorfs
 * Ellis Kuswandari
 * Mădălin Sava
 * Silviana Nedelcu
 * Lotte Hubert
 * Justin Koster
 * Giáp Đông Nghị
 * Teagan Jones *)


(* How to search from a list of names.

 # open Search;;
 # let items = items_from_names sample;;
val items : string search_item Seq.t = <fun> 

 # find_data_list items "giap";;
- : string list = ["Gi\195\161p \196\144\195\180ng Ngh\225\187\139"]

 # find_data_list items "an" |> List.iter print_endline;;
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
- : unit = ()

*)

(*
 # let items = items_from_names sample;;
val items : string search_item Seq.t = <fun>
 # let matching_stop _ _ = print_endline "OK"; false;;
val matching_stop : 'a -> 'b -> bool = <fun>
 # let stop _ = print_endline "SEARCHING"; false;;
val stop : 'a -> bool = <fun>
 # find_data_list ~stop ~matching_stop items "an" |> List.iter print_endline;;
SEARCHING
SEARCHING
SEARCHING
SEARCHING
SEARCHING
OK
SEARCHING
SEARCHING
SEARCHING
SEARCHING
SEARCHING
OK
SEARCHING
SEARCHING
OK
SEARCHING
SEARCHING
OK
SEARCHING
OK
SEARCHING
SEARCHING
SEARCHING
SEARCHING
SEARCHING
OK
SEARCHING
SEARCHING
SEARCHING
SEARCHING
SEARCHING
SEARCHING
SEARCHING
OK
SEARCHING
SEARCHING
SEARCHING
OK
SEARCHING
OK
SEARCHING
OK
SEARCHING
OK
SEARCHING
OK
SEARCHING
SEARCHING
OK
SEARCHING
SEARCHING
SEARCHING
OK
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
- : unit = ()

*)



(* How to search from a file.

utop # let channel = open_out "/tmp/aaa";;
val channel : out_channel = <abstr>
utop # List.iter (fun l -> output_string channel (l^"\n")) sample;;
- : unit = ()
utop # close_out channel;;
- : unit = ()
utop # let id x = x;;
val id : 'a -> 'a = <fun>
utop # let items = items_from_file id id "/tmp/aaa";;
val items : string search_item Seq.t = <fun>
utop # find_data_list items "an" |> List.iter print_endline;;
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
- : unit = ()


*)


(* How to search an infinite sequence.

   The infinite sequence for testing purposes is a random sequence:
   
   # let seq = random_seq 6;;
   val seq : string Seq.t = <fun>

   We transform it into a sequence of searchable items, where the "name" field
   is the string itself, and the "data" field is also the same string:

   # let id x = x;;
   val id : 'a -> 'a = <fun>

   # let items = items_from_seq id id seq;;
   val items : string search_item Seq.t = <fun>

   We search for names with "lin" and stop after 1 sec:

   # find_data_list ~stop:(make_stop ~timeout:1. ()) items "lin" 
     |> List.iter print_endline;;
   Linèf
   ølinu
   ílini
   Línar
   Ylïn
   Elïn
   ölínö
   Pálín
   Sálïn
   - : unit = ()

   Now we search only amongst the first 10000 entries:

   # find_data_list ~stop:(make_stop ~length:10000 ()) items "lin" 
     |> List.iter print_endline;;
   Lin
   Liním
   Linïh
   Lín
   Línyv
   ólín
   élïnø
   Nèlïn
   Wölïn
   - : unit = ()

   Now we stop after 5 results or after 10 seconds:

   # find_data_list ~stop:(make_stop ~timeout:10. ()) 
     ~matching_stop:(make_stop ~length:5 ()) items "lin" 
     |> List.iter print_endline;;
   Lin
   Linez
   élinø
   Lïna
   Gélín
   - : unit = ()

   We can use matching_stop to print results as they come:
   (hence not sorted; but the returned list is sorted.)

   # let matching_stop (_,item) = print_endline (item.data); false;;
   val matching_stop : 'a * string Search.search_item -> unit = <fun>

   # find_data_list ~matching_stop ~stop:(make_stop ~length:10000 ()) items "lin";;
   Qùlïn
   Lïnyd
   Lin
   ùlïní
   Linø
   - : string list =
   ["Lin"; "Lin\195\184"; "L\195\175nyd"; "\195\185l\195\175n\195\173";
   "Q\195\185l\195\175n"]

 *)




(* RESULT WITH CF_D145:

utop # Search.test_list ();;
Generating random list of 100000 strings. Time = 0.176564 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 2.209570 sec
Preprocessing items from list of 100000 elements. Time = 1.359650 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.200906 sec
Searching for probable string 'lïn' in lazy sequence. Time = 2.222598 sec
Lïné,Lïnét,Lïnöp,Lïnozà,Alïnè,Ilïnù,Lïnamy,ólïn,Jalïn,Sölïn,Unylïn,Nølïnà,Wölïne,Ifèlïn,Ygàlïn,àlïlïn,Liná,Linó,Liná,Linï,Linù,Lino,Elin,Lináz,Linès,Linømo,Linyfy,Ylinàq,Tiliná,ólinà,Silinó,Volini,Ugølin,Ewèlin,Yhólin,Lín,Lín,Líne,Línø,Línéd,Línutï,Línóné,Línöví,Línàpó,Elín,Ilín,Ilínom,Elínix,Nulín,àlín,àlín,ölína,Yvilín,Tílínu,Ubølín,ábùlín
Searching for probable string 'lïn' in preprocessed sequence. Time = 0.197295 sec
Lïné,Lïnöp,Lïnét,Lïnamy,Ilïnù,Alïnè,Lïnozà,Jalïn,ólïn,Nølïnà,Unylïn,Sölïn,Wölïne,Ygàlïn,Ifèlïn,àlïlïn,Lino,Linù,Linï,Liná,Linó,Liná,Linès,Lináz,Elin,Linyfy,Linømo,Ylinàq,Volini,Silinó,ólinà,Tiliná,Ugølin,Yhólin,Ewèlin,Lín,Lín,Línø,Líne,Línéd,Línàpó,Línöví,Línóné,Línutï,Ilín,Elín,Elínix,Ilínom,Nulín,àlín,àlín,ölína,Yvilín,Ubølín,Tílínu,ábùlín
- : unit = ()

RESULT WITH CF_D144:

utop # Search.test_list ();;
Generating random list of 100000 strings. Time = 0.175086 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 1.131501 sec
Preprocessing items from list of 100000 elements. Time = 0.410349 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.187212 sec
Searching for probable string 'lïn' in lazy sequence. Time = 1.128894 sec
Lïn,Lïn,Lïn,Lïnø,Elïn,Lïnof,élïn,Lïnèxø,èlïn,Colïn,élïné,Hylïn,Holïnö,Dïlïn,Sélïn,èlïnam,élïnàx,Gylïnó,Wïlïn,Zílïné,Qálïnù,Wólïnè,Cïlïnu,Mölïnà,Mölïne,öjàlïn,Lin,Lin,Lina,Linöl,Linyk,Linifá,Linuhø,Hulin,Kulin,àlinö,ílinàx,Dùlin,èlinál,Jálin,èlinéf,Hølinù,Làliní,Vàlinu,örólin,Lín,Lín,Línu,Líny,Línè,Línïs,Línit,Línik,Línoh,Línèh,Línes,Línir,Línís,Línidï,Olín,Ulín,Elíné,Elínók,álínà,ólínög,Tylína,ïlínèf,álínèk,Dàlín,Cílín,Obílín,ørílín
Searching for probable string 'lïn' in preprocessed sequence. Time = 0.189529 sec
Lïn,Lïn,Lïn,Lïnø,Lïnof,Elïn,èlïn,Lïnèxø,élïn,Hylïn,élïné,Colïn,Wïlïn,Gylïnó,élïnàx,èlïnam,Sélïn,Dïlïn,Holïnö,Mölïne,Mölïnà,Cïlïnu,Wólïnè,Qálïnù,Zílïné,öjàlïn,Lin,Lin,Lina,Linyk,Linöl,Linuhø,Linifá,àlinö,Kulin,Hulin,èlinéf,Jálin,èlinál,Dùlin,ílinàx,Vàlinu,Làliní,Hølinù,örólin,Lín,Lín,Línè,Líny,Línu,Línís,Línir,Línes,Línèh,Línoh,Línik,Línit,Línïs,Línidï,Ulín,Olín,Elíné,Elínók,álínà,álínèk,ïlínèf,Tylína,ólínög,Cílín,Dàlín,Obílín,ørílín
- : unit = ()

RESULT WITH CF_D147:

utop # Search.test_list ();;
Generating random list of 100000 strings. Time = 0.158110 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 1.869191 sec
Preprocessing items from list of 100000 elements. Time = 1.023775 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.194901 sec
Searching for probable string 'lïn' in lazy sequence. Time = 1.863296 sec
Lïn,Lïn,Lïn,Lïn,Lïná,Lïni,Lïnè,Lïnùj,Elïn,Lïnál,Lïnuv,Lïnùw,Lïnohó,Lïnùre,Olïnyt,àlïn,ùlïn,Gulïn,Pylïn,èlïne,ølïnon,Tylïnï,ölïnu,ölïnèk,élïnïd,Lin,Lin,Lin,Line,Liní,Line,Lino,Linup,Linis,Linóx,Linan,Linyhø,Linorö,Linuwà,Linïwe,Linokø,àliní,ólinó,Mølinù,Omilin,álinén,Sölin,Pölin,Pùlinu,Fïlinö,Lílinù,Akólin,àgàlin,èjélin,Lín,Lín,Lín,Lín,Lín,Líná,Línïn,Línóz,Línïfó,Línùwï,Línyne,Línyrí,Elínáf,ólínï,ïlínèt,Sùlín,Lùlín,óvalín,àxílín
Searching for probable string 'lïn' in preprocessed sequence. Time = 0.192657 sec
Lïn,Lïn,Lïn,Lïn,Lïnè,Lïni,Lïná,Lïnùw,Lïnuv,Lïnál,Elïn,Lïnùj,Lïnùre,Lïnohó,Pylïn,Gulïn,ùlïn,àlïn,Olïnyt,ölïnu,Tylïnï,ølïnon,èlïne,élïnïd,ölïnèk,Lin,Lin,Lin,Lino,Line,Liní,Line,Linan,Linóx,Linis,Linup,Linokø,Linïwe,Linuwà,Linorö,Linyhø,ólinó,àliní,Pölin,Sölin,álinén,Omilin,Mølinù,Lílinù,Fïlinö,Pùlinu,Akólin,èjélin,àgàlin,Lín,Lín,Lín,Lín,Lín,Líná,Línóz,Línïn,Línyrí,Línyne,Línùwï,Línïfó,Elínáf,ólínï,ïlínèt,Lùlín,Sùlín,óvalín,àxílín
- : unit = ()

RESULT WITH CF_ASCII:

utop # Search.test_list ();;
Generating random list of 100000 strings. Time = 0.158326 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 0.817624 sec
Preprocessing items from list of 100000 elements. Time = 0.272449 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.185873 sec
Searching for probable string 'lïn' in lazy sequence. Time = 0.821458 sec
Lïn,Lïnø,Lïnïq,Olïn,Alïn,Lïnad,Lïnùn,Olïn,Lïníb,élïn,Elïnè,Lïnødö,Lïneco,Lïnówö,Lïnùby,Lïnöme,Lïnáwo,ölïnö,àlïní,Silïn,Pølïn,ùlïniq,ölïnis,Jólïn,Iqilïn,Omèlïn,Ovàlïn,ècèlïn,Lin,Linów,Alin,Lináq,Linùto,Linaqí,Linèfù,Linihy,àlin,Linahø,Linïtù,Alinev,álinóm,Délin,ölinàl,ùlinep,àqulin,ámulin,Lín,Lín,Lín,Línø,Línè,Línefy,Línácö,Línify,Elín,álínè,ùlínip,élínec,ölínöv,Màlíní,Jólíni,èkilín,Ubùlín,écelín,íbèlín
Searching for probable string 'lïn' in preprocessed sequence. Time = 0.190013 sec
Lïn,Lïnø,Lïníb,Olïn,Lïnùn,Lïnad,Alïn,Olïn,Lïnïq,Lïnáwo,Lïnöme,Lïnùby,Lïnówö,Lïneco,Lïnødö,Elïnè,élïn,Silïn,àlïní,ölïnö,Jólïn,ölïnis,ùlïniq,Pølïn,Iqilïn,Ovàlïn,Omèlïn,ècèlïn,Lin,Lináq,Alin,Linów,Linïtù,Linahø,àlin,Linihy,Linèfù,Linaqí,Linùto,Alinev,ùlinep,ölinàl,Délin,álinóm,ámulin,àqulin,Lín,Lín,Lín,Línè,Línø,Línify,Línácö,Línefy,Elín,álínè,ölínöv,élínec,ùlínip,Jólíni,Màlíní,écelín,Ubùlín,èkilín,íbèlín
- : unit = ()

RESULT WITH CF_CUSTOM capitalize_casefold:

utop # Search.test_list ();;
Generating random list of 100000 strings. Time = 0.168095 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 1.229276 sec
Preprocessing items from list of 100000 elements. Time = 0.529048 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.193149 sec
Searching for probable string 'lïn' in lazy sequence. Time = 1.223606 sec
Lïn,Lïn,Lïnu,Lïnón,Lïnob,Lïnùná,Lïnobè,Lin,Linù,Liní,Lini,Linimá,Lín,Lín,Línö,Líno,Línï,Línèb,Línùg,Líniz,Línàfe,Líníré,Línazè,Línuge
Searching for probable string 'lïn' in preprocessed sequence. Time = 0.189299 sec
Lïn,Lïn,Lïnu,Lïnob,Lïnón,Lïnobè,Lïnùná,Lin,Lini,Liní,Linù,Linimá,Lín,Lín,Línï,Líno,Línö,Líniz,Línùg,Línèb,Línuge,Línazè,Líníré,Línàfe
- : unit = ()

TODO do the tests again now that we have stabilised the sort.
*)


(*
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

Generating random list of 100000 strings. Time = 0.048076 sec
Searching for nonexistent string 'xxéço' in lazy sequence. Time = 0.107705 sec
Preprocessing items from list of 100000 elements. Time = 0.121095 sec
Searching for nonexistent string 'xxéço' in preprocessed sequence. Time = 0.051155 sec
Searching for probable string 'ïlo' in lazy sequence. Time = 0.108022 sec
Ïlo,Ïlo,Ïlov,Ïloc,Ïlos,Ïlop,Ïlow,Ïloz,Ïlod,Ïlomö,Ïloja,Ïloxyx,Ïlø,Ïlø,Ïló,Ïlö,Ïlö,Ïló,Ïló,Ïlø,Ïlö,Ïlø,Ïlö,Ïlø,Ïló,Ïló,Ïlør,Ïlön,Ïløl,Ïløt,Ïløk,Ïløg,Ïlóbi,Ïløcø,Ïlöwi,Ïlópu,Ïlövi,Ïløky,Ïlómu,Ïlósi,Ïlöfè,Ïlösï,Ïløké,Ïløtó,Ïlösø,Ïlølà,Ïlóqø,Ïlóvé,Ïlówé,Ïlörá,Ïlöqíh,Ïlófíh,Ïløgïr,Ïløkan,Ïlósis,Ilo,Ilo,Ilo,Ilo,Iloc,Ilor,Ilos,Ilozï,Iloho,Ilogó,Ilowí,Iloràr,Ílo,Ílonø,Íloqá,Ílomo,Ílovù,Ílotøx,Ílogàp,Ílopyz,Ilö,Ilø,Iló,Ilö,Ilø,Iló,Ilö,Iló,Ilö,Iló,Iló,Ilóh,Ilød,Ilög,Iløz,Ilób,Ilóva,Ilöha,Ilødá,Ilømo,Ilóhø,Iløde,Ilótèj,Iløwív,Ilögiz,Iløhíz,Ilømáh,Íló,Ílø,Ílö,Ílö,Ílö,Ílö,Ílóp,Ílór,Ílód,Ílög,Íløw,Íløw,Ílób,Íløk,Íløs,Ílóm,Ílöq,Ílöfù,Ílódè,Íløpy,Ílógø,Íløcöx,Ílödíq,Íløjàr,Ílømik,Ílózóh,Íløgím,Íløxàk,Íløbïg,Íløwér
Searching for probable string 'ïlo' in preprocessed sequence. Time = 0.049636 sec
Ïlo,Ïlo,Ïlov,Ïloc,Ïlos,Ïlop,Ïlow,Ïloz,Ïlod,Ïlomö,Ïloja,Ïloxyx,Ïlø,Ïlø,Ïló,Ïlö,Ïlö,Ïló,Ïló,Ïlø,Ïlö,Ïlø,Ïlö,Ïlø,Ïló,Ïló,Ïlør,Ïlön,Ïløl,Ïløt,Ïløk,Ïløg,Ïlóbi,Ïløcø,Ïlöwi,Ïlópu,Ïlövi,Ïløky,Ïlómu,Ïlósi,Ïlöfè,Ïlösï,Ïløké,Ïløtó,Ïlösø,Ïlølà,Ïlóqø,Ïlóvé,Ïlówé,Ïlörá,Ïlöqíh,Ïlófíh,Ïløgïr,Ïløkan,Ïlósis,Ilo,Ilo,Ilo,Ilo,Iloc,Ilor,Ilos,Ilozï,Iloho,Ilogó,Ilowí,Iloràr,Ílo,Ílonø,Íloqá,Ílomo,Ílovù,Ílotøx,Ílogàp,Ílopyz,Ilö,Ilø,Iló,Ilö,Ilø,Iló,Ilö,Iló,Ilö,Iló,Iló,Ilóh,Ilød,Ilög,Iløz,Ilób,Ilóva,Ilöha,Ilødá,Ilømo,Ilóhø,Iløde,Ilótèj,Iløwív,Ilögiz,Iløhíz,Ilømáh,Íló,Ílø,Ílö,Ílö,Ílö,Ílö,Ílóp,Ílór,Ílód,Ílög,Íløw,Íløw,Ílób,Íløk,Íløs,Ílóm,Ílöq,Ílöfù,Ílódè,Íløpy,Ílógø,Íløcöx,Ílödíq,Íløjàr,Ílømik,Ílózóh,Íløgím,Íløxàk,Íløbïg,Íløwér

Test List OK.



*)
