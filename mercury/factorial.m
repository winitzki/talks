:- module factorial.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is det.

:- implementation.
:- import_module list.
:- import_module int.

:- pred test_data(list(int)::out).

test_data([1,2,3,4,5,6]).

main(!IO) :-
  % print factorial of 1, 2, 3, 4, 5, 6 using a predicate and using a function.
  io.write_string("Table of factorials computed with the predicate:\n", !IO),
  test_data(Test_data), map(factorial_pred, Test_data, R), io.write(R, !IO),
  io.write_string("\n", !IO),
  io.write_string("Table of factorials computed with the function:\n", !IO),
  R2 = map(factorial_func, Test_data), io.write(R2, !IO),
  io.write_string("\n", !IO).

% Error: invalid determinism for `factorial_bad'(in) = out:
%   the primary mode of a function cannot be `multi'.

% :- func factorial_bad(int) = int.
% factorial_bad(1) = 1.
% factorial_bad(N) = N*factorial_bad(N-1).


:- pred factorial_pred(int::in, int::out) is det.

factorial_pred(N, F) :- ( if N =< 1 then F = 1 else factorial_pred(N-1, G), F = N * G ).

:- func factorial_func(int) = int.

factorial_func(N) = (if N =< 1 then 1 else N*factorial_func(N-1) ).

% Note that factorial_pred and factorial_func will result in the identical compiled code.
