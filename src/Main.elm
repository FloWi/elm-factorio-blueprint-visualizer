module Main exposing (..)

import Browser
import Css exposing (..)
import Css.Animations as Anim exposing (keyframes)
import FormatNumber exposing (format)
import FormatNumber.Locales exposing (Decimals(..), usLocale)
import Html.Styled exposing (Html, button, div, h1, img, input, label, table, td, text, th, toUnstyled, tr)
import Html.Styled.Attributes as H exposing (..)
import Html.Styled.Events exposing (onClick, onInput)


myFormat =
    format { usLocale | decimals = Exact 1 }


expected : List Int
expected =
    [ 38
    , 166
    , 286
    , 416
    , 542
    , 672
    , 798
    , 928
    , 1062
    , 1190
    , 1318
    , 1446
    , 1568
    , 1696
    , 1830
    , 1958
    , 2128
    , 2255
    , 2342
    , 2470
    ]



---- MODEL ----


type alias Model =
    { initialOffset : Pos
    , offset : Pos
    , width : Float
    , height : Float
    , drawHeight : Float
    , debug : Bool
    }


type alias Pos =
    { x : Float
    , y : Float
    }


init : ( Model, Cmd Msg )
init =
    ( { debug = False
      , initialOffset =
            { x = 32
            , y = 32
            }
      , offset =
            { x = 60
            , y = 64
            }
      , width = 64
      , height = 64
      , drawHeight = 64
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
    | UpdateDrawHeight String
    | ToggleDebug


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

        UpdateDrawHeight str ->
            ( { model | drawHeight = Maybe.withDefault 0 (String.toFloat str) }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )

        ToggleDebug ->
            ( { model | debug = not model.debug }, Cmd.none )



---- VIEW ----
-- px : Float -> String
-- px num =
--     String.fromFloat num ++ "px"
-- pos : Pos -> String
-- pos { x, y } =
--     String.join " " [ px x, px y ]


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
            , text <| myFormat (v model)
            , button [ onClick (toMsg (String.fromFloat (v model + 0.5))) ] [ text "+" ]
            , button [ onClick (toMsg (String.fromFloat (v model - 0.5))) ] [ text "-" ]
            ]
        ]


theme : { secondary : Color, primary : Color }
theme =
    { primary = hex "55af6a"
    , secondary = rgb 250 240 230
    }


cssTransportBeltStyle model =
    css
        [ backgroundImage (url "/hr-transport-belt.png")
        , display inlineBlock
        , flexShrink (num 0)
        , flexGrow (num 0)
        , padding (px 0)
        , margin (px 0)
        , backgroundColor theme.primary
        , Css.width (px model.width)
        , Css.height (px model.drawHeight)
        ]


numAnimationSteps =
    16


pxFn : Float -> String
pxFn val =
    String.fromFloat val ++ "px"


yOffsetByRow : Model -> Int -> Float
yOffsetByRow model rowIdx =
    model.initialOffset.y + toFloat rowIdx * (model.offset.y + model.height)


cssTransportBeltAnimationStyle : Model -> Int -> Html.Styled.Attribute msg
cssTransportBeltAnimationStyle model rowIdx =
    let
        convertPxList : List Float -> String
        convertPxList xs =
            xs
                |> List.map pxFn
                |> String.join " "

        y =
            -(yOffsetByRow model rowIdx)

        from =
            [ -model.initialOffset.x
            , y
            ]
                |> convertPxList

        to =
            [ -(model.initialOffset.x + numAnimationSteps * model.offset.x + (numAnimationSteps + 1) * model.width)
            , y
            ]
                |> convertPxList
    in
    css
        [ animationName
            (keyframes
                [ ( 0, [ Anim.custom "background-position" from ] )
                , ( 100, [ Anim.custom "background-position" to ] )
                ]
            )
        , animationDuration (ms 266.666666667)

        -- , animationIterationCount infinite --this doesn't compile for some reason
        , Css.property "animation-iteration-count" "infinite"
        , Css.property "animation-timing-function" "steps(16)"
        ]


cssBeltNode : Model -> Int -> Int -> Html msg
cssBeltNode model rowIdx colIdx =
    let
        x =
            -(model.initialOffset.x + (toFloat colIdx * (model.width + model.offset.x)))

        y =
            -(model.initialOffset.y + (toFloat rowIdx * (model.height + model.offset.y)))
    in
    Html.Styled.node "mySprite"
        [ cssTransportBeltStyle model
        , css
            [ backgroundPosition2 (px x) (px y)
            ]
        ]
        []


type Direction
    = West
    | East
    | North
    | South
    | SouthEast
    | WestSouth
    | EastNorth
    | NorthWest
    | EastSouth
    | SouthWest
    | NorthEast
    | WestNorth


