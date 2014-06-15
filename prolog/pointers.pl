#!/usr/local/bin/swipl -q -t main -f

/* 
to compile and run: swipl -o e_pointers -q -t main -c e_pointers.pl
then run e_pointers.
 */

/* dlist is [...|A]-A, and an empty dlist is X-X */

:- op(600, xfx, ^^).

plist_truncate(A-B ^^ C-D, A-B).
plist_tail(A-B ^^ C-D, C-D).

plist_at_begin(X-X ^^ A-B).
plist_at_end(A-B ^^ X-X).

plist_incr(A-[X|B] ^^ [X|C]-D, A-B ^^ C-D).

test_dlist1([a,b|X]-X).
test_dlist2([c,d|X]-X).
test_plist(A ^^ B) :- test_dlist1(A), test_dlist2(B).

main :- test_plist(Z), plist_incr(Z, X),
		format('Initial plist: ~w~nAfter incr: ~w~n', [Z, X]),
		halt.
