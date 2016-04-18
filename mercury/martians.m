:- module martians.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is cc_multi.

:- implementation.
:- import_module string.

:- type martian ---> ngtrks; pgvdrk.

small(ngtrks). green(ngtrks).
martian(pgvdrk). jumping(pgvdrk).
green(X) :- jumping(X). 
martian(X) :- small(X), jumping(X). 

intelligent(X) :- green(X), martian(X).

main(!IO) :-
  io.write_string("Who is intelligent?\n", !IO),
  (
   if intelligent(X) 
   then io.write(X, !IO) 
   else io.write_string("Cannot determine!", !IO)
  ),
  nl(!IO).

