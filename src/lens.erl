%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(lens).

-include_lib("erlando/include/op.hrl").

%% API
-export([lens/2, record/1]).

%%%===================================================================
%%% API
%%%===================================================================
-spec lens(fun((S) -> A), fun((S, B) -> T)) -> fun(( fun((A) -> functor:f(F, B)) ) -> fun((S) -> functor:f(F, T))).
lens(Getter, Setter) ->
    fun(AFB) ->
            fun(S) ->
                    fun(B) -> Setter(S, B) end /'<$>'/ AFB(Getter(S))
            end
    end.

record(Offset) ->
    Getter = fun(R) -> element(Offset, R) end,
    Setter = fun(R, A) -> setelement(Offset, R, A) end,
    lens(Getter, Setter).
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
