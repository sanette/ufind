(* This file is part of Ufind *)

open Ufind;;

(* Disclaimer: This list of names was randomly generated. *)
let sample =
  [ "Aina Jokimies";
    "Ekaterina Sjeni\196\141i\196\135";
    "Lambert Dahlberg";
    "Juan Sebasti\195\161n Emilio Saucedo Tijerina";
    "Lia Vict\195\179ria Martins Neves";
    "Garron Ruppersberger";
    "Sven-Olov Larsson";
    "Quincy Gutkowski";
    "Thando Banda";
    "Koray Kahveci";
    "\197\160t\196\155p\195\161n Fiala";
    "Amina Cummerata";
    "Agnethe Johannessen";
    "Jana Boj\196\141i\196\135";
    "Elliot Reinger";
    "Ev\196\163enijs Veidenbaums";
    "Adrienne Wohlgemut";
    "David Boucher";
    "Stanojka Ljubi\196\141i\196\135";
    "Jacquelyn Rowe";
    "\196\144ur\196\145evka I\196\141eli\196\135";
    "Valerija Lambi\196\135";
    "Ilona Vav\197\153\195\173k";
    "Zita Neureuther";
    "Olivia Apodaca";
    "Anica Kolenc";
    "Ol\195\161h Milla";
    "Isaac Trujillo";
    "Ana\195\175s Lemieux";
    "Alexandria-C\195\169cile Ferrand";
    "Lukman Saefullah";
    "Ermanis Bendorfs";
    "Ellis Kuswandari";
    "M\196\131d\196\131lin Sava";
    "Silviana Nedelcu";
    "Lotte Hubert";
    "Justin Koster";
    "Gi\195\161p \196\144\195\180ng Ngh\225\187\139";
    "Teagan Jones"]

let consonnants = [| "b"; "c"; "d"; "f"; "g"; "h"; "j"; "k"; "l"; "m"; "n"; "p"; "q"; "r"; "s"; "t"; "v"; "w"; "x"; "z" |];;

let vowels = [| "a"; "à"; "á"; "e"; "é"; "è"; "i"; "ï"; "í"; "o"; "ó"; "ø"; "ö"; "u"; "ù"; "y"|];;

Random.self_init ();;

let random_word n = 
  let n = Random.int (n-3) + 3 in
  let b = Buffer.create n in
  let choose_vowel = Random.bool () in
  let rec loop choose_vowel i =
    if i = 0 then Buffer.contents b
    else
      let letters = if choose_vowel then vowels else consonnants in
      let letter = letters.(Random.int (Array.length letters)) in
      let letter = if i = n then Ufind.capitalize_casefold letter
      (* a big hammer here... *)
        else letter in
      Buffer.add_string b letter;
      loop (not choose_vowel) (i-1) in
  loop choose_vowel n

let rec random_seq n () =
  Seq.Cons (random_word n, random_seq n);;


(* SIMPLE SEARCH *)

let test_simple () =
  print_endline "\nSearching for 'giap' :";
  let items = items_from_names sample in
  let giap = select_data items "giap" in
  List.iter print_endline giap;
  assert (giap = ["Giáp Đông Nghị"]);

  print_endline "\nSearching for 'an' :";
  let an = select_data items "an" in
  List.iter print_endline an;
  assert (List.length an = 14 && List.hd an = "Anica Kolenc");

  print_endline "\nSimple Test OK.\n";;

  
(* SEARCHING FROM A LONG LIST *)

let pr = print_endline;;
let str = Printf.sprintf;;

let time () = Unix.gettimeofday ()
    
let time_test message fn =
  let t = time () in
  let res = fn () in
  print_string message;
  pr (str " Time = %f sec" (time () -. t));
  res
       
let test_list () =
  let size = 100000 in
  let list = time_test
      (str "Generating random list of %u strings." size) (fun () ->
          random_seq 7
          |> seq_truncate 0 size
          |> seq_to_list_rev) in

  (* First we try to search for a nonexistent item *)

  let wrong = "xxéço" in
  let probable = "ïlo" in
  let folding = `CF_D144 (* `CF_CUSTOM capitalize_casefold *) in

  let items = items_from_names ~folding list in
  
  let result = time_test
      (str "Searching for nonexistent string '%s' in lazy sequence." wrong) (fun () ->
          select_data ~folding items wrong) in

  assert (result = []);

  let id x : string = x in
  let pitems = time_test
      (str "Preprocessing items from list of %u elements." size) (fun () ->
          preprocess_list ~folding ~get_name:id ~get_data:id list) in

  let result = time_test
      (str "Searching for nonexistent string '%s' in preprocessed sequence." wrong) (fun () ->
          select_data ~folding pitems wrong) in

  assert (result = []);

  let result1 = time_test
    (str "Searching for probable string '%s' in lazy sequence." probable) (fun () ->
          select_data ~folding items probable) in

    print_endline (String.concat "," result1);

  let result2 = time_test
      (str "Searching for probable string '%s' in preprocessed sequence." probable) (fun () ->
          select_data ~folding pitems probable) in

  print_endline (String.concat "," result2);

  assert (result1 = result2);

  print_endline "\nTest List OK.\n";;


let () =

  test_simple ();
  test_list ();;
