%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created : 19 Oct 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(choice).

-superclass([profunctor]).

-export_type([p/3]).

-type p(_P, _A, _B) :: any().

-callback left(choice:p(P, A, B), P) -> choice:p(P, either:either(A, C), either:either(B, C)).
-callback right(choice:p(P, A, B), P) -> choice:p(P, either:either(C, A), either:either(C, B)).

-include_lib("erlando/include/gen_fun.hrl").

%% API
-export([left/2, right/2]).
-export([default_left/2, default_right/2]).

-gen_fun(#{args => [?MODULE], functions => [left/1, right/1]}).

%%%===================================================================
%%% API
%%%===================================================================
-spec left(choice:p(P, A, B), P) -> choice:p(P, either:either(A, C), either:either(B, C)).
left(UAB, UChoice) ->
    undetermined:map(
      fun(Choice, PAB) ->
              typeclass_trans:apply(left, [PAB], Choice, ?MODULE)
      end, UAB, UChoice).

-spec right(choice:p(P, A, B), P) -> choice:p(P, either:either(C, A), either:either(C, B)).
right(UAB, UChoice) ->
    undetermined:map(
      fun(Choice, PAB) ->
              typeclass_trans:apply(right, [PAB], Choice, ?MODULE)
      end, UAB, UChoice).

default_left(PAB, Choice) ->
    (profunctor:dimap(either:swap(), either:swap(), Choice))(right(PAB, Choice)).

default_right(PAB, Choice) ->
    (profunctor:dimap(either:swap(), either:swap(), Choice))(left(PAB, Choice)).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
