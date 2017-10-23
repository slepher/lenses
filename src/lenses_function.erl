%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 23 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(lenses_function).

-include_lib("erlando/include/op.hrl").

-behaviour(type).
-behaviour(profunctor).
-behaviour(choice).

%% API
-export([type/0]).
% profunctor instance
-export([lmap/1, rmap/1, dimap/2]).
% choice instance
-export([left/1, right/1]).
%%%===================================================================
%%% API
%%%===================================================================
type() ->
    function.

dimap(AB, CD) ->
    fun(BC) ->
            CD /'.'/ BC /'.'/ AB
    end.

lmap(AB) ->
    fun(BC) ->
         BC /'.'/ AB
    end.

rmap(BC) ->
    fun(AB) ->
            BC /'.'/ AB
    end.

right(PAB) ->
    fun({right, A}) ->
            {right, PAB(A)};
       ({left, C}) ->
            {left, C}
    end.

left(PAB) ->
    choice:default_left(PAB, ?MODULE).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
