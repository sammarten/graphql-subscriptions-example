port module Main exposing (main)

import Browser
import Graphql.Document
import Graphql.Http
import Graphql.Operation exposing (RootSubscription)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Html exposing (Html, button, div, fieldset, h1, img, input, label, li, p, pre, text, ul)
import Html.Attributes exposing (class, href, name, src, style, target, type_)
import Html.Events exposing (onClick)
import Json.Decode
import NotificationsApi.Mutation as Mutation
import NotificationsApi.Object
import NotificationsApi.Object.Notification as Notification
import NotificationsApi.Subscription as Subscription
import RemoteData exposing (RemoteData)



---- MODEL ----


type SubscriptionStatus
    = NotConnected
    | Connected
    | Reconnecting


type alias Notification =
    { channel : String
    , from : String
    , message : String
    }


type alias Model =
    { notifications : List Notification
    , subscriptionStatus : SubscriptionStatus
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( { notifications = []
      , subscriptionStatus = NotConnected
      }
    , createSubscriptions (subscriptionDocument "fun" |> Graphql.Document.serializeSubscription)
    )



---- GRAPHQL ----


subscriptionDocument : String -> SelectionSet Notification RootSubscription
subscriptionDocument channel =
    Subscription.notificationReceived { channel = channel } notificationSelection


notificationSelection : SelectionSet Notification NotificationsApi.Object.Notification
notificationSelection =
    SelectionSet.succeed Notification
        |> with Notification.channel
        |> with Notification.from
        |> with Notification.message



---- UPDATE ----


type Msg
    = SubscriptionDataReceived Json.Decode.Value
    | SentMessage (RemoteData (Graphql.Http.Error Notification) Notification)
    | NewSubscriptionStatus SubscriptionStatus ()


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubscriptionDataReceived newData ->
            case Json.Decode.decodeValue (subscriptionDocument "fun" |> Graphql.Document.decoder) newData of
                Ok notification ->
                    ( { model | notifications = notification :: model.notifications }, Cmd.none )

                Err error ->
                    ( model, Cmd.none )

        SentMessage _ ->
            ( model, Cmd.none )

        NewSubscriptionStatus newStatus () ->
            ( { model | subscriptionStatus = newStatus }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.subscriptionStatus of
        NotConnected ->
            div
                [ class "p-8"
                , class "text-center"
                ]
                [ text "Connecting..."
                ]

        Reconnecting ->
            div
                [ class "p-8"
                , class "text-center"
                ]
                [ text "Reconnecting..."
                , notificationsView model.notifications
                ]

        Connected ->
            div
                [ class "p-8"
                , class "text-center"
                ]
                [ text "Connected"
                , notificationsView model.notifications
                ]


notificationsView : List Notification -> Html Msg
notificationsView notifications =
    let
        notificationListView =
            List.map notificationView notifications
    in
    div
        []
        notificationListView


notificationView : Notification -> Html Msg
notificationView notification =
    div
        []
        [ div
            []
            [ text notification.channel ]
        , div
            []
            [ text notification.from ]
        , div
            []
            [ text notification.message ]
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    -- Graphql.Subscription.listen GraphqlSubscriptionMsg model.graphqlSubscriptionModel
    Sub.batch
        [ gotSubscriptionData SubscriptionDataReceived
        , socketStatusConnected (NewSubscriptionStatus Connected)
        , socketStatusReconnecting (NewSubscriptionStatus Reconnecting)
        ]



---- PORTS ----


port createSubscriptions : String -> Cmd msg


port gotSubscriptionData : (Json.Decode.Value -> msg) -> Sub msg


port socketStatusConnected : (() -> msg) -> Sub msg


port socketStatusReconnecting : (() -> msg) -> Sub msg



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
