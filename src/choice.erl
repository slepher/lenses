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

-export_type([choice/3]).

-type choice(_P, _A, _B) :: any().

-callback left(choice(P, A, B), P) -> choice(P, either:either(A, C), either:either(B, C)).
-callback right(choice(P, A, B), P) -> choice(P, either:either(C, A), either:either(C, B)).

-compile({parse_transform, monad_t_transform}).

%% API
-export([left/2, right/2]).
-export([default_left/2, default_right/2]).

-transform(#{args => [?MODULE], functions => [left/1, right/1]}).

%%%===================================================================
%%% API
%%%===================================================================
left(UAB, UChoice) ->
    undetermined:map(
      fun(Choice, PAB) ->
              typeclass_trans:apply(left, [PAB], Choice, ?MODULE)
      end, UAB, UChoice).

right(UAB, UChoice) ->
    undetermined:map(
      fun(Choice, PAB) ->
              typeclass_trans:apply(right, [PAB], Choice, ?MODULE)
      end, UAB, UChoice).

default_left(PAB, Choice) ->
    (profunctor:dimap(either:swap(), either:swap()))(right(PAB, Choice), Choice).

default_right(PAB, Choice) ->
    (profunctor:dimap(either:swap(), either:swap()))(left(PAB, Choice), Choice).

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================
