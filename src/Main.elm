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


w =
    64


h =
    70


offset =
    64


createTextureList : Texture -> List Texture
createTextureList texture =
    let
        x =
            32

        y =
            38
    in
    List.range 0 (numAnimationFrames - 1)
        |> List.map (\i -> sprite { x = x + (offset + w) * toFloat i, y = y, width = w, height = h } texture)


numAnimationFrames =
    16


view : Model -> Html Msg
view model =
    let
        width =
            1024

        height =
            768

        animationIndex =
            if model.frame > 0 then
                --0
                modBy numAnimationFrames model.frame

            else
                0

        firstBelt =
            case model.sprites of
                Success sprites ->
                    sprites.animationFrames
                        |> List.Extra.getAt animationIndex
                        |> Maybe.map (renderBelt { x = toFloat 0, y = toFloat 0 })
                        |> Maybe.withDefault []

                _ ->
                    []
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
            ++ firstBelt
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
    [ shapes [ fill Color.lightGreen ] [ rect ( location.x, location.y ) w h ]
    , texture [] ( location.x, location.y ) tex
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
