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

-export_type([profunctor/3]).

-type profunctor(_P, _A, _B) :: any().

-callback lmap(fun((A) -> B), P) -> fun((profunctor(P, B, C)) -> profunctor(P, A, C)).
-callback rmap(fun((B) -> C), P) -> fun((profunctor(P, A, B)) -> profunctor(P, A, C)).
-callback dimap((fun((A) -> B)), fun((C) -> D), P) -> fun((profunctor(P, B, C)) -> profunctor(P, A, D)).

-compile({parse_transform, monad_t_transform}).

%% API
-export([dimap/3, lmap/2, rmap/2]).
-export([default_dimap/3, default_lmap/2, default_rmap/2]).

-transform(#{args => [?MODULE], functions => [dimap/2, lmap/1, rmap/1]}).

%%%===================================================================
%%% API
%%%===================================================================

dimap(AB, CD, UProfunctor) ->
    fun(UBC) ->
            undetermined:map(
              fun(Profunctor, PBC) ->
                      (typeclass_trans:apply(dimap, [AB, CD], Profunctor, ?MODULE))(PBC)
              end, UBC, UProfunctor)
      end.

lmap(AB, UProfunctor) ->
    fun(UBC) ->
            undetermined:map(
              fun(Profunctor, PBC) ->
                      (typeclass_trans:apply(lmap, [AB], Profunctor, ?MODULE))(PBC)
              end, UBC, UProfunctor)
    end.

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
