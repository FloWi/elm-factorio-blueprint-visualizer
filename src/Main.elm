module Main exposing (main)

-- elm install avh4/elm-color

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Settings.Line exposing (lineWidth)
import Canvas.Texture exposing (..)
import Color
import Css exposing (local)
import Dict exposing (Dict)
import Dict.Extra
import Html exposing (Html, a)
import Html.Attributes exposing (style)
import List.Extra
import Svg.Styled.Attributes exposing (direction)


type alias Model =
    { frame : Int
    , sprites : Load Sprites
    , canvasWidth : Int
    , canvasHeight : Int
    }


type Load a
    = Loading
    | Success a
    | Failure


type alias Sprites =
    { animationFrames : Dict String (List Texture)
    , original : Texture
    }


type Msg
    = AnimationFrame Float
    | TextureLoaded (Maybe Texture)


init : ( Model, Cmd Msg )
init =
    ( { frame = 0
      , sprites = Loading
      , canvasWidth = 2048
      , canvasHeight = 2560
      }
    , Cmd.none
    )



{-

   - it seems that the graphics have a 2px overlap (on each side?)
   - so, the grid is still 64x64px, but I load (-2,-2) to (66,66)

-}


offsets : { initialOffset : { x : Int, y : Int }, offset : { x : Int, y : Int }, width : Int, height : Int, overlap : Int }
offsets =
    { initialOffset =
        { x = 32
        , y = 32
        }
    , offset =
        { x = 64
        , y = 64
        }
    , width = 64
    , height = 64
    , overlap = 2
    }


createTextureDict : Texture -> Dict String (List Texture)
createTextureDict texture =
    let
        o =
            offsets

        x =
            o.initialOffset.x

        texturesByDirectionName : String -> List Texture
        texturesByDirectionName directionName =
            let
                directionIndex =
                    beltRenderDirectionsByString
                        |> Dict.get directionName
                        |> Maybe.map Tuple.first
                        |> Maybe.withDefault -1
            in
            List.range 0 (numAnimationFrames - 1)
                |> List.map
                    (\i ->
                        sprite
                            { x = toFloat (-o.overlap + x + (o.offset.x + o.width) * i)
                            , y = toFloat (-o.overlap + o.initialOffset.y + directionIndex * (o.height + o.offset.y))
                            , width = toFloat (o.width + 2 * o.overlap)
                            , height = toFloat (o.height + 2 * o.overlap)
                            }
                            texture
                    )
    in
    beltRenderDirectionsByString
        |> Dict.map (\dir _ -> texturesByDirectionName dir)


numAnimationFrames =
    16


framerate =
    60 / 30


type BlueprintDirection
    = North
    | Northeast
    | East
    | Southeast
    | South
    | Southwest
    | West
    | Northwest


type BeltRenderDirection
    = NorthEast
    | NorthSouth
    | NorthWest
    | EastNorth
    | EastSouth
    | EastWest
    | SouthNorth
    | SouthEast
    | SouthWest
    | WestNorth
    | WestEast
    | WestSouth


factorioBlueprintDirection =
    Dict.fromList
        [ ( 0, North )
        , ( 1, Northeast )
        , ( 2, East )
        , ( 3, Southeast )
        , ( 4, South )
        , ( 5, Southwest )
        , ( 6, West )
        , ( 7, Northwest )
        ]


beltRenderDirectionsByIdx : Dict Int ( BeltRenderDirection, String )
beltRenderDirectionsByIdx =
    Dict.fromList
        [ ( 1, ( EastWest, "EastWest" ) )
        , ( 0, ( WestEast, "WestEast" ) )
        , ( 2, ( SouthNorth, "SouthNorth" ) )
        , ( 3, ( NorthSouth, "NorthSouth" ) )
        , ( 5, ( NorthEast, "NorthEast" ) )
        , ( 8, ( SouthEast, "SouthEast" ) )
        , ( 10, ( SouthWest, "SouthWest" ) )
        , ( 7, ( NorthWest, "NorthWest" ) )
        , ( 4, ( EastNorth, "EastNorth" ) )
        , ( 9, ( EastSouth, "EastSouth" ) )
        , ( 6, ( WestNorth, "WestNorth" ) )
        , ( 11, ( WestSouth, "WestSouth" ) )
        ]


