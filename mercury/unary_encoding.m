:- module unary_encoding.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is cc_multi.

:- implementation.
:- import_module list.
:- import_module int.

:- type unary ---> z; s(unary).

% convert unary to built-in int.
:- pred unary_int(unary, int).
:- mode unary_int(in, out). % is det.
:- mode unary_int(out, in). % is multi.
unary_int(C, N) :- 
( % match on C
  C = z, N = 0 ;
  C = s(B), N = M+1, unary_int(B, M)
% order of goals here depends on mode!
).

main(!IO) :-
  unary_int(s(s(z)), R),
  io.write(R, !IO),
  nl(!IO),
  unary_int(C, 3),
  io.write(C, !IO),
  nl(!IO).
