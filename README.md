# Lenses

Lenses is an erlang porting of haskell library Lens

[lens](http://hackage.haskell.org/package/lens)

just include servial functions currently, the rest will be added later.


## Lens

    type Lens s t a b = forall f. Functor f => (a -> f b) -> (s -> f t)
    lens:lens(s -> a, s -> b -> t) -> Lens s t a b
    
    Lens = lens:lens(fun({_, A}) -> A end, fun({C, _}, B) ->  {C, B} end),
    ?assertEqual(world, getter:view(Lens, {hello, world})),
    ?assertEqual({hello, another_world}, setter:set(Lens, another_world, {hello, world})).
    
## Traversal

    type Traversal s t a b = forall f. Applicative f => (a -> f b) -> (s -> f t)
    traversal:traverse() -> forall t. Traversable t => Traversal (t a) (t b) a b

    Traversal = traversal:traverse(),
    ?assertEqual([2, 4], setter:over(Traversal, fun(A) -> A + 1 end, As)).
    
## ISO

    type Iso s t a b = forall p f. (Profunctor p, Functor f) => p a (f b) -> p s (f t) 
    iso:iso(s -> a, b -> t) -> Iso s t a b
    
    Iso = iso:iso(fun(A) -> identity:run_identity(A) end, fun(A) -> identity:identity(A) end),
    ?assertEqual(3, getter:view(Iso, {identity, 3})),
    ?assertEqual({identity, 1}, setter:set(Iso, 1, {identity, 3})),
    
## Prism

    type Prism s t a b = forall p f. (Choice p, Applicative f) => p a (f b) -> p s (f t)
    prism:prism(b -> t, s -> Either t a) -> Prism s t a b
    
    -include_lib("erlando/include/op.hrl").
    Prism = prism:prism(fun(A) -> {cat, A} end, fun({cat, A}) -> {right, A}; (Other) -> {left, Other} end),
    Traverse = traversa:traverse(),
    Compose = Traverse /'.'/ Prism,
    CatsAndDogs = [{cat, kitty}, {dog, snoopy}, {cat, coffee}],
    ?assertEqual([kitty, coffee], fold:to_list_of(Compose, CatsAndDogs)),
    ?assertEqual([{cat, {my, kitty}}, {dog, snoopy}, {cat, {my, coffee}}],
                  setter:over(Compose, fun(Cat) -> {my, Cat} end, CatsAndDogs)).
    
## Getter

    type Getting r s a = (a -> Const r a) -> (s -> Const r s)
    type Getter s a = forall r. Getting r s a
    getter:view(Getting a s a, s) -> a
    
## Fold

    fold:to_list_of(Getting [a] s a, s) -> a
    
## Setter 

    type Setter s t a b = (a -> Identity b) -> (s -> Identity t)
    setter:over(Setter s t a b, a -> b, s) -> t

## TypeClass & Instances

* function (->) is an instance of Profunctor
* Const r is an instance of Functor
* Identity is an Instance of Functor
* Choice is Profucntor
* Applicative is Functor
* Lens is Getter
* Lens is Traversal
* Traversal is Setter
* Traversal is Fold
* Iso is Lens
* Iso is Prism
* Prism is Traversal
* Getter is Fold
    
## Compose

Lenses could be compose by . because

    (p a (f b) -> p s (f t)) -> (p x (f y) -> p a (f b)) -> (p x (f y) -> p s (f t))

## MakeLenses

    -compile({parse_transform, make_lenses}).
    -record(state, {hello, world}).
    -make_lenses([state, #{module => state}]).
    
generates

    state:hello/0
    state:world/0
    
which represents lenses of #state.hello, #state.world
