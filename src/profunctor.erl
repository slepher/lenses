%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(profunctor).

-superclass([]).

-export_type([p/3]).

-type p(_P, _A, _B) :: any().

-callback dimap((fun((A) -> B)), fun((C) -> D), P) -> fun((profunctor:p(P, B, C)) -> profunctor:p(P, A, D)).
-callback lmap(fun((A) -> B), P) -> fun((profunctor:p(P, B, C)) -> profunctor:p(P, A, C)).
-callback rmap(fun((B) -> C), P) -> fun((profunctor:p(P, A, B)) -> profunctor:p(P, A, C)).

-compile({parse_transform, function_generator}).

%% API
-export([dimap/3, lmap/2, rmap/2]).
-export([default_dimap/3, default_lmap/2, default_rmap/2]).

-gen_fun(#{args => [?MODULE], functions => [dimap/2, lmap/1, rmap/1]}).

%%%===================================================================
%%% API
%%%===================================================================
-spec dimap((fun((A) -> B)), fun((C) -> D), P) -> fun((profunctor:p(P, B, C)) -> profunctor:p(P, A, D)).
dimap(AB, CD, UProfunctor) ->
    fun(UBC) ->
            undetermined:map(
              fun(Profunctor, PBC) ->
                      (typeclass_trans:apply(dimap, [AB, CD], Profunctor, ?MODULE))(PBC)
              end, UBC, UProfunctor)
      end.

-spec lmap(fun((A) -> B), P) -> fun((profunctor:p(P, B, C)) -> profunctor:p(P, A, C)).
lmap(AB, UProfunctor) ->
    fun(UBC) ->
            undetermined:map(
              fun(Profunctor, PBC) ->
                      (typeclass_trans:apply(lmap, [AB], Profunctor, ?MODULE))(PBC)
              end, UBC, UProfunctor)
    end.

-spec rmap(fun((B) -> C), P) -> fun((profunctor:p(P, A, B)) -> profunctor:p(P, A, C)).
rmap(BC, UProfunctor) ->
    fun(UAB) ->
            undetermined:map(
              fun(Profunctor, PAB) ->
                      (typeclass_trans:apply(rmap, [BC], Profunctor, ?MODULE))(PAB)
              end, UAB, UProfunctor)
    end.

default_dimap(AB, CD, Profunctor) ->
    lmap(AB, Profunctor) /'.'/ rmap(CD, Profunctor).

default_lmap(AB, Profunctor) ->
    dimap(AB, function_instance:id(), Profunctor).

default_rmap(BC, Profunctor) ->
    dimap(function_instance:id(), BC, Profunctor).


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
