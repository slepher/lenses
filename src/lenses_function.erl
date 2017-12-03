%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 23 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(lenses_function).

-erlando_type(function). 

-compile({parse_transform, function_generator}).

-include_lib("erlando/include/op.hrl").

-behaviour(profunctor).
-behaviour(choice).

-define(TYPE, function).

%% API
% profunctor instance
-export([dimap/3, lmap/2, rmap/2]).
% choice instance
-export([left/2, right/2]).

% this generates functions [dimap/2, lmap/1, rmap/1, left/1, right/1].
-gen_fun(#{args => [?TYPE], behaviours => [profunctor, choice]}).

%%%===================================================================
%%% API
%%%===================================================================
-spec dimap((fun((A) -> B)), fun((C) -> D), function) -> fun((fun((B) -> C)) -> fun((A) -> D)).
dimap(AB, CD, ?TYPE) ->
    fun(BC) ->
            CD /'.'/ BC /'.'/ AB
    end.

-spec lmap(fun((A) -> B), function) -> fun((fun((B) -> C)) -> fun((A) -> C)).
lmap(AB, ?TYPE) ->
    fun(BC) ->
         BC /'.'/ AB
    end.

-spec rmap(fun((B) -> C), function) -> fun((fun((A) -> B)) -> fun((A) -> C)).
rmap(BC, ?TYPE) ->
    fun(AB) ->
            BC /'.'/ AB
    end.

-spec left(fun((A) -> B), function) -> fun((either:either(A, C)) -> either:either(B, C)).
left(PAB, ?TYPE) ->
    choice:default_left(PAB, ?TYPE).

-spec right(fun((A) -> B), function) -> fun((either:either(C, A)) -> either:either(C, B)).
right(PAB, ?TYPE) ->
    fun({right, A}) ->
            {right, PAB(A)};
       ({left, C}) ->
            {left, C}
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
