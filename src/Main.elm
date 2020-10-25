module Main exposing (main)

-- elm install avh4/elm-color

import Browser
import Browser.Events exposing (onAnimationFrameDelta)
import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Canvas.Texture exposing (..)
import Color
import Css exposing (local)
import Dict exposing (Dict)
import Html exposing (Html)
import Html.Attributes exposing (style)
import List.Extra


type alias Model =
    { frame : Int
    , sprites : Load Sprites
    }


type Load a
    = Loading
    | Success a
    | Failure


type alias Sprites =
    { animationFrames : List Texture
    }


type Msg
    = AnimationFrame Float
    | TextureLoaded (Maybe Texture)


init : ( Model, Cmd Msg )
init =
    ( { frame = 0, sprites = Loading }
    , Cmd.none
    )


offsets =
    { initialOffset =
        { x = 32
        , y = 38
        }
    , offset =
        { x = 64
        , y = 64
        }
    , width = 64
    , height = 64
    }


createTextureList : Texture -> List Texture
createTextureList texture =
    let
        o =
            offsets

        x =
            o.initialOffset.x

        y =
            o.initialOffset.y
    in
    List.range 0 (numAnimationFrames - 1)
        |> List.map (\i -> sprite { x = x + (o.offset.x + o.width) * toFloat i - 1, y = o.initialOffset.y, width = o.width + 1, height = o.height } texture)


numAnimationFrames =
    16


framerate =
    60 / 30


renderBeltAnimation : Model -> Pos -> List Renderable
renderBeltAnimation model pos =
    let
        renderFrame =
            round (toFloat model.frame / framerate)

        animationIndex =
            if renderFrame > 0 then
                --0
                modBy numAnimationFrames renderFrame

            else
                0
    in
    case model.sprites of
        Success sprites ->
            sprites.animationFrames
                |> List.Extra.getAt animationIndex
                |> Maybe.map (renderBelt pos)
                |> Maybe.withDefault []

        _ ->
            []


view : Model -> Html Msg
view model =
    let
        width =
            1024

        height =
            768
    in
    Canvas.toHtmlWith
        { width = width
        , height = height
        , textures = [ loadFromImageUrl "/hr-transport-belt.png" TextureLoaded ]
        }
        [ style "border" "1px solid black" ]
        ([ shapes [ fill Color.white ] [ rect ( 0, 0 ) width height ]
         , renderSquare
         ]
            ++ renderBeltAnimation model { x = 0, y = toFloat 0 }
            ++ renderBeltAnimation model { x = offsets.width, y = toFloat 0 }
            ++ renderBeltAnimation model { x = toFloat 2 * offsets.width, y = toFloat 0 }
        )


renderSquare =
    shapes [ fill Color.lightGrey ]
        [ rect ( 0, 0 ) 1024 768 ]


type alias Pos =
    { x : Float
    , y : Float
    }


renderBelt : Pos -> Texture -> List Renderable
renderBelt location tex =
    [ --shapes [ fill Color.lightGreen ] [ rect ( location.x, location.y ) w h ]
      texture [] ( location.x, location.y ) tex
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimationFrame _ ->
            ( { model | frame = model.frame + 1 }
            , Cmd.none
            )

        TextureLoaded (Just texture) ->
            let
                t =
                    Debug.log "texture" texture
            in
            ( { model | sprites = Success { animationFrames = createTextureList texture } }, Cmd.none )

        TextureLoaded Nothing ->
            let
                foo =
                    Debug.log "loading failed" 0
            in
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    onAnimationFrameDelta AnimationFrame


main : Program () Model Msg
main =
    Browser.element { init = \_ -> init, update = update, subscriptions = subscriptions, view = view }
