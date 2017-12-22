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
    case proplists:get_value(outdir, Opts) of
        undefined ->
            Forms;
        OutDir ->
            LensRecs = ast_traverse:attributes(make_lenses, Forms),
            Records = get_records(Forms),
            NLensRecs = 
                lists:foldl(
                  fun([Rec, RecOpts], Acc) when is_atom(Rec) ->
                          [{Rec, RecOpts}|Acc];
                     ([Rec], Acc) when is_atom(Rec) ->
                          [{Rec, #{}}|Acc];
                     (_, Acc) ->
                          Acc
                  end, [], LensRecs),
            lists:foldl(
              fun({Rec, RecOpts}, FormsAcc) ->
                      make_lenses(Rec, RecOpts, Records, FormsAcc, OutDir)
              end, Forms, NLensRecs)
    end.

%%--------------------------------------------------------------------
%% @doc
%% @spec
%% @end
%%--------------------------------------------------------------------

%%%===================================================================
%%% Internal functions
%%%===================================================================

make_lenses(Rec, RecOpts, Records, FormsAcc, OutDir) ->
    case maps:find(Rec, Records) of
        {ok, Fields} ->
            Module = maps:get(module, RecOpts, Rec),
            Functions = lists:map(
                          fun(N) ->
                                  generate_function(Rec, N, Fields, N + 2)
                          end, lists:seq(1, length(Fields))),
            Exports = {attribute, 2, export, lists:map(fun(Field) -> {Field, 0} end, Fields)},
            ModuleForm = {attribute,1,module,Module},
            Forms = [ModuleForm,Exports|Functions],
            {ok, Mod, Bin} = compile:forms(Forms, [debug_info, binary]),
            Filename = filename:join([OutDir, atom_to_list(Mod) ++ ".beam"]),
            ok = file:write_file(Filename, Bin),
            {module, Mod} = code:load_binary(Mod, Filename, Bin),
            FormsAcc;
        error ->
            FormsAcc
    end.

get_records(Forms) ->    
    Recs = ast_traverse:attributes(record, Forms),
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

generate_function(Record, Offset, Fields, Line) ->
    Name = lists:nth(Offset, Fields),
    {function,Line,Name,0,
     [{clause, Line,
       [], [],
       [{match, Line, {var, Line, 'Getter'}, make_getter(Record, Offset, Fields, Line)},
        {match, Line, {var, Line, 'Setter'}, make_setter(Record, Offset, Fields, Line)},
        {call,Line,{remote,Line, {atom, Line, lens} , {atom, Line, lens}},[{var, Line, 'Getter'}, {var, Line, 'Setter'}]}
       ]}]}.

make_getter(Record, Offset, Fields, Line) ->
    {'fun', Line, 
     {clauses,
      [{clause, Line, 
        [{tuple, Line, 
          [{atom, Line, Record}|
           lists:map(
             fun(N) ->
                     FieldName = lists:nth(N, Fields),
                     NFieldName = 
                         if N == Offset ->
                                 FieldName;
                            true ->
                                 hide_field(FieldName)
                         end,
                     {var, Line, NFieldName}
             end, lists:seq(1, length(Fields)))]
          }],
        [], [{var, Line, lists:nth(Offset, Fields)}]}]
     }}.

make_setter(Record, Offset, Fields, Line) ->
    {'fun', Line, 
     {clauses, 
      [{clause, Line,
        [{tuple, Line, 
          [{atom, Line, Record}|
           lists:map(
             fun(N) ->
                     FieldName = lists:nth(N, Fields),
                     NFieldName = 
                         if N == Offset ->
                                 hide_field(FieldName);
                            true ->
                                 FieldName
                         end,
                     {var, Line, NFieldName}
             end, lists:seq(1, length(Fields)))]
          }, {var, Line, 'Value'}],
        [], [{tuple, Line, 
              [{atom, Line, Record}|
               lists:map(
                 fun(N) ->
                         if 
                             N == Offset ->
                                 {var, Line, 'Value'};
                             true ->
                                 FieldName = lists:nth(N, Fields),
                                 {var, Line, FieldName}
                         end
                 end, lists:seq(1, length(Fields)))]
             }]}]
     }}.

hide_field(Name) ->
    list_to_atom("_" ++ atom_to_list(Name)).
