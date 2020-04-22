-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module NotificationsApi.Object.Notification exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import NotificationsApi.InputObject
import NotificationsApi.Interface
import NotificationsApi.Object
import NotificationsApi.Scalar
import NotificationsApi.ScalarCodecs
import NotificationsApi.Union


channel : SelectionSet String NotificationsApi.Object.Notification
channel =
    Object.selectionForField "String" "channel" [] Decode.string


from : SelectionSet String NotificationsApi.Object.Notification
from =
    Object.selectionForField "String" "from" [] Decode.string


message : SelectionSet String NotificationsApi.Object.Notification
message =
    Object.selectionForField "String" "message" [] Decode.string
