module BackendTask.Env exposing
    ( get, expect
    , Error(..)
    )

{-| Because BackendTask's in `elm-pages` never run in the browser (see [the BackendTask docs](BackendTask)), you can access environment variables securely. As long as the environment variable isn't sent
down into the final `Data` value, it won't end up in the client!

    import BackendTask exposing (BackendTask)
    import BackendTask.Env
    import FatalError exposing (FatalError)

    type alias EnvVariables =
        { sendGridKey : String
        , siteUrl : String
        }

    sendEmail : Email -> BackendTask FatalError ()
    sendEmail email =
        BackendTask.map2 EnvVariables
            (BackendTask.Env.expect "SEND_GRID_KEY" |> BackendTask.allowFatal)
            (BackendTask.Env.get "BASE_URL"
                |> BackendTask.map (Maybe.withDefault "http://localhost:1234")
            )
            |> BackendTask.andThen (sendEmailBackendTask email)

    sendEmailBackendTask : Email -> EnvVariables -> BackendTask FatalError ()
    sendEmailBackendTask email envVariables =
        Debug.todo "Not defined here"

@docs get, expect


## Errors

@docs Error

-}

import Ansi.Color
import BackendTask exposing (BackendTask)
import BackendTask.Http
import BackendTask.Internal.Request
import FatalError exposing (FatalError)
import Json.Decode as Decode
import Json.Encode as Encode


{-| -}
type Error
    = MissingEnvVariable String


{-| Get an environment variable, or Nothing if there is no environment variable matching that name. This `BackendTask`
will never fail, but instead will return `Nothing` if the environment variable is missing.
-}
get : String -> BackendTask error (Maybe String)
get envVariableName =
    BackendTask.Internal.Request.request
        { name = "env"
        , body = BackendTask.Http.jsonBody (Encode.string envVariableName)
        , expect =
            BackendTask.Http.expectJson
                (Decode.nullable Decode.string)
        }


{-| Get an environment variable, or a BackendTask FatalError if there is no environment variable matching that name.
-}
expect : String -> BackendTask { fatal : FatalError, recoverable : Error } String
expect envVariableName =
    envVariableName
        |> get
        |> BackendTask.andThen
            (\maybeValue ->
                maybeValue
                    |> Result.fromMaybe
                        (FatalError.recoverable
                            { title = "Missing Env Variable"
                            , body =
                                [ "BackendTask.Env.expect was expecting a variable `"
                                , Ansi.Color.fontColor Ansi.Color.yellow envVariableName
                                , "` but couldn't find a variable with that name."
                                ]
                                    |> String.concat
                            }
                            (MissingEnvVariable envVariableName)
                        )
                    |> BackendTask.fromResult
            )