rowIndex dir =
    case dir of
        West ->
            1

        East ->
            0

        North ->
            2

        South ->
            3

        SouthEast ->
            8

        WestSouth ->
            11

        EastNorth ->
            4

        NorthWest ->
            7

        EastSouth ->
            9

        SouthWest ->
            10

        NorthEast ->
            5

        WestNorth ->
            6


cssAnimatedBeltNode : Direction -> Model -> Html msg
cssAnimatedBeltNode dir model =
    div [ class "row" ]
        [ Html.Styled.node "mySprite"
            [ cssTransportBeltStyle model
            , cssTransportBeltAnimationStyle model (rowIndex dir)
            ]
            []
        ]


renderLocationTable : Model -> Html msg
renderLocationTable model =
    let
        calculatedValues : List (Html msg)
        calculatedValues =
            expected
                |> List.indexedMap
                    (\index e ->
                        tr []
                            [ td [] [ text (String.fromInt index) ]
                            , td [] [ text (String.fromInt e) ]
                            , td [] [ text (String.fromFloat (yOffsetByRow model index)) ]
                            ]
                    )
    in
    Html.Styled.table []
        ([ tr []
            [ th [] [ text "index" ]
            , th [] [ text "expected" ]
            , th [] [ text "actual" ]
            ]
         ]
            ++ calculatedValues
        )


circleClockwise : Model -> List (Html msg)
circleClockwise model =
    [ div [ class "row" ]
        [ cssAnimatedBeltNode SouthEast model
        , cssAnimatedBeltNode WestSouth model
        ]
    , div [ class "row" ]
        [ cssAnimatedBeltNode EastNorth model
        , cssAnimatedBeltNode NorthWest model
        ]
    ]


circleCounterClockwise : Model -> List (Html msg)
circleCounterClockwise model =
    [ div [ class "row" ]
        [ cssAnimatedBeltNode EastSouth model
        , cssAnimatedBeltNode SouthWest model
        ]
    , div [ class "row" ]
        [ cssAnimatedBeltNode NorthEast model
        , cssAnimatedBeltNode WestNorth model
        ]
    ]


checkbox : msg -> String -> Bool -> Html msg
checkbox msg name isChecked =
    label
        [ style "padding" "20px" ]
        [ input [ type_ "checkbox", onClick msg, H.checked isChecked ] []
        , text name
        ]


debugShow : Bool -> List a -> List a
debugShow isDebug x =
    if isDebug then
        x

    else
        []


view : Model -> Html Msg
view model =
    div [ class "main" ]
        ([ h1 [] [ text "Factorio belts" ]
         , checkbox ToggleDebug "Debug" model.debug
         ]
            ++ debugShow model.debug
                [ formSlider model "initial-offset x" -64 64 (\m -> m.initialOffset.x) UpdateInitialOffsetX
                , formSlider model "initial-offset y" -64 64 (\m -> m.initialOffset.y) UpdateInitialOffsetY
                , formSlider model "offset x" -80 80 (\m -> m.offset.x) UpdateOffsetX
                , formSlider model "offset y" -80 80 (\m -> m.offset.y) UpdateOffsetY
                , formSlider model "width" -80 80 (\m -> m.width) UpdateWidth
                , formSlider model "height" -80 80 (\m -> m.height) UpdateHeight
                , formSlider model "draw-height" -80 80 (\m -> m.drawHeight) UpdateDrawHeight
                ]
            ++ [ div [ class "row" ]
                    (List.repeat 3 (cssBeltNode model 0 0))
               , div [ class "row" ]
                    (List.repeat 3 (cssAnimatedBeltNode West model) ++ List.repeat 3 (cssAnimatedBeltNode East model))
               , div [ class "row" ]
                    (List.repeat 3 (cssBeltNode model 1 0))
               , div [ class "row" ]
                    (List.repeat 3 (cssAnimatedBeltNode East model) ++ List.repeat 3 (cssAnimatedBeltNode West model))
               ]
            ++ circleClockwise model
            ++ circleCounterClockwise model
            ++ List.repeat 3 (div [ class "row" ] [ cssAnimatedBeltNode North model, cssAnimatedBeltNode East model, cssAnimatedBeltNode South model, cssAnimatedBeltNode West model ])
            ++ List.repeat 3 (div [ class "row" ] [ cssAnimatedBeltNode South model ])
            ++ debugShow model.debug
                [ div []
                    [ renderLocationTable model
                    ]
                ]
            ++ [ img [ src "/hr-transport-belt.png" ] []
               ]
        )



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view >> toUnstyled
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
