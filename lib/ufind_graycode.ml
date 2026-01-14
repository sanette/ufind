(* Gray Code implementation *)

(* https://fr.wikipedia.org/wiki/Code_de_Gray *)

(* This file is part of Ufind. But it's an independent module, *)
(* it only depends on Zarith. *)

(* San Vu Ngoc, 2019 *)

type t = {
  indicator : Z.t;
  length : int; (* number of "ones" *)
  last : int (* position du 1 le plus à droite, en numéro de bit (0=le plus à
                droite) *)
  (* [length] and [last] can be deduced from [indicator]. They are stored just
     for speeding up. *)
}

let toggle_bit b int =
  let x = Z.(one lsl b) in
  Z.logxor int x

let has_bit b int =
  Z.testbit int b

let is_even = Z.is_even

let last_one int =
  if Z.equal int Z.zero then -1
  else Z.trailing_zeros int

let length = Z.popcount

let to_Z gray =
  gray.indicator

let of_Z z =
  if Z.sign z = -1  then failwith "Subset Indicator must be non-negative."
  else
    { indicator = z;
      length = length z;
      last = last_one z }

let of_int int =
  if int < 0 then failwith "Subset Indicator must be non-negative."
  else of_Z (Z.of_int int)

let succ_mod gray =
  if gray.length mod 2 = 0
  then
    let i = toggle_bit 0 gray.indicator in
    let last = if is_even i then last_one i else 0 in
    let length = if is_even i then gray.length - 1 else gray.length + 1 in
    { indicator=i; last; length }, 0
  else
    let b = gray.last + 1 in
    let i = toggle_bit b gray.indicator in
    let length = if has_bit b i
      then gray.length + 1 else gray.length - 1 in
    { indicator=i; length; last = gray.last }, b

let succ gray = fst (succ_mod gray)

let zero = { indicator = Z.zero; last = -1; length = 0}

let last size =
  { indicator = if size > 0 then Z.shift_left Z.one (size-1) else Z.zero;
    length = 1;
    last = size-1
  }

let has_bit b gray =
  has_bit b gray.indicator

let equal c1 c2 =
  Z.equal c1.indicator c2.indicator
