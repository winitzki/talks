:- module typeclasses.
:- interface.
:- import_module io.
:- pred main(io::di, io::uo) is cc_multi.

:- implementation.
:- import_module string.
:- import_module int.
:- import_module list.

main(!IO) :-
  nl(!IO).

% The commented-out lines do not work.

% :- typeclass functor(T, FT) <= (par(T), (T -> FT)) where [ func fmap(func(T)=T) = (func(FT)=FT) ].

% :- typeclass functor1(FT) where [ func fmap1(func(T)=T) = (func(FT)=FT) ].

:- type param(T) ---> t(T).

:- instance par(param(T)) where [ unwrap(t(X)) = X ].

%:- typeclass functor2(T, FT) <= (par(T), (T -> FT)) where [ func fmap(func(T)=T) = (func(FT)=FT) ].

% :- instance functor(param(T), list(T)) where [ fmap(F) = (func(L) = FL :- FL = map(F, L) ) ].

% :- instance functor1(list(T)) where [ fmap1(F) = (func(L) = FL :- FL = map(F, L) ) ].
