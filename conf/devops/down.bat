@rem ------------------- batch setting -------------------
@echo off

@rem ------------------- declare variable -------------------

@rem ------------------- execute script -------------------
call :%*
goto end

@rem ------------------- declare function -------------------

:action
    echo ^> Server close down
    IF EXIST %CONF_FILE_PATH% (
        docker-compose -f .\conf\docker\docker-compose.yml --env-file %CONF_FILE_PATH% down
        del %CONF_FILE_PATH%
    )
    goto end

:args
    goto end

:short
    echo Close down Server
    goto end

:help
    echo This is a Command Line Interface with project %PROJECT_NAME%
    echo Close down Server
    echo.
    echo Options:
    echo      --help, -h        Show more information with '%~n0' command.
    call %CLI_SHELL_DIRECTORY%\utils\tools.bat command-description %~n0
    goto end

:end
