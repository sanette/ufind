(** Gray Code implementation.

This module offers basic manipulation of integers encoded with the Gray code,
   see https://en.wikipedia.org/wiki/Gray_code *)

type t

val zero : t
(** Element with Gray code equal to zero. *)

val of_int : int -> t
(** [of_int i] is the element whose Gray code is given by the non-negative
   integer [i]. *)

val of_Z: Z.t -> t
(** [of_Z z] is the element whose Gray code is given by the non-negative
   Z-integer [z]. *)

val to_Z : t -> Z.t
(** [to_Z code] is the Z-integer representing the Gray code of [code]. *)

val has_bit : int -> t -> bool
(** [has_bit b code] is true if and only if the Gray code of [code] has a bit
   set at position [b]. (Positions start from 0.) *)

val succ : t -> t
(** Return the successor of the given element. *)

val succ_mod : t -> t * int
(** Return the successor of the given element, together with the position of the
   modified bit in the Gray code. *)

val last : int -> t
(** [last size], where [size>0], is the last element of the given bit size. Its
    code is equal to 2^(size-1). *)

val equal : t -> t -> bool
(** Equality of Gray codes. *)
