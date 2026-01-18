(lang dune 2.7)
(name ufind)
(version "0.2.0")
(generate_opam_files true)
(license GPL-3.0-or-later)
(maintainers "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(authors "Vu Ngoc San <san.vu-ngoc@laposte.net>")
(source (github sanette/ufind))

(package
 (name ufind)
 (synopsis "Utf8 search engine with parameterized case and accent sensibility")
 (tags ("utf8"))
 (depends
  (zarith (>= 1.9.1))
   uutf
  (uunf (>= 12.0.0))
  (uucp (>= 12.0.0))
  (ubase (>= 0.01))
  (ocaml (>= 4.14.0))
))
