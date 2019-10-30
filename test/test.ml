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
  let name = "giap" in
  print_endline (Printf.sprintf "\nSearching for '%s' :" name);
  let items = items_from_names sample in
  let giap = select_data items name in
  List.iter print_endline giap;
  assert (giap = ["Giáp Đông Nghị"]);

  print_endline "\nSearching for 'an' :";
  let an = select_data items "an" in
  List.iter print_endline an;
  assert (List.length an = 14 && List.hd an = "Jana Boj\196\141i\196\135");

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
  let folding = CF_D144 (* CF_CUSTOM capitalize_casefold *) in

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


let test_text () =

  (* https://vi.wikipedia.org/wiki/V%C5%A9_Ng%E1%BB%8Dc_Phan *)
  let text = "Vũ Ngọc Phan sinh ngày 8 tháng 9 năm 1902 tại Hà Nội. Nguyên quán là làng Đông Lão, xã Đông Cửu, huyện Gia Lương, tỉnh Bắc Ninh [1], nay thuộc Hà Nội.

Xuất thân từ một gia đình nhà nho nghèo, thuở nhỏ, ông theo cha đến Hưng Yên và theo học chữ Hán. Từ năm 1920 đến năm 1929, Vũ Ngọc Phan chuyển sang học tiếng Pháp tại Hà Nội, đỗ tú tài Pháp ở tuổi 27.

Song với năng khiếu văn chương và tư tưởng tự do, ông không thích gò mình vào cuộc sống công chức nên đã chọn nghề dạy học tư, viết báo, viết văn và dịch sách.

Từ năm 1929 đến nửa đầu những năm 1940, Vũ Ngọc Phan cộng tác với nhiều tờ báo, tạp chí đương thời như các tờ: Pháp-Việt, Văn học, Nhật Tân, Phổ thông bán nguyệt san, Trung Bắc tân văn, Sông Hương.... Ngoài ra, ông còn từng là Chủ bút tờ Tuần báo Hà Nội tân văn, và là người chủ trương lập Nhà xuất bản Hà Nội.

Vũ Ngọc Phan thời trẻ
Năm 1945, ông tham gia Tổng khởi nghĩa. Cách mạng tháng Tám (1945) thành công, Vũ Ngọc Phan cộng tác với tạp chí Tiên phong của Hội Văn hóa cứu quốc. Lần lượt, ông trải qua các chức vụ sau:

-Phó chủ tịch Đoàn văn nghệ Bắc bộ Việt Nam (tháng 12 năm 1945).
-Tổng thư ký Ủy ban vận động Hội nghị Văn hóa toàn quốc (tháng 11 năm 1946).
-Ủy viên thường trực Đoàn văn hóa kháng chiến liên khu IV (1947-1951).
-Ủy viên Ban nghiên cứu Văn Sử Địa (1951-1953).
Sau kháng chiến chống Pháp (1946-1954), Vũ Ngọc Phan tiếp tục công tác ở Ban Văn Sử Địa. Từ năm 1957, Vũ Ngọc Phan trở thành hội viên của Hội Nhà văn Việt Nam.

Năm 1959, khi Tổ văn học của Ban nghiên cứu Văn Sử Địa tách ra thành lập Viện Văn học, Vũ Ngọc Phan về công tác tại Viện, trở thành tổ trưởng tổ văn học dân gian (nay là phòng văn học dân gian và phòng văn học các dân tộc ít người) của Viện Văn học. Sau đó, Vũ Ngọc Phan được bầu làm Tổng thư ký, phụ trách cơ quan Hội Văn nghệ dân gian tại Đại hội Văn nghệ dân gian lần thứ nhất năm 1966.

Vũ Ngọc Phan mất ngày 14 tháng 6 năm 1987 tại Hà Nội, hưởng thọ 85 tuổi." in

  let items = items_from_text text in
  let pattern = "hán" in
  let result = time_test
      (str "Searching '%s' from text." pattern) (fun () ->
          select_data items pattern) in
  List.iter (fun (i, word) ->
      print_endline (Printf.sprintf "position #%i = %s" i word)) result;

  assert (List.length result = 23 && List.hd result = (307, "Hán"));
  print_endline "\nTest Text OK.\n";;

let test_channel () =

  let cleves = "TOME PREMIER

La magnificence et la galanterie n’ont jamais paru en France avec tant d’éclat que dans les dernières années du règne de Henri second. Ce prince était galant, bien fait et amoureux ; quoique sa passion pour Diane de Poitiers, duchesse de Valentinois, eût commencé il y avait plus de vingt ans, elle n’en était pas moins violente, et il n’en donnait pas des témoignages moins éclatants.

Comme il réussissait admirablement dans tous les exercices du corps, il en faisait une de ses plus grandes occupations. C’étaient tous les jours des parties de chasse et de paume, des ballets, des courses de bagues, ou de semblables divertissements ; les couleurs et les chiffres de Mme de Valentinois paraissaient partout, et elle paraissait elle-même avec tous les ajustements que pouvait avoir Mlle de la Marck, sa petite-fille, qui était alors à marier.

La présence de la reine autorisait la sienne. Cette princesse était belle, quoiqu’elle eût passé la première jeunesse ; elle aimait la grandeur, la magnificence et les plaisirs. Le roi l’avait épousée lorsqu’il était encore duc d’Orléans, et qu’il avait pour aîné le dauphin, qui mourut à Tournon, prince que sa naissance et ses grandes qualités destinaient à remplir dignement la place du roi François premier, son père.

L’humeur ambitieuse de la reine lui faisait trouver une grande douceur à régner ; il semblait qu’elle souffrît sans peine l’attachement du roi pour la duchesse de Valentinois, et elle n’en témoignait aucune jalousie, mais elle avait une si profonde dissimulation qu’il était difficile de juger de ses sentiments, et la politique l’obligeait d’approcher cette duchesse de sa personne, afin d’en approcher aussi le roi." in
  
  let tmp = Filename.temp_file "ufind-test-" ".txt" in
  let outch = open_out tmp in
  (print_endline (Printf.sprintf "Writing file %s." tmp);
   output_string outch cleves;
   close_out outch);
  let file = open_in tmp in
  let items = items_from_channel file in
  let pattern = "ell" in
  let result = time_test
      (str "Searching '%s' from file %s." pattern tmp) (fun () ->
          select_data items pattern) in
  List.iter (fun (i, word) ->
      print_endline (Printf.sprintf "position #%i = %s" i word)) result;
  assert (List.length result = 9 && List.hd (List.rev result) = (962, "quoiqu’elle"));
  print_endline "\nTest Channel OK.\n";;  
  
let () =

  test_simple ();
  test_list ();
  test_text ();
  test_channel ();;
