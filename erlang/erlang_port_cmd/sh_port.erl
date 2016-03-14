%% 
%% 该程序取自：http://blog.csdn.net/zhongruixian/article/details/43083193
%% 使用示例
%% erl -noshell -pa ./ -run sh_port sh "ps ajxf|grep rabbit" -run init stop
%%

-module(sh_port).

-export([sh/1, sh/2]).


%%
%% Options = [Option] -- defaults to [use_stdout, abort_on_error]
%% Option = ErrorOption | OutputOption | {cd, string()} | {env, Env}
%% ErrorOption = return_on_error | abort_on_error | {abort_on_error, string()}
%% OutputOption = use_stdout | {use_stdout, bool()}
%% Env = [{string(), Val}]
%% Val = string() | false
%%
sh(Command) ->
    sh(Command, []).

sh(Command0, Options0) ->
    DefaultOptions = [use_stdout, abort_on_error],
    Options = [expand_sh_flag(V)
               || V <- proplists:compact(Options0 ++ DefaultOptions)],
    ErrorHandler = proplists:get_value(error_handler, Options),
    OutputHandler = proplists:get_value(output_handler, Options),
    Command = patch_on_windows(Command0, proplists:get_value(env, Options, [])),
    PortSettings = proplists:get_all_values(port_settings, Options) ++
        [exit_status, {line, 16384}, use_stdio, stderr_to_stdout, hide],
    Port = open_port({spawn, Command}, PortSettings),
    case sh_loop(Port, OutputHandler, []) of
        {ok, _Output} = Ok ->
            Ok;
        {error, {_Rc, _Output}=Err} ->
            ErrorHandler(Command, Err)
    end.

sh_loop(Port, Fun, Acc) ->
    receive
        {Port, {data, {eol, Line}}} ->
            sh_loop(Port, Fun, Fun(Line ++ "\n", Acc));
        {Port, {data, {noeol, Line}}} ->
            sh_loop(Port, Fun, Fun(Line, Acc));
        {Port, {exit_status, 0}} ->
            {ok, lists:flatten(lists:reverse(Acc))};
        {Port, {exit_status, Rc}} ->
            {error, {Rc, lists:flatten(lists:reverse(Acc))}}
    end.

expand_sh_flag(return_on_error) ->
    {error_handler,
     fun(_Command, Err) ->
             {error, Err}
     end};
expand_sh_flag({abort_on_error, Message}) ->
    {error_handler,
     log_msg_and_abort(Message)};
expand_sh_flag(abort_on_error) ->
    {error_handler,
     fun log_and_abort/2};
expand_sh_flag(use_stdout) ->
    {output_handler,
     fun(Line, Acc) ->
             io:format("~s", [Line]),
             [Line | Acc]
     end};
expand_sh_flag({use_stdout, false}) ->
    {output_handler,
     fun(Line, Acc) ->
             [Line | Acc]
     end};
expand_sh_flag({cd, _CdArg} = Cd) ->
    {port_settings, Cd};
expand_sh_flag({env, _EnvArg} = Env) ->
    {port_settings, Env}.

%% We do the shell variable substitution ourselves on Windows and hope that the
%% command doesn't use any other shell magic.
patch_on_windows(Cmd, Env) ->
    case os:type() of
        {win32,nt} ->
            Cmd1 = "cmd /q /c "
                ++ lists:foldl(fun({Key, Value}, Acc) ->
                                       expand_env_variable(Acc, Key, Value)
                               end, Cmd, Env),
            %% Remove left-over vars
            re:replace(Cmd1, "\\\$\\w+|\\\${\\w+}", "",
                       [global, {return, list}]);
        _ ->
            Cmd
    end.

-type err_handler() :: fun((string(), {integer(), string()}) -> no_return()).
-spec log_msg_and_abort(string()) -> err_handler().
log_msg_and_abort(Message) ->
    fun(_Command, {_Rc, _Output}) ->
            abort(Message, [])
    end.

-spec log_and_abort(string(), {integer(), string()}) -> no_return().
log_and_abort(Command, {Rc, Output}) ->
    abort("sh(~s)~n"
           "failed with return code ~w and the following output:~n"
           "~s~n", [Command, Rc, Output]).

%%
%% Given env. variable FOO we want to expand all references to
%% it in InStr. References can have two forms: $FOO and ${FOO}
%% The end of form $FOO is delimited with whitespace or eol
%%
expand_env_variable(InStr, VarName, RawVarValue) ->
    case string:chr(InStr, $$) of
        0 ->
            %% No variables to expand
            InStr;
        _ ->
            ReOpts = [global, unicode, {return, list}],
            VarValue = re:replace(RawVarValue, "\\\\", "\\\\\\\\", ReOpts),
            %% Use a regex to match/replace:
            %% Given variable "FOO": match $FOO\s | $FOOeol | ${FOO}
            RegEx = io_lib:format("\\\$(~s(\\s|$)|{~s})", [VarName, VarName]),
            re:replace(InStr, RegEx, [VarValue, "\\2"], ReOpts)
    end.

-spec abort() -> no_return().
abort() ->
    throw(rebar_abort).

-spec abort(string(), [term()]) -> no_return().
abort(String, Args) ->
    io:format(String, Args),
    abort().
