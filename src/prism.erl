%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(prism).

-compile({parse_transform, cut}).
-include_lib("erlando/include/op.hrl").

-include_lib("erlando/include/op.hrl").

%% API
-export([prism/2]).

%%%===================================================================
%%% API
%%%===================================================================
prism(BT, SETA) ->
    profunctor:dimap(SETA, either:either(applicative:pure(_), functor:fmap(BT))) /'.'/ choice:right(_).
%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
