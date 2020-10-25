# Factorio Blueprint Visualizer

The idea is to analyze the quality of splitters in a blueprint book.

## misc

- graphics of belts found here: `~/Library/Application Support/Steam/SteamApps/common/Factorio/factorio.app/Contents/data/base/graphics/entity/transport-belt/hr-transport-belt.png`
- [Blueprint string encoding (factorio wiki)](https://wiki.factorio.com/Blueprint_string_format)
- decode blueprint book string: `cat blueprint-book.txt | sed '1s/^.//'| base64 --decode | pigz -dc | jq . > blueprint-book.json`
  - skip the first character of the string (which denotes the version)
- [belt_animation_set](https://wiki.factorio.com/Prototype/TransportBelt#belt_animation_set)

## inspiration

- [Factorio Blueprint Editor](https://teoxoy.github.io/factorio-blueprint-editor/)
- [pen by Jason Rushton (taught me, how css-sprites and animations work)](https://codepen.io/jasonr/pen/YrzxOJ)

## TODO

- visualize splitters
- visualize underground belts
- visualize splitter from blueprintbook

## Done

- visualizing normal transport belts

## research

### seam between belts problem

[https://forums.factorio.com/viewtopic.php?t=84760](https://forums.factorio.com/viewtopic.php?t=84760)

> A while ago we made transport belt graphics have about 2 pixel overlap of their tile to fix these seaming issues. I wonder if bobs mods were updated to do that as well. In vanilla I can't really notice any seams. Maybe when zoomed out in editor and on white tiles, but not in real game.

### orientation indexes

[https://wiki.factorio.com/Prototype/TransportBelt#belt_animation_set](https://wiki.factorio.com/Prototype/TransportBelt#belt_animation_set)

| id                  | type  | default     |
| :------------------ | :---- | :---------- |
| east_to_north_index | uint8 | Default: 5  |
| north_to_east_index | uint8 | Default: 6  |
| west_to_north_index | uint8 | Default: 7  |
| north_to_west_index | uint8 | Default: 8  |
| south_to_east_index | uint8 | Default: 9  |
| east_to_south_index | uint8 | Default: 10 |
| south_to_west_index | uint8 | Default: 11 |
| west_to_south_index | uint8 | Default: 12 |

[https://wiki.factorio.com/Prototype/TransportBeltConnectable#belt_animation_set](https://wiki.factorio.com/Prototype/TransportBeltConnectable#belt_animation_set)

| id                   | type             | optional?  | default        |
| :------------------- | :--------------- | :--------- | :------------- |
| animation_set        | RotatedAnimation | Mandatory. |                |
| east_index           | uint8            | Optional.  | Default: 1     |
| west_index           | uint8            | Optional.  | Default: 2     |
| north_index          | uint8            | Optional.  | Default: 3     |
| south_index          | uint8            | Optional.  | Default: 4     |
| starting_south_index | uint8            | Optional.  | Default: 13    |
| ending_south_index   | uint8            | Optional.  | Default: 14    |
| starting_west_index  | uint8            | Optional.  | Default: 15    |
| ending_west_index    | uint8            | Optional.  | Default: 16    |
| starting_north_index | uint8            | Optional.  | Default: 17    |
| ending_north_index   | uint8            | Optional.  | Default: 18    |
| starting_east_index  | uint8            | Optional.  | Default: 19    |
| ending_east_index    | uint8            | Optional.  | Default: 20    |
| ending_patch         | Sprite4Way       | Optional.  |                |
| ends_with_stopper    | bool             | Optional.  | Default: false |
