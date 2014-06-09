#!/usr/local/bin/swipl -q -t main -f

/* 
to compile and run: swipl -o e_martians -q -t main -c e_martians.pl
then run e_martians
 */

/* 
All jumping creatures are green. All small jumping creatures are martians. All green martians are intelligent. 

Ngtrks is small and green. Pgvdrk is a jumping martian. 

Who is intelligent?
 */

small(ngtrks). green(ngtrks). martian(pgvdrk). jumping(pgvdrk).
green(X) :- jumping(X).
martian(X) :- small(X), jumping(X).
intelligent(X) :- green(X), martian(X).

main :- intelligent(X), format('~w is intelligent.~n', X), halt.
