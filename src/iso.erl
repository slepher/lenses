%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(iso).

-compile({parse_transform, cut}).

-include_lib("erlando/include/op.hrl").

%% API
-export([iso/2]).

%%%===================================================================
%%% API
%%%===================================================================
-spec iso(fun((S) -> A), fun((B) -> T)) -> fun((profunctor:p(P, A, functor:f(F, B))) -> profunctor:p(P, S, functor:f(F, T))).
iso(SA, BT) ->
    %% type of functor:fmap(BT) is f b -> f t
    %% type of SA is s -> a 
    %% so final type is p a (f b) -> p s (f t)
    profunctor:dimap(SA, functor:fmap(BT, _)).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
