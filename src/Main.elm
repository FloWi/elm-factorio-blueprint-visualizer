module Main exposing (..)

import Browser
import Html exposing (Html, div, h1, img, input, label, text)
import Html.Attributes as H exposing (..)
import Html.Events exposing (onInput)



---- MODEL ----


type alias Model =
    { initialOffset : Pos
    , offset : Pos
    , width : Float
    , height : Float
    }


type alias Pos =
    { x : Float
    , y : Float
    }


init : ( Model, Cmd Msg )
init =
    ( { initialOffset =
            { x = 32
            , y = 38
            }
      , offset =
            { x = 60
            , y = 60
            }
      , width = 64
      , height = 68
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = NoOp
    | UpdateInitialOffsetX String
    | UpdateInitialOffsetY String
    | UpdateOffsetX String
    | UpdateOffsetY String
    | UpdateWidth String
    | UpdateHeight String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInitialOffsetX str ->
            let
                newX =
                    Maybe.withDefault 0 (String.toFloat str)

                newPos =
                    { x = newX, y = model.initialOffset.y }
            in
            ( { model | initialOffset = newPos }, Cmd.none )

        UpdateInitialOffsetY str ->
            let
                newY =
                    Maybe.withDefault 0 (String.toFloat str)

                newPos =
                    { x = model.initialOffset.x, y = newY }
            in
            ( { model | initialOffset = newPos }, Cmd.none )

        UpdateOffsetX str ->
            let
                new =
                    Maybe.withDefault 0 (String.toFloat str)

                offset =
                    { x = new, y = model.offset.y }
            in
            ( { model | offset = offset }, Cmd.none )

        UpdateOffsetY str ->
            let
                new =
                    Maybe.withDefault 0 (String.toFloat str)

                offset =
                    { x = model.offset.x, y = new }
            in
            ( { model | offset = offset }, Cmd.none )

        UpdateWidth str ->
            ( { model | width = Maybe.withDefault 0 (String.toFloat str) }, Cmd.none )

        UpdateHeight str ->
            ( { model | height = Maybe.withDefault 0 (String.toFloat str) }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



---- VIEW ----


px : Float -> String
px num =
    String.fromFloat num ++ "px"


pos : Pos -> String
pos { x, y } =
    String.join " " [ px x, px y ]


formSlider : Model -> String -> Float -> Float -> (Model -> Float) -> (String -> Msg) -> Html Msg
formSlider model lbl min max v toMsg =
    div [ class "row" ]
        [ label []
            [ text lbl
            , input
                [ type_ "range"
                , H.min (String.fromFloat min)
                , H.max (String.fromFloat max)
                , value <| String.fromFloat (v model)
                , onInput toMsg
                ]
                []
            , text <| String.fromFloat (v model)
            ]
        ]


beltNode : Model -> Int -> Int -> Html msg
beltNode model rowIdx colIdx =
    let
        x =
            -(model.initialOffset.x + (toFloat colIdx * (model.width + model.offset.x)))

        y =
            -(model.initialOffset.y + (toFloat rowIdx * (model.height + model.offset.y)))
    in
    Html.node "sprite"
        [ class "my-transport-belt"
        , style "background-position" (pos { x = x, y = y })
        , style "width" (px model.width)
        , style "height" (px model.height)

        -- , Html.Attributes.attribute "direction" "e"
        ]
        []


animatedBeltNode dir =
    div [ class "row" ]
        [ Html.node "sprite"
            [ class "transport-belt"
            , H.attribute "direction" dir
            ]
            []
        ]


customAnimatedBeltNode dir =
    div [ class "row" ]
        [ Html.node "sprite"
            [ class "transport-belt"
            , H.attribute "direction" dir
            ]
            []
        ]


view : Model -> Html Msg
view model =
    div [ class "main" ]
        [ h1 [] [ text "Factorio belts" ]
        , formSlider model "initial-offset x" -64 64 (\m -> m.initialOffset.x) UpdateInitialOffsetX
        , formSlider model "initial-offset y" -64 64 (\m -> m.initialOffset.y) UpdateInitialOffsetY
        , formSlider model "offset x" -80 80 (\m -> m.offset.x) UpdateOffsetX
        , formSlider model "offset y" -80 80 (\m -> m.offset.y) UpdateOffsetY
        , formSlider model "width" -80 80 (\m -> m.width) UpdateWidth
        , formSlider model "height" -80 80 (\m -> m.height) UpdateHeight
        , div [ class "row" ]
            (List.repeat 10 (beltNode model 0 0))
        , div [ class "row" ]
            (List.repeat 10 (animatedBeltNode "e"))
        , div [ class "row" ]
            (List.repeat
                10
                (beltNode model 1 0)
            )
        , div [ class "row" ]
            (List.repeat 10 (animatedBeltNode "w"))
        , img [ src "/hr-transport-belt.png" ] []
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
