(* Dealing with subsets of a list *)

(* This file is part of Ubase. But it's an independent module, *)
(* it only depends on Graycode (included in Ubase). *)

(* San Vu Ngoc, 2019 *)

module Graycode = Ufind_graycode
  
(* array est le tableau contenant tous les éléments potentiels, et code "encode"
   les éléments selectionnés dans le subset, en binaire (1 en position i => le
   array.(i) est présent dans le subset.) *)
type 'a t = { array : 'a array; code : Graycode.t }

(* Retourne l'ensemble vide comme sous-ensemble de list *)
let empty list = { array = Array.of_list list; code = Graycode.zero }
                 
(* Retourne l'ensemble défini par list au complet. *)
let full list =
  let array = Array.of_list list in
  let code = Graycode.of_int (1 lsl (Array.length array) - 1) in
  { array; code }

(* Retourne le singleton contenant le ième élément de la liste. *)
let nth list i =
  { array = Array.of_list list;
    code = Graycode.of_int (1 lsl i) }

(* Retourne le subset sous forme de liste *)
let to_list subset =
  let rec loop i list =
    if i = -1 then list
    else let list' =
           if Graycode.has_bit i subset.code
           then subset.array.(i)::list
           else list in
      loop (i-1) list' in
  loop (Array.length subset.array) []

(* Retourne le subset sous forme de tableau d'options *)
(* let to_array subset =
 *   Array.init (Array.length subset.array) (fun i ->
 *       if Graycode.has_bit i subset.code
 *       then Some subset.array.(i) else None) *)

(* succ subset is the subset whose code is Graycode.succ code.  Raise:
   Invalid_argument "index out of bounds" if subset = last (=last singleton)
   Warning, the resulting subset shares the same array as the original
   subset. *)
let succ subset =
  {subset with code = Graycode.succ subset.code}

(* This version does not allocate new array, it only modifies the opt_array,
   taking advantage that the next gray code has only one different bit. *)
let succ_inplace full_array opt_array code  =
  let code, b = Graycode.succ_mod code in
  let () = if Graycode.has_bit b code
    then opt_array.(b) <- Some full_array.(b)
    else opt_array.(b) <- None in
  code
    
(* Note that f is always executed at least once, because the empty set belongs
   the the power set. *)
let iter_powerset f list =
  let subset = empty list in
  let opt_array = Array.make (Array.length subset.array) None in
  let last_code = Graycode.last (Array.length subset.array) in
  let rec loop code =
    f opt_array;
    if not (Graycode.equal code last_code)
    then loop (succ_inplace subset.array opt_array code)
  in
  loop subset.code

(* Note that f is always applied at least once, because the empty set belongs
   the the power set. *)
let fold_powerset f x0 list =
  let subset = empty list in
  let opt_array = Array.make (Array.length subset.array) None in
  let last_code = Graycode.last (Array.length subset.array) in
  let rec loop x code =
    if Graycode.equal code last_code
    then f x opt_array 
    else loop (f x opt_array) (succ_inplace subset.array opt_array code)
  in
  loop x0 subset.code

let opt_array_to_list a =
  Array.fold_left (fun list -> function
      | None -> list
      | Some x -> x::list) [] a

(* Create an iterator on the list of sublists. *)
(* WARNING this Seq is mutable, should be traversed only once. *)
let to_seq list =
  let subset = empty list in
  let opt_array = Array.make (Array.length subset.array) None in
  let last_code = Graycode.last (Array.length subset.array) in
  let rec make_next code () =
    if Graycode.equal code last_code
    then Seq.Nil
    else let code'= succ_inplace subset.array opt_array code in
      Seq.Cons (opt_array_to_list opt_array, make_next code')
  in
  fun () -> Seq.Cons ([], make_next subset.code)

(* This should be the same as [Seq.iter f (to_seq list)]. (Probably) less
   efficient than [iter_powerset] because we have to create a sublist at each
   step. *)
let iter f list =
  let g a = f (opt_array_to_list a) in
  iter_powerset g list

let fold f x list =
  let g y a = f y (opt_array_to_list a) in
  fold_powerset g x list
    
(* let print_opt_array array =
 *   array
 *   |> Array.to_list
 *   |> List.filter (fun o -> o <> None)
 *   |> List.map (function | Some x -> x | None -> "")
 *   |> String.concat ","
 *   |> (fun s -> "[" ^ s ^"]")
 *   |> print_endline *)

(*
# Subset.iter_powerset print_opt_array ["1";"2";"3";"4"];;
[]
[1]
[1,2]
[2]
[2,3]
[1,2,3]
[1,3]
[3]
[3,4]
[1,3,4]
[1,2,3,4]
[2,3,4]
[2,4]
[1,2,4]
[1,4]
[4]
- : unit = ()
# 
*)
