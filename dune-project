(lang dune 2.7)
(name ufind)
(version "0.02")
(generate_opam_files true)
(license GPL-3.0-or-later)
(maintainers "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(authors "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(source (github sanette/ufind))

(package
 (name ufind)
 (synopsis "Case-insensitive, accent-insensitive search engine for Latin UTF strings")
 (tags ("utf8"))
 (depends
  (zarith (>= 1.9.1))
   uutf
  (uunf (>= 12.0.0))
  (uucp (>= 12.0.0))
  (ubase (>= 0.01))
  (ocaml (>= 4.14.0))
))
