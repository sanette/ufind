(* Ufind: Searching using Ubase *)

(* This module provides a case insentitive, accent insensitive search in lists
   of strings encoded in utf8. *)

(* Vu Ngoc San, 2019 *)

(* This module depends on Ufind_Subset *)

module Subset = Ufind_subset
  
type replacement =
  | Malformed
  | Uchar 
  | Strip

(* A substitution is a map (a association list) that with an integer (the
   position in the utf stream) associates the replacement of the corresponding
   utf char. *)
type substitution = (int * (replacement * string)) list

let option_map f = function
  | Some x -> Some (f x)
  | None -> None

type casefolding =
  | CF_D144 (* http://unicode.org/versions/latest/ch03.pdf page 157. *)
  | CF_D145 (* http://unicode.org/versions/latest/ch03.pdf page 158. *)
  | CF_D147 (* http://unicode.org/versions/latest/ch03.pdf page 158. *)
  | CF_NONE (* no transformation *)
  | CF_LATIN144 (* D144 restricted to Latin letters *)
  | CF_LATIN147 (* D147 restricted to Latin letters *)
  | CF_ASCII (* ASCII lowercase *)
  | CF_CUSTOM of (string -> string)
;;
(* The casefolding parameter is the function used to perform a case-insensitive
   search. Two strings that have the same image under this function will be
   considered equal (exact match).

   For enforcing a case sensitive search, just use CF_NONE. The casefolding
   function can also be used to _normalize_ the utf8 string; however, recall
   that normalizing is a slow operation, and it should rather be done directly
   when storing items in your database. The expected properties of the
   casefolding function are:

   1. Removing accents (with Ubase) followed by casefolding should give the same
   result as casefolding followed be removing accents. The resulting string is
   called the base string. It contains only ASCII characters.

   2. Applying casefoldind on a base string should return the unmodified string.

   3. If two items have different base strings, they will never match in any
   search.

   4. If two items have the same base string, they should match in any search,
   but maybe we a low ranking (low matching quality).

   Expected property for case-insensitive search:

   5. Equality of casefolded ASCII strings should be equivalent to equality of
   the strings obtained by applying [String.lowercase_ascii].

   CUSTOM casefolding functions can be used for specific cases. For instance, a
   useful one is to combining a usual lower-case function with capitalizing the
   first letter. In this way, "Ver" (or "ver") will match with "Véronique" and
   "VÉRONIQUE" but not with "Prévert" or "PRÉVERT".

 *)

let default_casefolding : casefolding =CF_D144;;
    
(****)
(* This is taken from
   https://erratique.ch/software/uucp/doc/Uucp.Case.html#caselesseq *)

let cf_d145 s =
  let b = Buffer.create (String.length s * 2) in
  let to_nfd_and_utf_8 =
    let n = Uunf.create `NFD in
    let rec add v = match Uunf.add n v with
      | `Await | `End -> ()
      | `Uchar u -> Uutf.Buffer.add_utf_8 b u; add `Await
    in
    add
  in
  let add =
    let n = Uunf.create `NFD in
    let rec add v = match Uunf.add n v with
      | `Await | `End -> ()
      | `Uchar u ->
        begin match Uucp.Case.Fold.fold u with
          | `Self -> to_nfd_and_utf_8 (`Uchar u)
          | `Uchars us -> List.iter (fun u -> to_nfd_and_utf_8 (`Uchar u)) us
        end;
        add `Await
    in
    add
  in
  let add_uchar _ _ = function
    | `Malformed  _ -> add (`Uchar Uutf.u_rep)
    | `Uchar _ as u -> add u
  in
  Uutf.String.fold_utf_8 add_uchar () s;
  add `End;
  to_nfd_and_utf_8 `End;
  Buffer.contents b

let cf_d147 s =
  let b = Buffer.create (String.length s * 3) in
  let n = Uunf.create `NFD in
  let rec add v = match Uunf.add n v with
    | `Await | `End -> ()
    | `Uchar u ->
      begin match Uucp.Case.Nfkc_fold.fold u with
        | `Self -> Uutf.Buffer.add_utf_8 b u; add `Await
        | `Uchars us -> List.iter (Uutf.Buffer.add_utf_8 b) us; add `Await
      end
  in
  let add_uchar _ _ = function
    | `Malformed  _ -> add (`Uchar Uutf.u_rep)
    | `Uchar _ as u -> add u
  in
  Uutf.String.fold_utf_8 add_uchar () s;
  add `End;
  Buffer.contents b

(****)

let cf_d144 s =
  let b = Buffer.create (String.length s * 3) in
  let add_uchar _ _ = function
    | `Malformed  _ -> Uutf.Buffer.add_utf_8 b Uutf.u_rep
    | `Uchar u -> match Uucp.Case.Fold.fold u with
      | `Self -> Uutf.Buffer.add_utf_8 b u
      | `Uchars us -> List.iter (Uutf.Buffer.add_utf_8 b) us
  in
  Uutf.String.fold_utf_8 add_uchar () s;
  Buffer.contents b

let capitalize_casefold s =
  let b = Buffer.create (String.length s * 3) in
  let start = ref true in
  let add_uchar _ _ = function
    | `Malformed  _ -> Uutf.Buffer.add_utf_8 b Uutf.u_rep
    | `Uchar u -> match if !start
        then (start := false; Uucp.Case.Map.to_upper u)
        else Uucp.Case.Fold.fold u with
      | `Self -> Uutf.Buffer.add_utf_8 b u
      | `Uchars us -> List.iter (Uutf.Buffer.add_utf_8 b) us
  in
  Uutf.String.fold_utf_8 add_uchar () s;
  Buffer.contents b

(* let default_casefolding = CF_CUSTOM capitalize_casefold;; *)

let casefolding_fn = function
  | CF_D144 -> cf_d144
  | CF_D145 -> cf_d145
  | CF_D147 -> cf_d147
  | CF_NONE -> fun s : string -> s
  | CF_LATIN144 -> failwith "Not implemented"
  | CF_LATIN147 -> failwith "Not implemented"
  | CF_ASCII -> String.lowercase_ascii
  | CF_CUSTOM f -> f

(* To improve performance, we provide a second casefolding function to use when
   the data is ASCII. It should return the same result as the first casefolding
   function. (This 'optimization' is maybe unnecessary, cf tests). *)
let casefolding_pair folding = match folding with
  | CF_D144
  | CF_D145
  | CF_D147
  | CF_LATIN144
  | CF_LATIN147
  | CF_ASCII -> casefolding_fn folding, casefolding_fn CF_ASCII
  | CF_NONE -> (fun s : string -> s), (fun s : string -> s)
  | CF_CUSTOM f -> f, f

let from_utf8_string_with_subs ?strip s : string * substitution =
  let b = Buffer.create (String.length s) in
  let subs = ref [] in
  let malformed = "?" in
  let folder () pos = function
    | `Malformed _ ->
      Buffer.add_string b malformed;
      subs := (pos, (Malformed, malformed)) :: !subs
    | `Uchar u ->
      try
        let t = Ubase.uchar_to_string u in
        Buffer.add_string b t;
        if Uchar.to_int u > 127
        then subs := (pos, (Uchar, t)) :: !subs
      with Not_found -> match strip with
        | None -> Uutf.Buffer.add_utf_8 b u
        | Some strip ->
          Buffer.add_string b strip;
          subs := (pos, (Strip, strip)) :: !subs
  in
  Uutf.String.fold_utf_8 folder () s;
  Buffer.to_bytes b, !subs;;

(* apply the substitution [subs] to the utf string [s]. *)
let apply_subs subs s =
  let b = Buffer.create (String.length s) in
  let folder () pos char =
    match List.assoc_opt pos subs with
    | Some (_,t) -> Buffer.add_string b t
    | None -> match char with
      | `Malformed m -> Buffer.add_string b m
      | `Uchar u -> Uutf.Buffer.add_utf_8 b u
  in
  Uutf.String.fold_utf_8 folder () s;
  Buffer.to_bytes b;;

(* Preparing data for Searching. *)
(*********************************)

(* For speed, we preassociate to each utf string its base version. *)
type 'a search_item =
  { utf8 : string; (* canonical caseless form of the name record. *)
    base : string; (* lowercase ascii *)
    subs : substitution; (* the substitutions necessary to map utf8 to base. *)
    data : 'a (* used to link to the full record where the name comes from. *) }

let base_of_item item = item.base

let data_of_item item = item.data
                      
let make_item ~folding ~get_name ~get_data x =
  let name = get_name x in
  let data = get_data x in
  let utf_folding, ascii_folding = folding in
  let utf8 = utf_folding name in
  (* [canonical_caseless_key] is responsible for at least 75% of the time *)
  let base, subs = from_utf8_string_with_subs ~strip:"" utf8 in
  let base = ascii_folding base in
  { utf8; base; subs; data }

(* Create a lonely item from a string, with no associated data *)
let item_from_name ~folding name =
   let get_name s = s in
   let get_data _ = () in   
   make_item ~folding ~get_name ~get_data name

(* Testing quality/defect of being a substring *)
(***********************************************)

type matching_defect =
  | MD_EQUAL
  | MD_SUBSTRING
  | MD_CUSTOM of ((string * string) -> (string * string) -> int option)
  (* A defect function need not be symmetric. The first argument is always the
   search pattern and the second is the candidate data. *)

let search_forward_opt reg s pos =
  try Some (Str.search_forward reg s pos) with
  | Not_found -> None


let test_equal (name1,_) (name2,_) =
  if String.equal name1 name2 then Some 0 else None

let find_base ?(test = String.equal) items_seq base =
  Seq.filter (fun p -> test base p.base) items_seq
  
(* The "defect" returned by [test_substring c1 c2] is the position of
   name1 inside name2 + the difference of lengths base2 - base1. *)
(* If name1 is a substring of name2 then base1 is a substring of base2, hence
   this difference is non negative. *)
let test_substring (name1, base1) (name2, base2) =
  let r = Str.regexp_string name1 in
  search_forward_opt r name2 0
  |> option_map (fun i -> i + String.length base2 - String.length base1)

let defect_fn = function
  | MD_EQUAL -> test_equal
  | MD_SUBSTRING -> test_substring
  | MD_CUSTOM f -> f

(* Comuputing the distance in terms of accents substitutions *)
(*************************************************************)
    
(* The first distance is the minimum number of substitutions on item1 and item2
   (we take the sum) required to make them "equal".  It is more efficient if
   item1 has fewer accents than item2. It also returns a pair of matching
   substitutions, and degree of defect of the test (0=perfect match). If [dtest]
   is not the default '=', the 'distance' can be no longer symmetric (as with
   test_substring.) *)
let distance ?(dtest = test_equal) item1 item2 =
  match dtest (item1.utf8, item1.base) (item2.utf8, item2.base) with
  | Some defect -> 0, Some ([], [], defect)
  | None ->
    (* We cannot stop at the first match, because unfortunately the Gray code we
       use is not monotonous. A match at step n does not implies that there
       cannot be a simpler match at a later step. *)
    (* Remark: instead of two loops, we could fold over the cartesian product
       (assuming we construct a cartesian product iterator). *)
    let rec loop2 name1 seq2 (dist, subs, defect) =
      match seq2 () with
      | Seq.Nil -> dist, subs, defect
      (* dist = distance between name1 and seq2. *)
      | Seq.Cons (subs2, next) ->
        let result =
          let d2 = List.length subs2 in
          if d2 >= dist (* then we don't need to test this. *)
          then dist, subs, defect
          else let name2 = apply_subs subs2 item2.utf8 in
            match dtest (name1, item1.base) (name2, item2.base) with
            | Some defect -> d2, Some subs2, defect
            | None -> dist, subs, defect in
        loop2 name1 next result in
    let rec loop1 seq1 dist subs_pair =
      match seq1 () with
      | Seq.Nil -> dist, subs_pair
      (* dist = total distance (sum) between seq1 and seq2 *)
      | Seq.Cons (subs1, next) ->
        let dist, subs_pair = 
          let d1 = List.length subs1 in
          if d1 >= dist then dist, subs_pair
          else let name1 =  apply_subs subs1 item1.utf8 in
            let seq2 = Subset.to_seq item2.subs in
            let d2, s2, defect = loop2 name1 seq2 (dist, None, -1) in
            min dist (d1 + d2), match s2 with
            | None -> subs_pair
            | Some subs2 -> Some (subs1, subs2, defect) in
        loop1 next dist subs_pair in
    let seq1 = Subset.to_seq item1.subs in
    loop1 seq1 (String.length item1.utf8) None

(* Returns the lazy sequence of matching items using the [dtest] comparison
   whose first entry is (given by) the provided [name]. Can be infinite.  The
   [folding] parameter must be the same as the one used to create the
   [items_seq] sequence. TODO combine them in a data structure. *)
let find_name ?(folding = default_casefolding) ?(dtest = test_substring)
    items_seq name =
  let folding = casefolding_pair folding in
  let item = item_from_name ~folding name in
  (* We first reduce the search to the list of matching base items *)
  let test s1 s2 = dtest (s1,"") (s2,"") <> None in
  let reduce = find_base ~test items_seq item.base in
  (* We iterate all items in reduce: *)
  Seq.map (fun it ->
      let d, subs_pair = distance ~dtest item it in
      match subs_pair with
      | None -> failwith "Probaly a wrong casefolding function."
      (* Not found, this should not happen since the bases are the same. *)
      | Some pair -> (d, it, pair)
    ) reduce;;

(* Evaluate the whole sequence and convert it to a list. *)
let seq_to_list_rev seq =
  Seq.fold_left (fun list x -> x::list) [] seq

(* This function is lazy and returns immediately (no loop) *)
let rec list_to_seq = function
  | [] -> Seq.empty
  | x::rest -> fun () -> Seq.Cons (x, list_to_seq rest)
    
(* Convert the result of [find_name] to a sorted list. *)
let get_result_list seq =
  seq_to_list_rev seq
  |> List.stable_sort (fun (dis1,_,def1) (dis2,_,def2) ->
      match compare dis1 dis2 with
      | 0 -> compare def1 def2
      | d -> d)

(* Returns the sequence starting at the nth element (starting from n=0), or the
   empty sequence if the sequence is not long enough. NOT lazy: the elements
   before the nth element are immediately evaluated. *)
let rec seq_skip n seq =
  if n <= 0 then seq
  else match seq () with
    | Seq.Nil -> Seq.empty
    | Seq.Cons (_, next) -> seq_skip (n-1) next
                              
(* (Half)-immediate truncation of a sequence (not lazy: element before #start
   will be evaluated. But no other element.) The number of items in the returned
   sequence can be less than length in case the initial sequence is too
   short. *)
let seq_truncate start length seq =
  let seq = seq_skip start seq in
  let rec loop i seq () =
    if i >= length then Seq.Nil
    else match seq () with
        | Seq.Nil -> Seq.Nil
        | Seq.Cons (x, next) -> Seq.Cons (x, loop (i+1) next)
  in
    loop 0 seq

(* Lazy truncation of the sequence. When evaluated, the sequence will stop just
   after the function [stop] evaluated on an element returns true. For instance
   [stop] can be a timer. *)
let rec seq_stop stop seq () =
  match seq () with
  | Seq.Nil -> Seq.Nil
  | Seq.Cons (x, next) -> let next = if stop x then Seq.empty else next in
    Seq.Cons (x, seq_stop stop next)

let seq_split seq =
  let seq2 = ref seq in
  let rec loop seq () =
    match seq () with
    | Seq.Nil -> Seq.Nil
    | Seq.Cons (x, next) -> seq2:=next; Seq.Cons (x, loop next) in
  loop seq, fun () -> !seq2 ()

(* In order to test sequences and side-effects, it is useful to consider a sequence like this:

let seq = list_to_seq ["1";"2";"3";"4";"5"];;
let seq_test = Seq.map (fun s -> print_endline ("Reading: " ^s); s) seq;;

For instance we can check that seq_truncate evaluates only "start" elements:
# let s1 = seq_truncate 1 2 seq_test;;
Reading: 1
val s1 : string Seq.t = <fun>
# Seq.iter print_endline s1;;
Reading: 2
2
Reading: 3
3
- : unit = ()
# 

   We now chek the funny behaviour of seq_split:

# let s1,s2 = seq_split seq_test;;
val s1 : string Seq.t = <fun>
val s2 : unit -> string Seq.node = <fun>

The rule is "s2 always start just after the last execution of s1":

# Seq.iter print_endline s2;;
Reading: 1
1
Reading: 2
2
Reading: 3
3
Reading: 4
4
Reading: 5
5
- : unit = ()
# Seq.iter print_endline s1;;
Reading: 1
1
Reading: 2
2
Reading: 3
3
Reading: 4
4
Reading: 5
5
- : unit = ()
# Seq.iter print_endline s2;;
- : unit = ()

   Now with truncation of s1:

#  let s1t = seq_truncate 1 2 s1;;
Reading: 1
val s1t : string Seq.t = <fun>
# Seq.iter print_endline s1t;;
Reading: 2
2
Reading: 3
3
- : unit = ()
# Seq.iter print_endline s2;;
Reading: 4
4
Reading: 5
5
- : unit = ()

Now with stop:

# let s1,s2 = seq_split seq_test;;
val s1 : string Seq.t = <fun>
val s2 : unit -> string Seq.node = <fun>
# let stop = make_stop ~count:2 ();;
val stop : '_a -> bool = <fun>
# let ss = seq_stop stop s1;;
val ss : string Seq.t = <fun>
# Seq.iter print_endline ss;;
Reading: 1
1
Reading: 2
2
- : unit = ()
# Seq.iter print_endline s2;;
Reading: 3
3
Reading: 4
4
Reading: 5
5
- : unit = ()
# 
*)


(* Search the string [name] within the sequence of search items [seq] and
   returns the sorted list of data corresponding to matching items.  If [stop]
   is not provided, the search will explore the whole sequence. Otherwise, the
   search will stop when [stop item = true], where [item] is the current item in
   [seq]. The argument [matching_stop] operates in a similar way, but is
   executed only on matching items, and it has two arguments: [(distance,
   item)]. *)
let select_data ?(folding = default_casefolding) ?stop ?matching_stop
    ?(matching_defect : matching_defect = MD_SUBSTRING) seq name =
  let seq = match stop with
    | None -> seq
    | Some stop -> seq_stop stop seq in
  let dtest = defect_fn matching_defect in
  let matching = find_name ~folding ~dtest seq name in
  let matching = match matching_stop with
    | None -> matching
    | Some stop ->
      let stop (d,item,_) = stop (d, item) in
      seq_stop stop matching in
  get_result_list matching
  |> List.map (fun (_,item,_) -> item.data)


(* If [limit=(offset,count)], [preprocess] will force evaluation of the first
   [offset+count] elements of the sequence [seq], and return a sequence of at
   most [count] effectively computed [search_items] starting at item #[offset]
   (inclusive). Warning, if no [limit] is given, the whole [seq] is processed;
   hence if [seq] is infinite, it will never terminate until memory overflow. *)
let rec preprocess ?(folding = default_casefolding) ?limit
    ~get_name ~get_data seq =
  match limit with
  | None ->
    let folding = casefolding_pair folding in
    Seq.fold_left (fun list x ->
        (make_item ~folding ~get_name ~get_data x) :: list) [] seq
    |> List.rev
    |> list_to_seq
  | Some (offset, count) ->
    seq_truncate offset count seq
    |> preprocess ~folding ~get_name ~get_data 

(* Use [preprocess] or [preprocess_list] to accelerate several searches in the
   same database. *)
let preprocess_list ?(folding = default_casefolding) ~get_name ~get_data list =
  let folding = casefolding_pair folding in
  List.rev_map (make_item ~folding ~get_name ~get_data) list
  |> List.rev
  |> list_to_seq

(* Create a lazy item sequence from any type of sequence. See [preprocess]. *)
let items_from_seq ?(folding = default_casefolding) ~get_name ~get_data seq =
  let folding = casefolding_pair folding in  
  Seq.map (make_item ~folding ~get_name ~get_data) seq
  
(* [items_from_names list] returns a lazy sequence of search items from a list
   of strings. For faster searching, rather use [preprocess_list id_string
   id_string list], where [id_string x = x]. The only interest of
   [items_from_names] is when the list is really long and we don't want to
   duplicate it in memory. *)
let items_from_names ?(folding = default_casefolding) list =
  let folding = casefolding_pair folding in
  let id_string x = x in
  list_to_seq list
  |> Seq.map (make_item ~folding ~get_name:id_string ~get_data:id_string)
(* WARNING, the function [make_item] will be executed at each iteration of the
   sequence. So if the sequence is searched several times, this is not
   efficient.  *)
(* It makes a real difference: right now for a list of 1000000 small strings,
   searching an inexistent pattern of two chars takes 13sec (bytecode), while
   for a preprocessed *list* it takes 1,7sec. (Moreover [preprocess_list] only
   takes 5,6 sec.) *)


(* After using this sequence for searching part of the file, a consecutive
   search will only look at the remaining part of the file. In order to search
   again in the same file, the channel has to be closed, and the sequence has to
   be created again. *)
let rec channel_to_seq channel () =
  try Seq.Cons (input_line channel, channel_to_seq channel) with
    | End_of_file -> Seq.Nil

(* Open a file for searching, where each item must be encoded in a line. The
   name field should be obtained by [get_name line], and the data field by
   [get_data line]. Returns the sequence of pre-processed search items.  *)
let preprocess_file ?limit ~get_name ~get_data file =
  let channel = open_in file in
  let items = channel_to_seq channel
              |> preprocess ?limit ~get_name ~get_data in
  close_in channel;
  items

let make_stop ?count ?timeout () =
  let i = ref 0 in
  let t = Unix.gettimeofday () in
  fun _ -> incr i;
    (match count with
    | Some count -> !i >= count
    | None -> false) ||
    match timeout with
    | Some timeout -> Unix.gettimeofday () -. t >= timeout
    | None -> false
  

(** String conversion utilities from Ubase *)

let isolatin_to_utf8 = Ubase.isolatin_to_utf8

let utf8_to_base = Ubase.from_utf8_string ~malformed:"?" ~strip:""
