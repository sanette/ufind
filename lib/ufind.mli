(** Case insensitive, accent insensitive search engine

    Ufind is a small {{:https://ocaml.org/}ocaml} library that provides a case
   insentitive, accent insensitive search in strings encoded in utf8. It is
   meant to be easy to use, either for searching simple lists, or for digging in
   large databases.

 Thanks to {{:https://sanette.github.io/ubase/}Ubase}, accents and more general
   diacritics are recognized for all Latin characters.  For other
   alphabets/scripts, searching will remain accent sensitive.

{{:https://github.com/sanette/ufind}Source on github}

@version 0.01 *)

(** {1 Examples}

    The simplest search function is {!filter_list}; you can use it for
    searching an arbitrary list with only one line of code:

{[ # let list = [1,"Arthur"; 2,"Benoît"; 3,"Camille"; 4,"Damián"] in
   Ufind.filter_list ~get_name:snd "á" list;;

 - : (int * string) list = [(4, "Dami\195\161n"); (1, "Arthur"); (3, "Camille")] ]}
    Note that the results are sorted by relevance;
    the best match is "Damián" because it has an "á" with the correct accent.

    However, for better speed {e and} memory usage, as soon as you intend
    to do several searches in the same database, we recommend using a
    two-step approach, as in the example below.

    Let us search a substring in a list of strings.
    Here we use the [sample] list of names that can be
    found in the test directory.

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

The string "Olivia Apodaca" came first, because the substring "ap" is
present without any accent substitution. If we searched "áp" instead,
the order of the results would have been inverted.
*)



(** {1 Search filters}

The search can be greatly modified by playing with two filters: {e casefolding}
   and {e matching_defect}.

*)

(** {2 Casefolding}

 The [casefolding] parameter is the function used to perform a {b
   case-insensitive} search. Two strings that have the same image under this
   function will be considered equal (exact match).

    This function is applied only in the preprocess stage, see below.  *)

type casefolding =
  | CF_D144 (** {{:https://unicode.org/versions/Unicode17.0.0/core-spec/chapter-3/#G53513}Unicode Core Spec}. *)
  | CF_D145 (** {{:https://unicode.org/versions/Unicode17.0.0/core-spec/chapter-3/#G53523}Unicode Core Spec}. *)
  | CF_D147 (** {{:https://unicode.org/versions/Unicode17.0.0/core-spec/chapter-3/#G53539}Unicode Core Spec}. *)
  | CF_NONE (** no transformation *)
  | CF_LATIN145 (** D145 restricted to Latin letters *)
  | CF_LATIN147 (** D147 restricted to Latin letters *)
  | CF_ASCII (** ASCII lowercase *)
  | CF_CUSTOM of (string -> string) (** any compatible function -- see below *)
(** For enforcing a {b case-sensitive} search, just use [CF_NONE]. The
   casefolding function can also be used to {e normalize} the utf8 string; this
   is done by [CF_D145] and [CF_D147].  However, recall that normalizing is a
   slow operation, and it should rather be done directly when storing items in
   your database. The expected properties of the casefolding function are:

    - Removing accents (with {!utf8_to_ascii}) followed by casefolding should
   give the same result as casefolding followed by removing accents. The
   resulting string is called the base string. It contains only ASCII
   characters.

    - Applying casefolding on a base string should return the unmodified string.

    - If two items have different base strings, they will never match in any
   search.

    - If two items have the same base string, they should match in any search,
   but maybe we a low ranking (low matching quality).

   Expected property for case-insensitive search:

    - Equality of casefolded ASCII strings should be equivalent to equality of
   the strings obtained by applying [String.lowercase_ascii].

    CUSTOM casefolding functions can be used for specific cases. For instance,
   one can use {!capitalize_casefold}, which combines a usual lower-case
   function with capitalizing the first letter. In this way we force the match
   to happen at the start of the string: "Ver" (or "ver") will match with
   "Véronique" and "VÉRONIQUE" but not with "Prévert" or "PRÉVERT". Of course,
   the same result can be obtained by a simple {!matching_defect} function, see
   below.  *)

val capitalize_casefold : string -> string
(* Standard UTF casefolding (D144) except for the first letter, which is
   capitalized. For most words, this will put everything in lowercase, except
   for the first letter in upper case. *)


(** {2 Matching defect}

Ufind uses a function that establishes the quality of "A being a substring of
   B". It is entirely parameterizable. It should be fast and {e not} deal with
   accents, only raw strings. *)

type matching_defect =
  | MD_EQUAL
  | MD_SUBSTRING
  | MD_CUSTOM of ((string * string) -> (string * string) -> int option)

(**

   - The default matching defect is [MD_SUBSTRING]. For this function, the
   defect increases with the position of the substring A within the string B, and
   with the difference between their respective sizes.

   - [MD_EQUAL] only accepts strict equality of strings. Equal strings have
   zero defect, and non-equal strings have undefined defect.

   - [MD_CUSTOM f] will compute the defect with the function [f], which takes
   two arguments, each one of the form [(name, base)], where [name] is a utf8
   string, and [base] its ASCII version. The function [f] should have the
   following properties:

      [f s1 s2] returns [None] if [s1] is not considered as a substring of [s2]
   (whatever you want it to mean); otherwise

      [f s1 s2] returns [Some d] where the non-negative integer [d] measures the
   defect of [s1] being "close" to [s2]. (The "best match" should return [d=0].)

      [f s1 s2] returns [Some 0] if [s1 = s2].

   A good matching_defect function should primarily compare the "name" components
   of [s1] and [s2]; it does not need to take into account their "base" components.
   However, it must be consistent in the following way:

      If [f (name1, base1) (name2, base2) <> None] then we must have
      [f (base1, "") (base2, "") <> None] as well.

   {e In future versions, we plan to implement functions that accept small
   typing errors, like permutations of two consecutive letters. But right now,
   you need to write your own function for this feature.}  *)

(** {1 Searching}

The Ufind library is meant for searching through a database by filtering a
   string field, typically a name. We use the vocabulary "name" for denoting the
   field in question; but of course, it can be any string field, as long as it
   is UTF8 encoded.

*)

(** {2 Preparing the data}

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
(** [preprocess ~get_name ~get_data seq] returns a sequence of [search_item]s
   from the source sequence [seq].

   This function is a general way of obtaining a sequence of search items from
   any kind of data source, as long as this source can be accessed by a sequence
   (ocaml type [Seq.t]). The function [get_name] takes an element of the
   sequence and should return the name field that we are searching. The function
   [get_data] on an element of the sequence can return any type of data that we
   want to associate with the result of the search. It can be the same as
   [get_name]. But, the data can also be the id of the correspondng record, so
   that from the result of the search on the name field we can recover the other
   fields of the matching records.

   The {!preprocess} function is {e not} lazy; as a consequence, the resulting
   sequence is very fast to search. If [limit=(offset,count)], [preprocess] will
   force evaluation of the first [offset+count] elements of the sequence [seq],
   and return a sequence of at most [count] effectively computed [search_items]
   starting at item #[offset] (inclusive). Warning, if no [limit] is given, the
   whole [seq] is processed; hence if [seq] is infinite, it will never terminate
   until memory overflows.

    In all [preprocess*] functions, the returned sequence is not mutable, has no
   side-effect, and will always point to the start of the source sequence. So
   there is no need to reset it for each new search. *)

val preprocess_list : ?folding:casefolding ->
  get_name:('a -> string) ->
  get_data:('a -> 'b) -> 'a list -> 'b search_item Seq.t
(** Same as {!preprocess} but the database is a list instead of a sequence. *)

val preprocess_file : ?limit:int * int ->
  get_name:(string -> string) ->
  get_data:(string -> 'a) -> string -> 'a search_item Seq.t
(** Use this to search in a file, where each item must be encoded in a single
   line.

The name field should be obtained by [get_name line], and the data field by
   [get_data line]. Returns the sequence of pre-processed search items.  *)

(** The [items_from*] functions below, contrary to the [preprocess*] functions,
   immediately return a lazy sequence of [search_item]s that will be evaluated
   on-the-fly when needed. They may be mutable on not, depending on the nature
   of the source sequence they depend upon.

    If needed, any sequence of [search_item]s can be transformed into a
   preprocessed one by applying {!seq_eval}.  *)


val items_from_seq : ?folding:casefolding ->
  get_name:('a -> string) ->
  get_data:('a -> 'b) -> 'a Seq.t -> 'b search_item Seq.t
(** Similar to {!preprocess} except that there is no preprocessing: this
   immediately returns a lazy sequence of items, suitable for searching.

    If the source sequence is mutable (most sequences are), then for each new
   search, it has to be reset to its origin position, and a new call to
   [items_from_seq] is required.

    If memory allows and if you intend to perform several searches, use
   {!preprocess} for faster searching. *)

val items_from_names : ?folding:casefolding ->
  string list -> string search_item Seq.t
(** [items_from_names list] immediately returns a lazy sequence of search items
   from a list of strings.

    The returned sequence is not mutable, and will always point to the start of
   the list. So there is no need to reset it for each new search.

   For faster searching, rather use [preprocess_list ~get_name:id ~get_data:id
   list], where [id x = x]. The only interest of [items_from_names] is when the
   list is really long and we don't want to duplicate it in memory. *)

val items_from_text : ?folding:casefolding -> string -> (int * string) search_item Seq.t
(** [items_from_text text] immediately constructs a lazy list of search_item
   corresponding to each word of the string [text], where word delimiters are
    [[ \t\n()]]. Usual punctuation signs are removed from the end of words.

    The returned sequence is not mutable, and will always point to the start of
   the text. So there is no need to reset it for each new search.

    After searching with {!select_data}, the resulting data is a list of pairs
   [(pos, word)] where [pos] is the position of the word in the original string.
   *)

val items_from_channel : ?folding:casefolding -> in_channel -> (int * string) search_item Seq.t
(** [items_from_channel channel] immediately constructs a lazy list of
   search_item corresponding to each word read from the [channel], where word
   delimiters are [[ \t\n()]]. Usual punctuation signs are removed from the end
   of words.

    The resulting sequence is mutable, and will point to the current search
   position in the channel, which is not closed by this function.

 After searching with {!select_data}, the resulting data is a list of pairs
   [(pos, word)] where [pos] is the byte position of the word in channel,
   starting from the initial state of the channel.

*)

(** {2 Search results}

*)

val select_data :
  ?folding:casefolding ->
  ?stop:('a search_item -> bool) ->
  ?matching_stop:(int * 'a search_item -> bool) ->
  ?matching_defect:matching_defect -> 'a search_item Seq.t -> string -> 'a list
(** [select_data items name] searches for the string [name] within the sequence
   of search items [items] and returns the sorted list of data corresponding to
   matching items.

   If [stop] is not provided, the search will explore the whole
   sequence. Otherwise, the search will stop after processing the first [item]
   in [items] for which [stop item = true]. The argument [matching_stop]
   operates in a similar way, but is executed only on matching items, and its
   argument is the couple [(distance, item)].

    The [folding] parameter must be the same as the one used to create the
   [items] sequence.

 *)

val make_stop : ?count:int -> ?timeout:float -> unit ->
  ('a -> bool) * (unit -> bool)
(** [make_stop ~count ~timeout ()] returns the pair [(stop, flag)], where [stop]
   is a 'stop' function suitable for use in {!select_data}; and [flag] is a
   function that returns [true] when the stop test is effectively triggered.

    When used with {!select_data}, the search will stop after processing [count]
   elements, or when the [timeout] (in seconds) is elapsed. Note that the timer
   starts as soon at the unit argument [()] is provided.

    The stop function has to be created again after each use.

    In conjunction with {!seq_split}, the [flag] can be used to resume a
    previously stopped search, as follows.

    {[let seq1, seq2 = seq_split items in
      let stop, flag = make_stop ~count:10 () in
      let result = select_data ~stop seq1 name in
    if flag () then begin
      print_endline "The search was interrupted. We resume it.";
      let result2 = select_data seq2 name in
      (* ...now the complete result is the union {result,result2},
            but the global ranking is lost... *)
    end else print_endline "The search was complete."]}

  *)

val filter_list : ?folding:casefolding ->
?matching_defect:matching_defect ->
  get_name:('a -> string) -> string -> 'a list -> 'a list
(** This is the simplest search function; it doesn't require any
   preprocessing. [filter_list ~get_name name list] will filter (and sort by
   relevance) the given [list] by returning only those elements whose name field
   (extracted by [get_name]) matches [name].

Example: {[ # let list = [1,"Arthur"; 2,"Benoît"; 3,"Camille"; 4,"Damián"] in
   filter_list ~get_name:snd "á" list;;

 - : (int * string) list = [(4, "Dami\195\161n"); (1, "Arthur"); (3, "Camille")]
   ]}

    Because the returned list is just a subset of the initial list, one can
    easily refine a search by chaining several calls to [filter_list].  *)

(** Obtaining detailed matching results

    Use this module if {!select_data} is not sufficient for your needs.

For instance, in order to obtain a global ranking of results obtained from
   different searches, use {!find} and {!to_list} instead of {!select_data}.

 *)
module Matching : sig
  type 'a item
  (** Matching item. *)

  val data : 'a item -> 'a
  (** Extract the data from the matching item. *)

  val find : ?folding:casefolding -> matching_defect:matching_defect ->
    'a search_item Seq.t -> string -> 'a item Seq.t
  (** [find sitems name] immediately returns the lazy sequence of {!item}s
      matching the given [name] in the sequence of search items [sitems]. The
      returned sequence may be infinite if [sitems] is infinite.

      The [matching_defect] parameter defines the function used for matching:
      its first entry is (given by) the provided [name].

      Warning: the [folding] parameter must be the same as the one used to
      create the [sitems] sequence. *)

  val to_list : 'a item Seq.t -> 'a item list
  (** Convert the result of [find] to a sorted list. *)

end

(** {1 Utilities} *)

(** {2 Sequences}

Sequences, or "delayed lists" is a standard data type in ocaml, see
   {{:https://caml.inria.fr/pub/docs/manual-ocaml/libref/Seq.html}here}. They
   represent lists where each element is obtained by evaluating some function,
   and the evaluation is "lazy", {e i.e.} is done only when absolutely needed.


    {e (In order to keep the Ufind library compatible with ocaml 4.05, the newer
   [Seq] functions that appeared in 4.07 are not used.)}


*)

val seq_to_list_rev : 'a Seq.t -> 'a list
(** Evaluate the whole sequence and convert it to a list, in reverse order. *)

val list_to_seq : 'a list -> 'a Seq.t
(** Immediately return a lazy sequence from the given list. *)

val seq_eval : 'a Seq.t -> 'a Seq.t
(** Evaluate the whole sequence and return a new sequence with the evaluated
   values. *)

val seq_truncate : int -> int -> 'a Seq.t -> 'a Seq.t
(** (Half)-immediate truncation of a sequence.  [seq_truncate offset count seq]
   returns a sequence of length [count] (or less in case the initial sequence is
   too short) containing the elements of the initial [seq] starting at the
   [offset]-eth element.

   This operation is not entirely lazy: elements before #[offset] will be
   evaluated. But no other element.  *)

val seq_stop : ('a -> bool) -> 'a Seq.t -> 'a Seq.t
(** [seq_stop stop seq] returns a lazy truncation of the sequence [seq]. When
   evaluated, the sequence will stop just after the function [stop] evaluated on
   an element returns true. For instance [stop] can be a timer, see
   {!make_stop}. *)

val seq_split : 'a Seq.t -> 'a Seq.t * 'a Seq.t
(** Dynamic splittig of a sequence. If [s1,s2 = seq_split seq] then [s2] will
   always start after the last evaluated element of [s1].

    For instance if we let [st = seq_truncate 0 10 s1] and iterate on [st], then
   the iteration of [s2] will start at the 11th element of [seq].  *)

(** {2 String conversions}

Shortcuts to some {{:https://sanette.github.io/ubase/}Ubase} functions.
*)

val isolatin_to_utf8 : string -> string
(** Convert ISO_8859_1 to UTF8 *)

val utf8_to_ascii : string -> string
(** Convert to ASCII by removing all accents on Latin letters, and removing all
   other non-ascii chars or non-Latin letters.

    Example:
{[
# utf8_to_ascii "¡Déjà vu!";;
- : string = "Deja vu!"
]} *)

(** {2 Mysql interface}

See {{:https://github.com/sanette/ufind/blob/master/ufind_mysql.md}an example here}.

*)
