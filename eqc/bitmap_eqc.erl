%%%-------------------------------------------------------------------
%%% @author Heinz N. Gies <heinz@licenser.net>
%%% @copyright (C) 2016, Heinz N. Gies
%%% @doc
%%%
%%% @end
%%% Created :  5 Dec 2016 by Heinz N. Gies <heinz@licenser.net>
%%%-------------------------------------------------------------------
-module(bitmap_eqc).

-include_lib("eqc/include/eqc.hrl").
-compile(export_all).


%% Ensure that we're 1 or above
size() ->
    ?LET(I, int(), abs(I) + 1).

pos(Size) ->
    choose(0, Size - 1).

prop_size() ->
    ?FORALL(Size, size(),
            begin
                {ok, B} = bitmap:new([{size, Size}]),
                Size =:= bitmap:size(B)
            end).

set(Pos, B0) ->
    {ok, B1} = bitmap:set(Pos, B0),
    B1.

unset(Pos, B0) ->
    {ok, B1} = bitmap:unset(Pos, B0),
    B1.

new(Size) ->
    {ok, B1} = bitmap:new([{size, Size}]),
    B1.

bitmap(Size) ->
    ?SIZED(N, bitmap(N, Size)).

bitmap(0, Size) ->
    new(Size);
bitmap(N, Size) ->
    ?LET({Pos, B1}, {pos(Size), bitmap(N - 1, Size)},
         oneof([
                set(Pos, B1),
                unset(Pos, B1)
               ])).

prop_set() ->
    ?FORALL(
       Size, size(),
       ?FORALL(Pos, pos(Size),
               begin
                   B0 = new(Size),
                   B1 = set(Pos, B0),
                   bitmap:test(Pos, B1)
               end)).

prop_unset() ->
    ?FORALL(
       Size, size(),
       ?FORALL(Pos, pos(Size),
               begin
                   B0 = new(Size),
                   B1 = set(Pos, B0),
                   B2 = unset(Pos, B1),
                   not bitmap:test(Pos, B2)
               end)).



prop_seti() ->
    ?FORALL(
       Size, size(),
       ?FORALL({B, Pos}, {bitmap(Size), pos(Size)},
               begin
                   B1 = set(Pos, B),
                   bitmap:test(Pos, B1)
               end)).

prop_unseti() ->
    ?FORALL(
       Size, size(),
       ?FORALL({B, Pos}, {bitmap(Size), pos(Size)},
               begin
                   B1 = unset(Pos, B),
                   not bitmap:test(Pos, B1)
               end)).


prop_no_diff() ->
    ?FORALL(
       Size, size(),
       ?FORALL(B, bitmap(Size),
               begin
                   bitmap:diff(B, B) =:= {ok, {[], []}}
               end)).

prop_one_diff() ->
    ?FORALL(
       Size, size(),
       ?FORALL({B, Pos}, {bitmap(Size), pos(Size)},
               begin
                   L = set(Pos, B),
                   R = unset(Pos, B),
                   bitmap:diff(L, R) =:= {ok, {[Pos], []}}
               end)).


