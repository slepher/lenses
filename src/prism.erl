%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(prism).

-compile({parse_transform, cut}).
-include_lib("erlando/include/op.hrl").

-include_lib("erlando/include/op.hrl").

%% API
-export([prism/2]).

%%%===================================================================
%%% API
%%%===================================================================
-spec prism(fun((B) -> T), fun((S) -> either:either(T, A))) -> 
                   fun((choice:p(P, A, functor:f(F, B))) -> choice:p(P, S, functor:f(F, T))).
prism(BT, SETA) ->
    %% functor:fmap(BT) :: f b -> f t
    %% applicative:pure(_) :: t -> f t
    %% either:either(applicative:pure(_), functor:fmap(BT)) :: Either t (f b) -> f t
    %% SETA :: s -> Either t a
    %% dimap(SETA, either) :: p (Either t a) (Either t (f b)) -> p s -> f t
    %% right :: p a (f b) -> p (Either t a) (Either t (f b))
    %% final type is p a (f b) -> p s (f t)
    profunctor:dimap(SETA, either:either(applicative:pure(_), functor:fmap(BT, _))) /'.'/ choice:right(_).
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
