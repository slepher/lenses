%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 20 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(traversal).

%% API
-export([traverse/0]).

%%%===================================================================
%%% API
%%%===================================================================
-spec traverse() -> fun(( fun((_A) -> applicative:f(F, _B)) ) -> fun((_S) -> applicative:f(F, _T))).
traverse() ->
    fun(AFB) ->
            fun(S) ->
                    traversable:traverse(AFB, S)
            end
    end.
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
