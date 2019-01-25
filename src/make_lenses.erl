%%%-------------------------------------------------------------------
%%% @author Chen Slepher <slepheric@gmail.com>
%%% @copyright (C) 2017, Chen Slepher
%%% @doc
%%%
%%% @end
%%% Created :  4 Dec 2017 by Chen Slepher <slepheric@gmail.com>
%%%-------------------------------------------------------------------
-module(make_lenses).

%% API
-export([parse_transform/2]).

%%%===================================================================
%%% API
%%%===================================================================
parse_transform(Forms, Opts) ->
    LensLineRecs = astranaut:attributes_with_line(make_lenses, Forms),
    Records = get_records(Forms),
    NLensLineRecs = 
        lists:foldl(
          fun({Line, [Rec, RecOpts]}, Acc) when is_atom(Rec) ->
                  [{Rec, RecOpts, Line}|Acc];
             ({Line, [Rec]}, Acc) when is_atom(Rec) ->
                  [{Rec, #{}, Line}|Acc];
             (_, Acc) ->
                  Acc
          end, [], LensLineRecs),
    {AllExports, AllFunctions} = 
        lists:foldl(
          fun({Rec, RecOpts, Line}, {ExportsAcc, FunctionsAcc}) ->
                  {Exports, Functions} = lenses_forms(Rec, Records, Line),
                  case maps:find(module, RecOpts) of
                      {ok, Module} ->
                          make_lenses_module(Module, Exports, Functions, Opts),
                          {ExportsAcc, FunctionsAcc};
                      error ->
                          {[Exports|ExportsAcc], Functions ++ FunctionsAcc}
                  end
          end, {[], []}, NLensLineRecs),
    NForms = 
        case {AllExports, AllFunctions} of
            {[], []} ->
                Forms;
            _ ->
                add_to_exports(AllExports ++ AllFunctions, Forms, [])
        end,
    NForms.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================

add_to_exports(AllExports, [{function,_,_,_,_}|_] = Forms, Acc) ->
    lists:reverse(Acc) ++ AllExports ++ Forms;
add_to_exports(AllExports, [{eol, _}] = Forms, Acc) ->
    lists:reverse(Acc) ++ AllExports ++ Forms;
add_to_exports(AllExports, [Form|Forms], Acc) ->
    add_to_exports(AllExports, Forms, [Form|Acc]).
    
make_lenses_module(Module, Exports, Functions, Opts) ->
    case proplists:get_value(outdir, Opts) of
        undefined ->
            ok;
        OutDir ->
            ModuleForm = {attribute, 1, module, Module},
            Forms = [ModuleForm,Exports|Functions],
            {ok, Mod, Bin} = compile:forms(Forms, [debug_info, binary]),
            Filename = filename:join([OutDir, atom_to_list(Mod) ++ ".beam"]),
            ok = file:write_file(Filename, Bin),
            {module, Mod} = code:load_binary(Mod, Filename, Bin)
    end.

lenses_forms(Rec, Records, Line) ->
    case maps:find(Rec, Records) of
        {ok, Fields} ->
            Exports = {attribute,Line,export,
                       lists:flatten(lists:map(fun(Field) -> [{Field, 0}, {Field, 1}, {Field, 2}] end, Fields))},
            Functions = lists:flatten(
                          lists:map(
                            fun(N) ->
                                    [
                                     generate_function(Rec, N, Fields, Line),
                                     generate_getter_function(Rec, N, Fields, Line),
                                     generate_setter_function(Rec, N, Fields, Line)
                                    ]
                            end, lists:seq(1, length(Fields)))),
            {Exports, Functions};
        error ->
            {[], []}
    end.

get_records(Forms) ->
    Recs = astranaut:attributes(record, Forms),
    lists:foldl(
      fun({RecName, Fields}, Acc) ->
              FieldNames = 
                  lists:map(
                    fun(Field) ->
                            field_name(Field)
                    end, Fields),
              maps:put(RecName, FieldNames, Acc)
      end, maps:new(), Recs).

field_name({record_field, _Line1, {atom, _Line2, Field}}) ->
    Field;
field_name({record_field, _Line1, {atom, _Line2, Field}, _Value}) ->
    Field;
field_name({typed_record_field, Field, _T}) ->
    field_name(Field).

generate_getter_function(Record, Offset, Fields, Line) ->
    Name = lists:nth(Offset, Fields),
    {function, Line, Name, 1, getter_clauses(Record, Offset, Fields, Line)}.

generate_setter_function(Record, Offset, Fields, Line) ->
    Name = lists:nth(Offset, Fields),
    {function, Line, Name, 2, setter_clauses(Record, Offset, Fields, Line)}.

generate_function(Record, Offset, Fields, Line) ->
    Name = lists:nth(Offset, Fields),
    {function,Line,Name,0,
     [{clause, Line,
       [], [],
       [{match, Line, {var, Line, 'Getter'}, {'fun', Line, {clauses, getter_clauses(Record, Offset, Fields, Line)}}},
        {match, Line, {var, Line, 'Setter'}, {'fun', Line, {clauses, setter_clauses(Record, Offset, Fields, Line)}}},
        {call,Line,{remote,Line, {atom, Line, lens} , {atom, Line, lens}},[{var, Line, 'Getter'}, {var, Line, 'Setter'}]}
       ]}]}.

getter_clauses(Record, Offset, Fields, Line) ->
    GetterFieldName = lists:nth(Offset, Fields),
    [{clause, Line, 
      [{tuple, Line, 
        [{atom, Line, Record}|
         lists:map(
           fun(N) ->
                   FieldName = lists:nth(N, Fields),
                   NFieldName = 
                       if N == Offset ->
                               normal_field(FieldName);
                          true ->
                               hide_field(FieldName)
                       end,
                   {var, Line, NFieldName}
           end, lists:seq(1, length(Fields)))]
       }],
      [], [{var, Line, normal_field(GetterFieldName)}]}].

setter_clauses(Record, Offset, Fields, Line) ->
    SetterFieldName = lists:nth(Offset, Fields),
    [{clause, Line,
      [{tuple, Line, 
        [{atom, Line, Record}|
         lists:map(
           fun(N) ->
                   FieldName = lists:nth(N, Fields),
                   NFieldName = 
                       if N == Offset ->
                               '_';
                          true ->
                               normal_field(FieldName)
                       end,
                   {var, Line, NFieldName}
           end, lists:seq(1, length(Fields)))]
       }, {var, Line, normal_field(SetterFieldName)}],
      [], [{tuple, Line, 
            [{atom, Line, Record}|
             lists:map(
               fun(N) ->
                       if 
                           N == Offset ->
                               {var, Line, normal_field(SetterFieldName)};
                           true ->
                               FieldName = lists:nth(N, Fields),
                               {var, Line, normal_field(FieldName)}
                       end
               end, lists:seq(1, length(Fields)))]
           }]}].

normal_field(Name) ->
    list_to_atom(camelcase(Name)).

hide_field(Name) ->
    list_to_atom("_" ++ camelcase(Name)).


camelcase(Name) ->
    string:join(
      lists:map(
        fun(Chars) ->
                string:titlecase(Chars)
        end, string:split(atom_to_list(Name), "_", all)), "").
