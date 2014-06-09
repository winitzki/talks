#!/usr/local/bin/swipl -q -t main -f

/* 
to compile and run: swipl -o e_crocodile -q -t main -c e_crocodile.pl
then run e_crocodile
 */

/* 
All babies are illogical. Nobody is despised who can manage a crocodile. Illogical persons are despised. (Lewis Carroll)
Archibald is a baby. Brian is illogical. Charles can manage a crocodile.
 */

???

main :- baby(X), format('~w is a baby.~n', X), halt.