beltRenderDirectionsByString : Dict String ( Int, BeltRenderDirection )
beltRenderDirectionsByString =
    beltRenderDirectionsByIdx
        |> Dict.toList
        |> List.map (\( idx, ( dir, dirString ) ) -> ( dirString, ( idx, dir ) ))
        |> Dict.fromList


renderBeltAnimation : Model -> GameEntity -> List Renderable
renderBeltAnimation model { x, y, direction } =
    let
        pos =
            { x = -offsets.overlap + x * offsets.width, y = -offsets.overlap + y * offsets.height }

        renderFrame =
            round (toFloat model.frame / framerate)

        animationIndex =
            if renderFrame > 0 then
                --0
                modBy numAnimationFrames renderFrame

            else
                0

        directionString =
            beltRenderDirectionsByIdx
                |> Dict.values
                |> List.Extra.find (\( dir, str ) -> dir == direction)
                |> Maybe.map Tuple.second
                |> Maybe.withDefault "broken"
    in
    case model.sprites of
        Success sprites ->
            sprites.animationFrames
                |> Dict.get directionString
                |> Maybe.withDefault []
                |> List.Extra.getAt animationIndex
                |> Maybe.map (renderBelt pos)
                |> Maybe.withDefault []

        _ ->
            []


type alias GameEntity =
    { x : Int, y : Int, direction : BeltRenderDirection }


type RotationDirection
    = Clockwise
    | CounterClockwise


circle : Pos -> RotationDirection -> List GameEntity
circle offset rot =
    [ { x = 0 + offset.x
      , y = 0 + offset.y
      , direction =
            if rot == Clockwise then
                SouthEast

            else
                EastSouth
      }
    , { x = 1 + offset.x
      , y = 0 + offset.y
      , direction =
            if rot == Clockwise then
                WestSouth

            else
                SouthWest
      }
    , { x = 1 + offset.x
      , y = 1 + offset.y
      , direction =
            if rot == Clockwise then
                NorthWest

            else
                WestNorth
      }
    , { x = 0 + offset.x
      , y = 1 + offset.y
      , direction =
            if rot == Clockwise then
                EastNorth

            else
                NorthEast
      }
    ]


straight : BeltRenderDirection -> Int -> List GameEntity
straight dir y =
    [ { x = 0, y = y, direction = dir }
    , { x = 1, y = y, direction = dir }
    , { x = 2, y = y, direction = dir }
    , { x = 3, y = y, direction = dir }
    ]


straightVertical : BeltRenderDirection -> Int -> List GameEntity
straightVertical dir x =
    [ { x = x, y = 0, direction = dir }
    , { x = x, y = 1, direction = dir }
    , { x = x, y = 2, direction = dir }
    , { x = x, y = 3, direction = dir }
    , { x = x, y = 4, direction = dir }
    ]



-- view : Model -> Html Msg
-- view model =
--     let
--         width =
--             1024
--         height =
--             768
--     in
--     Canvas.toHtmlWith
--         { width = width
--         , height = height
--         , textures = [ loadFromImageUrl "/hr-transport-belt.png" TextureLoaded ]
--         }
--         [ style "border" "1px solid black" ]
--         ([ shapes [ fill Color.white ] [ rect ( 0, 0 ) width height ]
--          , renderSquare
--          ]
--             ++ (circle { x = 0, y = 0 } Clockwise |> List.concatMap (renderBeltAnimation model))
--             ++ (circle { x = 2, y = 0 } CounterClockwise |> List.concatMap (renderBeltAnimation model))
--             ++ (straight WestEast 3 |> List.concatMap (renderBeltAnimation model))
--             ++ (straight EastWest 4 |> List.concatMap (renderBeltAnimation model))
--             ++ (straightVertical NorthSouth 4 |> List.concatMap (renderBeltAnimation model))
--             ++ (straightVertical SouthNorth 5 |> List.concatMap (renderBeltAnimation model))
--          -- ++ [ grid ]
--         )


