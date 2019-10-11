(** Case insensitive, accent insensitive search engine

Ufind is a small library that provides a case insentitive, accent insensitive
   search in strings encoded in utf8. It is meant to be easy to use, either for
   searching simple lists, or for digging in large databases.

 Accents are more general diacritics are recognized for all Latin characters.
 For other alphabets, searching will remain accent sensitive.

@version 0.01

@author Vu Ngoc San

*)

(** {2 Example} 

Here [sample] is a list of names that can be found in the test directory.

First we prepare the data:
{[
# let items = Ufind.items_from_names sample;;
val items : string Ufind.search_item Seq.t = <fun>
]}

And then we may search:
{[
# let result = Ufind.select_data items "ap";;
val result : string list =
  ["Olivia Apodaca"; "Gi\195\161p \196\144\195\180ng Ngh\225\187\139"]
# List.iter print_endline result;;
Olivia Apodaca
Giáp Đông Nghị
- : unit = ()                 
]}

*)



(** {2 String transformations}

 The [casefolding] parameter is the function used to perform a {b
   case-insensitive} search. Two strings that have the same image under this
   function will be considered equal (exact match).

*)

type casefolding =
  [ `CF_D144 (** http://unicode.org/versions/latest/ch03.pdf page 157. *)
  | `CF_D145 (** http://unicode.org/versions/latest/ch03.pdf page 158. *)
  | `CF_D147 (** http://unicode.org/versions/latest/ch03.pdf page 158. *)
  | `CF_NONE (** no transformation *)
  | `CF_LATIN144 (** D144 restricted to Latin letters *)
  | `CF_LATIN147 (** D147 restricted to Latin letters *)
  | `CF_ASCII (** ASCII lowercase *)
  | `CF_CUSTOM of (string -> string)
  ]
(** For enforcing a {b case-sensitive} search, just use [`CF_NONE]. The
   casefolding function can also be used to {e normalize} the utf8 string; this
   is done by [`CF_D145] and [`CF_D147].  However, recall that normalizing is a
   slow operation, and it should rather be done directly when storing items in
   your database. The expected properties of the casefolding function are:

    - Removing accents (with Ubase) followed by casefolding should give the same
   result as casefolding followed be removing accents. The resulting string is
   called the base string. It contains only ASCII characters.

    - Applying casefolding on a base string should return the unmodified string.

    - If two items have different base strings, they will never match in any
   search.

    - If two items have the same base string, they should match in any search,
   but maybe we a low ranking (low matching quality).

   Expected property for case-insensitive search:

    - Equality of casefolded ASCII strings should be equivalent to equality of
   the strings obtained by applying [String.lowercase_ascii].

   CUSTOM casefolding functions can be used for specific cases. For instance, a
   useful one, {!capitalize_casefold}, is to combine a usual lower-case
   function with capitalizing the first letter. In this way, "Ver" (or "ver")
   will match with "Véronique" and "VÉRONIQUE" but not with "Prévert" or
   "PRÉVERT".

*)

val capitalize_casefold : string -> string
(* Standard UTF casefolding (D144) except for the first letter, which is
   capitalized. For most words, this will put everything in lowercase, except
   for the first letter in upper case. *)


(** {2 Searching}

The library is meant for searching through a database by filtering a string
   field, typically a name. We use the vocabulary "name" for denoting the field
   in question.

*)

(** {3 Preparing the data}

Before searching, the data has to be preprocessed, in order to transform it into
   a sequence of {!search_item}s. The preprocess can be lazy (will be executed
   only when real search queries will be made), but if memory allows it, it will
   be much faster to preprocess the whole data in memory, especially if you
   intend to perform several searches in the same database.

A search item does not have to contain all the data of the original records, it
   only contains the "name" field and a "data" pointer to recover the original
   data.

*)

type 'a search_item

val base_of_item : 'a search_item -> string
(** Return the ASCII version of the item. *)

val data_of_item : 'a search_item -> 'a
(** Return the data associated with the item. *)

val preprocess : ?folding:casefolding ->
  ?limit:int * int ->
  get_name:('a -> string) ->
  get_data:('a -> 'b) -> 'a Seq.t -> 'b search_item Seq.t
(** [preprocess ~get_name ~get_data seq] is a general way of obtaining a
   sequence of search items from any kind of data source, as long as it can be
   converted into a sequence. The function [get_name] takes an element of the
   sequence and should return the name field that we are searching. The function
   [get_data] on an element of the sequence can return any type of data that we
   want to associate with the result of the search. It can be the same as
   [get_name]. But, the data can also be the id of the correspondng record, so
   that from the result of the search on the name field we can recover the other
   fields of the matching records.

   If [limit=(first,length)], [preprocess] will force evaluation of the first
   [first+length] elements of the sequence [seq], and return a sequence of at
   most [length] effectively computed [search_items] starting at item #[start]
   (inclusive). Warning, if no [limit] is given, the whole [seq] is processed;
   hence if [seq] is infinite, it will never terminate until memory overflow. *)

val preprocess_list : ?folding:casefolding ->
  get_name:('a -> string) ->
  get_data:('a -> 'b) -> 'a list -> 'b search_item Seq.t
(** Same as {!preprocess} but the database is a list instead of a sequence. *)

val preprocess_file : ?limit:int * int ->
  get_name:(string -> string) ->
  get_data:(string -> 'a) -> string -> 'a search_item Seq.t
(** Open a file for searching, where each item must be encoded in a line. The
   name field should be obtained by [get_name line], and the data field by
   [get_data line]. Returns the sequence of pre-processed search items.  *) 

val items_from_seq : ?folding:casefolding ->
  ('a -> string) -> ('a -> 'b) -> 'a Seq.t -> 'b search_item Seq.t
(** Similar to {!preprocess} except that there is no preprocessing: this
   immediately returns a lazy sequence of items, suitable for searching. If
   memory allows and if you intend to perform several searches, use
   {!preprocess} for faster searching. *)

val items_from_names : ?folding:casefolding ->
  string list -> string search_item Seq.t
(** [items_from_names list] returns a lazy sequence of search items from a list
   of strings. For faster searching, rather use [preprocess_list ~get_name:id
   ~get_data:id list], where [id x = x]. The only interest of [items_from_names]
   is when the list is really long and we don't want to duplicate it in
   memory. *)
  
(** {3 Search results}

All search functions operate on a sequence of search_items. 
*)

val select_data : ?folding:casefolding ->
  ?stop:('a search_item -> bool) ->
  ?matching_stop:(int * 'a search_item -> bool) ->
  'a search_item Seq.t -> string -> 'a list
(** [select_data seq name] searches for the string [name] within the sequence of
   search items [seq] and returns the sorted list of data corresponding to
   matching items.  If [stop] is not provided, the search will explore the whole
   sequence. Otherwise, the search will stop when [stop item = true], where
   [item] is the current item in [seq]. The argument [matching_stop] operates in
   a similar way, but is executed only on matching items, and its argument is
    the couple [(distance, item)]. *)

val make_stop : ?length:int -> ?timeout:float -> unit -> 'a -> bool
(** [make_stop ~length ~timeout ()] creates a 'stop' function suitable for use
   in {!select_data}. It will stop after processing [length] elements, or when
   the [timeout] (in seconds) is elapsed. Note that the timer starts as soon at
   the unit argument [()] is provided. *)

(** {2 Utilities for sequences} *)

val seq_to_list_rev : 'a Seq.t -> 'a list
(** Evaluate the whole sequence and convert it to a list, in reverse order. *)

val seq_truncate : int -> int -> 'a Seq.t -> 'a Seq.t
(** (Half)-immediate truncation of a sequence. [seq_truncate start length seq]
   returns a sequence of length [length] (or less in case the initial sequence
   is too short) containing the elements of the initial [seq] starting at the
   [start]-eth element.  This operation is not entirely lazy: elements before
   #[start] will be evaluated. But no other element.  *)
