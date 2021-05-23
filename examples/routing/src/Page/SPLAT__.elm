module Page.SPLAT__ exposing (Data, Model, Msg, page)

import DataSource
import Head
import Html.Styled exposing (text)
import Page exposing (Page, PageWithState, StaticPayload)
import View exposing (View)


type alias Model =
    ()


type alias Msg =
    Never


type alias RouteParams =
    { splat : List String }


page : Page RouteParams Data
page =
    Page.serverlessRoute
        { head = head

        --, routes = routes
        , data = \_ -> data
        , routeFound = \_ -> DataSource.succeed True
        }
        |> Page.buildNoState { view = view }


data : RouteParams -> DataSource.DataSource Data
data routeParams =
    DataSource.succeed ()


head :
    StaticPayload Data RouteParams
    -> List Head.Tag
head static =
    []


type alias Data =
    ()


view :
    StaticPayload Data RouteParams
    -> View Msg
view static =
    { body =
        [ Debug.toString static.routeParams |> text
        ]
    , title = "Fallback splat page"
    }
