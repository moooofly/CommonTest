%% 取自 http://www.cnblogs.com/lulu/p/4149217.html
%% 与系统自动生成的 erl_crash.dump 文件相比内容存在简化
%% Update: 调整了部分内容

-module(crashdump).

-export([crash_dump/0]).


crash_dump() ->
    Date = erlang:list_to_binary(rfc1123_local_date()),
    Slogan = <<"\nSlogan: Snapshot requested by user, not crashdump">>,
    Header = binary:list_to_bin([<<"=erl_crash_dump:0.2\n">>,Date,Slogan,<<"\nSystem version: ">>]),
    Ets = ets_info(),
    Report = binary:list_to_bin([
                                    Header,
                                    erlang:list_to_binary(erlang:system_info(system_version)),
                                    %% 从 =memory 开始的信息
                                    erlang:system_info(info),
                                    %% 从 =proc:<0.0.0> 开始的信息
                                    erlang:system_info(procs),
                                    Ets,
                                    %% 从 =node: xxx 开始的信息
                                    erlang:system_info(dist),
                                    <<"=loaded_modules\n">>,
                                    binary:replace(erlang:system_info(loaded),<<"\n">>,<<"\n=mod:">>,[global])
                                ]),
    file:write_file("erl_crash.dump",Report).

ets_info() ->
    binary:list_to_bin([ets_table_info(T)||T<-ets:all()]).

ets_table_info(TableId) ->
    Info    = ets:info(TableId),
    Owner   = erlang:list_to_binary(erlang:pid_to_list(proplists:get_value(owner,Info))),
    %%TableN  = erlang:list_to_binary(erlang:atom_to_list(TableId)),
    TableN = case TableId of
        _ when is_integer(TableId) -> erlang:list_to_binary(erlang:integer_to_list(TableId));
        _ when is_atom(TableId) -> erlang:list_to_binary(erlang:atom_to_list(TableId))
    end,
    Name    = erlang:list_to_binary(erlang:atom_to_list(proplists:get_value(name,Info))),
    Objects = erlang:list_to_binary(erlang:integer_to_list(proplists:get_value(size,Info))),
    binary:list_to_bin([
                            <<"=ets:">>, Owner,
                            <<"\nTable: ">>, TableN,
                            <<"\nName: ">>, Name,
                            <<"\nObjects: ">>, Objects,
                            <<"\n">>
                        ]).

rfc1123_local_date() ->
    rfc1123_local_date(os:timestamp()).

rfc1123_local_date({A,B,C}) ->
    rfc1123_local_date(calendar:now_to_local_time({A,B,C}));
rfc1123_local_date({{YYYY,MM,DD},{Hour,Min,Sec}}) ->
    DayNumber = calendar:day_of_the_week({YYYY,MM,DD}),
    lists:flatten(
        io_lib:format("~s, ~2.2.0w ~3.s ~4.4.0w ~2.2.0w:~2.2.0w:~2.2.0w GMT",
                      [day(DayNumber),DD,month(MM),YYYY,Hour,Min,Sec]));
rfc1123_local_date(Epoch) when erlang:is_integer(Epoch) ->
    rfc1123_local_date(calendar:gregorian_seconds_to_datetime(Epoch+62167219200)).


%% day

day(1) -> "Mon";
day(2) -> "Tue";
day(3) -> "Wed";
day(4) -> "Thu";
day(5) -> "Fri";
day(6) -> "Sat"; 
day(7) -> "Sun".

%% month

month(1) -> "Jan";
month(2) -> "Feb";
month(3) -> "Mar";
month(4) -> "Apr";
month(5) -> "May";
month(6) -> "Jun";
month(7) -> "Jul";
month(8) -> "Aug";
month(9) -> "Sep";
month(10) -> "Oct";
month(11) -> "Nov";
month(12) -> "Dec".


