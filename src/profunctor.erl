%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(profunctor).

-export_type([profunctor/3]).

%% API
-export([lmap/1, rmap/1, dimap/2]).
-export([default_lmap/2, default_rmap/2, default_dimap/3]).

-type profunctor(_P, _A, _B) :: any().

-callback lmap(fun((A) -> B)) -> fun((profunctor(P, B, C)) -> profunctor(P, A, C)).
-callback rmap(fun((B) -> C)) -> fun((profunctor(P, A, B)) -> profunctor(P, A, C)).
-callback dimap((fun((A) -> B)), fun((C) -> D)) -> fun((profunctor(P, B, C)) -> profunctor(P, A, D)).

%%%===================================================================
%%% API
%%%===================================================================

dimap(AB, CD) ->
    fun(UBC) ->
            undetermined:map(
              fun(Module, PBC) ->
                      (Module:dimap(AB, CD))(PBC)
              end, UBC, ?MODULE)
      end.

lmap(AB) ->
    fun(UBC) ->
            undetermined:map(
              fun(Module, PBC) ->
                      (Module:lmap(AB))(PBC)
              end, UBC, ?MODULE)
    end.

rmap(BC) ->
    fun(UAB) ->
            undetermined:map(
              fun(Module, PAB) ->
                      (Module:rmap(BC))(PAB)
              end, UAB, ?MODULE)
    end.

default_dimap(AB, CD, Module) ->
    Module:lmap(AB) /'.'/ Module:rmap(CD).

default_lmap(AB, Module) ->
    Module:dimap(AB, function_instance:id()).

default_rmap(BC, Module) ->
    Module:dimap(function_instance:id(), BC).


%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
