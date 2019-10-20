# Using Ufind with a Mysql database

Using `Ufind` for searching in a database is easy, because accessing a
database is naturally well adapted to constructing a sequence
(`Seq.t`); and any sequence can be directly used by `Ufind`.

In this file we give an example with the `mysql` package

```
opam install mysql
```

but adapting to other types of databases should be quite obvious.

## First use the database capabilities

A database is _meant_ for very quick searching in very large sets of
data.  So, the first thing to do is to _narrow your search_ first, by
executing a relevent query. On the other hand, databases are not
always very good at handling Unicode encodings and searching, this is
where `Ufind` enters the picture, but _only as a second step_.

## The world database

For this example, we use the freely available 'world' database

https://downloads.mysql.com/docs/world.sql.gz

Once you have downloaded it, connect to Mysql and insert the file as follows:

```
mysql> SOURCE world.sql;
```

This table has the following structure:

```
mysql> SHOW tables;
+-----------------+
| Tables_in_world |
+-----------------+
| city            |
| country         |
| countrylanguage |
+-----------------+
3 rows in set (0.00 sec)

mysql> SELECT * FROM city LIMIT 5;
+----+----------------+-------------+---------------+------------+
| ID | Name           | CountryCode | District      | Population |
+----+----------------+-------------+---------------+------------+
|  1 | Kabul          | AFG         | Kabol         |    1780000 |
|  2 | Qandahar       | AFG         | Qandahar      |     237500 |
|  3 | Herat          | AFG         | Herat         |     186800 |
|  4 | Mazar-e-Sharif | AFG         | Balkh         |     127800 |
|  5 | Amsterdam      | NLD         | Noord-Holland |     731200 |
+----+----------------+-------------+---------------+------------+
5 rows in set (0.00 sec)
```

## Create a sequence of search items

The `world` function connects to mysql and gives you a handle to the
`world` database.

We want to search in the `city` table. The `world_items` function
returns a sequence of search items, where the search field is the
`Name` of the city, and the data we want to return is a string
including the `Name` field but also the `CountryCode` field, in the
form "City: Paris, Country code: [FRA]".

Note that, like many Mysql databases unfortunately, its uses the
`isolatin` encoding, so we have to convert it to `utf`.


```ocaml
#require "mysql";;
#require "seq";;
#require "ufind";;

open Printf;;
open Mysql;;

let default o x = match o with
  | None -> x
  | Some y -> y
    
let world_items db =
  let res = exec db "SELECT * FROM city" in
  let () = match status db with
    | StatusError _ ->
      print_endline ("Error when processing Mysql query. " ^
                     (default (errmsg db) "?"))
    | StatusOK
    | StatusEmpty -> () in
  let get_name row = (default (column ~key:"Name" ~row res)) "Unknown"
                     |> Ufind.isolatin_to_utf8 in
  let get_code row = default (column ~key:"CountryCode" ~row res) "???" in
  let get_data row = sprintf "City: %s, Country code: [%s]"
      (get_name row) (get_code row) in
  let rec seq () = match fetch res with
    | None -> Seq.empty
    | Some row -> fun () -> Seq.Cons (row, seq ()) in
  Ufind.items_from_seq ~get_name ~get_data (seq ());;
  
let world () =
  quick_connect ~database:"world" ~user:"......." ~password:"......."  ()
```

## Searching

Two possibilies:

1. Each search starts with a Mysql query.

2. We load into memory the list of search items, and then each search
does not rely on the Mysql connection anymore.

```ocaml
 let test () =
  let db = world () in

(* 1. With Mysql queries *)

  print_endline "\nLooking for 'paris' through a Mysql query:";
  let items = world_items db in
  let paris = Ufind.select_data items "paris" in
  List.iter print_endline paris;

  print_endline "\nLooking for 'río' through a Mysql query:";
  let items = world_items db in
  let rio = Ufind.select_data items "río" in
  List.iter print_endline rio;

(* 2A. Preprocessing *)

  print_endline "\nPreprocessing the whole database in memory.";
  let pitems = Ufind.seq_eval (world_items db) in

(* 2B. No Mysql connection required *)

  print_endline "\nLooking for 'paris':";
  let paris = Ufind.select_data pitems "paris" in
  List.iter print_endline paris;

  print_endline "\nLooking for 'río':";
  let rio = Ufind.select_data pitems "río" in
  List.iter print_endline rio;;

```

Here is the result:

```

Looking for 'paris' through a Mysql query:
City: Paris, Country code: [FRA]

Looking for 'río' through a Mysql query:
City: Ríobamba, Country code: [ECU]
City: Río Bravo, Country code: [MEX]
City: Río Cuarto, Country code: [ARG]
City: Boca del Río, Country code: [MEX]
City: Pinar del Río, Country code: [CUB]
City: San Juan del Río, Country code: [MEX]
City: San Luis Río Colorado, Country code: [MEX]
City: Rio Claro, Country code: [BRA]
City: Rio Verde, Country code: [BRA]
City: Morioka, Country code: [JPN]
City: Rio Branco, Country code: [BRA]
City: Rio Grande, Country code: [BRA]
City: Rosario, Country code: [ARG]
City: La Rioja, Country code: [ARG]
City: Ontario, Country code: [USA]
City: Rio de Janeiro, Country code: [BRA]
City: Cabo Frio, Country code: [BRA]
City: Peristerion, Country code: [GRC]
City: São José do Rio Preto, Country code: [BRA]
City: Coacalco de Berriozábal, Country code: [MEX]

Preprocessing the whole database in memory.

Looking for 'paris':
City: Paris, Country code: [FRA]

Looking for 'río':
City: Ríobamba, Country code: [ECU]
City: Río Bravo, Country code: [MEX]
City: Río Cuarto, Country code: [ARG]
City: Boca del Río, Country code: [MEX]
City: Pinar del Río, Country code: [CUB]
City: San Juan del Río, Country code: [MEX]
City: San Luis Río Colorado, Country code: [MEX]
City: Rio Claro, Country code: [BRA]
City: Rio Verde, Country code: [BRA]
City: Morioka, Country code: [JPN]
City: Rio Branco, Country code: [BRA]
City: Rio Grande, Country code: [BRA]
City: Rosario, Country code: [ARG]
City: La Rioja, Country code: [ARG]
City: Ontario, Country code: [USA]
City: Rio de Janeiro, Country code: [BRA]
City: Cabo Frio, Country code: [BRA]
City: Peristerion, Country code: [GRC]
City: São José do Rio Preto, Country code: [BRA]
City: Coacalco de Berriozábal, Country code: [MEX]
- : unit = ()

```
