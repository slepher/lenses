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

-include_lib("erlando/include/op.hrl").

-behaviour(profunctor).
-behaviour(choice).

-define(TYPE, function).

%% API
% profunctor instance
-export([dimap/3, lmap/2, rmap/2]).
% choice instance
-export([left/2, right/2]).

-transform_behaviour({?MODULE, [], [?TYPE], [profunctor, choice]}).

%%%===================================================================
%%% API
%%%===================================================================
dimap(AB, CD, ?TYPE) ->
    fun(BC) ->
            CD /'.'/ BC /'.'/ AB
    end.

lmap(AB, ?TYPE) ->
    fun(BC) ->
         BC /'.'/ AB
    end.

rmap(BC, ?TYPE) ->
    fun(AB) ->
            BC /'.'/ AB
    end.

right(PAB, ?TYPE) ->
    fun({right, A}) ->
            {right, PAB(A)};
       ({left, C}) ->
            {left, C}
    end.

left(PAB, ?TYPE) ->
    choice:default_left(PAB, ?MODULE).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
