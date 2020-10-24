# Factorio Blueprint Visualizer

The idea is to analyze the quality of splitters in a blueprint book.

## misc

- graphics of belts found here: `~/Library/Application Support/Steam/SteamApps/common/Factorio/factorio.app/Contents/data/base/graphics/entity/transport-belt/hr-transport-belt.png`
- [Blueprint string encoding (factorio wiki)](https://wiki.factorio.com/Blueprint_string_format)
- decode blueprint book string: `cat blueprint-book.txt | sed '1s/^.//'| base64 --decode | pigz -dc | jq . > blueprint-book.json`
  - skip the first character of the string (which denotes the version)  

## inspiration

- [Factorio Blueprint Editor](https://teoxoy.github.io/factorio-blueprint-editor/)
- [pen by Jason Rushton (taught me, how css-sprites and animations work)](https://codepen.io/jasonr/pen/YrzxOJ)

## TODO

- visualize splitters
- visualize underground belts
- visualize splitter from blueprintbook

## Done

- visualizing normal transport belts
