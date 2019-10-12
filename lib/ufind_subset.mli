(** Dealing with subsets of a list.

This module can iter all subsets of a given list (considered as a set with
   pairwise distinct elements) without actually store all subsets. This is
   useful because the number of subsets of a list of n elements is 2^n, so can
   quickly grow out of memory.

It internally uses a representation of subsets by binary Gray codes, which is
   particularly efficient for ordering all subsets in a way that {e two
   consecutive subsets differ by only one element}. (That is to say, to obtain
   the next subset, you only need to add or remove one element.)

Example:

{[
let print_subset list = "[" ^ (String.concat "," list) ^ "]" |> print_endline;;
iter print_subset ["1";"2";"3";"4"];;
[]
[1]
[2,1]
[2]
[3,2]
[3,2,1]
[3,1]
[3]
[4,3]
[4,3,1]
[4,3,2,1]
[4,3,2]
[4,2]
[4,2,1]
[4,1]
[4]
- : unit = ()
]}

*)

type 'a t
(** The type for a subset of a list of elements of type ['a]. *)

val empty : 'a list -> 'a t
(** Return the empty set, viewed as a subset of the given list. *)

val full : 'a list -> 'a t
(** Return the maximal subset, i.e. the set containig all elements of the
   given list. *)

val nth : 'a list -> int -> 'a t
(** Return the singleton (subset with only one element) containing the nth
    element of the given list. *)

val to_list : 'a t -> 'a list
(** List representation of the subset. *)

val succ : 'a t -> 'a t
(** Successor of the subset. It is another subset which differs from the
   original by either adding or removing an element. Raises an error if called
   on the last subset. By convention, the successor of the empty set if the
   singleton of the {e last} element of the list. If you want to preserve the
   order of elements of the original list, you should [List.rev] it first. *)

val iter : ('a list -> unit) -> 'a list -> unit
(** [iter_sublists f list] applies the function [f] to all subsets of the given
   [list]; the subsets are given to [f] in the form of lists. Note that [f] is
   always executed at least once, since the empty set is always an element of
   the list of subsets. *)

val fold : ('a -> 'b list -> 'a) -> 'a -> 'b list -> 'a
(** [fold_sublists f x0 list] folds [f] over all subsets of the given [list],
   with initial argument x0.  *)
  
val to_seq : 'a list ->  'a list Seq.t
(** Return a one-time iterator on the subsets of the list. To iterate a second
   time, the sequence must be created again. *)