renderSpriteGraphicWithGrid : Model -> List Renderable
renderSpriteGraphicWithGrid model =
    case model.sprites of
        Success sprites ->
            [ texture [] ( 0, 0 ) sprites.original, grid model ]

        _ ->
            []


view : Model -> Html Msg
view model =
    Canvas.toHtmlWith
        { width = model.canvasWidth
        , height = model.canvasHeight
        , textures = [ loadFromImageUrl "/hr-transport-belt.png" TextureLoaded ]
        }
        [ style "border" "1px solid black" ]
        ([ shapes [ fill Color.gray ] [ rect ( 0, 0 ) (toFloat model.canvasWidth) (toFloat model.canvasHeight) ]
         ]
            ++ renderSpriteGraphicWithGrid model
         -- ++ [ grid ]
        )


grid : Model -> Renderable
grid model =
    let
        verticals =
            List.range 0 numAnimationFrames
                |> List.concatMap
                    (\i ->
                        let
                            xLeftEdge =
                                toFloat (offsets.initialOffset.x + i * (offsets.width + offsets.offset.x))

                            xLeftOverlapEdge =
                                xLeftEdge - toFloat offsets.overlap

                            xRightEdge =
                                xLeftEdge + toFloat offsets.width

                            xRightOverlapEdge =
                                xRightEdge + toFloat offsets.overlap
                        in
                        [ path ( xLeftEdge, 0 ) [ lineTo ( xLeftEdge, toFloat model.canvasHeight ) ]
                        , path ( xRightEdge, 0 ) [ lineTo ( xRightEdge, toFloat model.canvasHeight ) ]
                        , path ( xLeftOverlapEdge, 0 ) [ lineTo ( xLeftOverlapEdge, toFloat model.canvasHeight ) ]
                        , path ( xRightOverlapEdge, 0 ) [ lineTo ( xRightOverlapEdge, toFloat model.canvasHeight ) ]
                        ]
                    )

        horizontals =
            List.range 0 20
                |> List.concatMap
                    (\i ->
                        let
                            yTopEdge =
                                toFloat (offsets.initialOffset.y + i * (offsets.height + offsets.offset.y))

                            yTopOverlapEdge =
                                yTopEdge - toFloat offsets.overlap

                            yBottomEdge =
                                yTopEdge + toFloat offsets.width

                            yBottomOverlapEdge =
                                yBottomEdge + toFloat offsets.overlap
                        in
                        [ path ( 0, yTopEdge ) [ lineTo ( toFloat model.canvasWidth, yTopEdge ) ]
                        , path ( 0, yTopOverlapEdge ) [ lineTo ( toFloat model.canvasWidth, yTopOverlapEdge ) ]
                        , path ( 0, yBottomEdge ) [ lineTo ( toFloat model.canvasWidth, yBottomEdge ) ]
                        , path ( 0, yBottomOverlapEdge ) [ lineTo ( toFloat model.canvasWidth, yBottomOverlapEdge ) ]
                        ]
                    )
    in
    shapes [ stroke Color.lightRed, lineWidth 0.5 ] (verticals ++ horizontals)


renderSquare =
    shapes [ fill Color.lightGrey ]
        [ rect ( 0, 0 ) 1024 768 ]


type alias Pos =
    { x : Int
    , y : Int
    }


renderBelt : Pos -> Texture -> List Renderable
renderBelt location tex =
    [ --shapes [ fill Color.lightGreen ] [ rect ( location.x, location.y ) w h ]
      texture [] ( toFloat location.x, toFloat location.y ) tex
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimationFrame _ ->
            ( { model | frame = model.frame + 1 }
            , Cmd.none
            )

        TextureLoaded (Just texture) ->
            ( { model
                | sprites =
                    Success
                        { animationFrames = createTextureDict texture
                        , original = texture
                        }
              }
            , Cmd.none
            )

        TextureLoaded Nothing ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    onAnimationFrameDelta AnimationFrame


main : Program () Model Msg
main =
    Browser.element { init = \_ -> init, update = update, subscriptions = subscriptions, view = view }
