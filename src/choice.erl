%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(choice).

-callback left(any()) -> any().
-callback right(any()) -> any().

%% API
-export([left/1, right/1]).
-export([default_left/2, default_right/2]).

%%%===================================================================
%%% API
%%%===================================================================

left(UAB) ->
    undetermined:map(
      fun(Module, PAB) ->
              Module:left(PAB)
      end, UAB, ?MODULE).

right(UAB) ->
    undetermined:map(
      fun(Module, PAB) ->
              Module:right(PAB)
      end, UAB, ?MODULE).

default_left(PAB, Module) ->
    (Module:dimap(either:swap(), either:swap()))(Module:right(PAB)).

default_right(PAB, Module) ->
    (Module:dimap(either:swap(), either:swap()))(Module:left(PAB)).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
