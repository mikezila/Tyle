Tyle
====

Tile based map editor for gaming use the Tyle format.  The game it goes with isn't ready yet, but the editor stores it's data into three pretty simple arrays, so it could easily be used to make maps for other games that use simple tile based rendering.

Demo here:
http://www.youtube.com/watch?v=GOkeDAkhCJ8

Requirements
============
- **Ruby** v1.8 or v1.9, I recommend v1.9.3
- The **Gosu** gem

        gem install gosu

Maps
====

It stores map data in two layers, world and props.  Props are always rendered above the world, so things like signs, fences, and mailboxes always appear on top of the grass, roads, or gravel you place them on top of. Maps also contain collision information, and any tile can be marked for collision.  You must manually pick what tiles you want to have collision, it doesn't matter what world tile or prop is on a tile, the player can walk over it unless you tell the map they shouldn't.

It's also on you to make sure that your props and world tiles are used sensibly.  The editor will let you place a map tile (like a road, or a patch of grass) as a prop, which will cover whatever world tile is there.  It will also let you place props (like trees, signs, rocks) as world tiles, meaning their transparent bits will let the void shine through.

Keys
====

There is no HUD at current, so the keys aren't obvious.  Sorry about that.  There will be a HUD in the next version I think.

- **Arrows** - Move the cursor.
- **Q / W** - Cycle through the tiles in the tileset.
- **A** - Place the current tile as a world map tile.
- **S** - Place the current tile as a prop.
- **D** - Clear a tile, removing any world tile, prop, and collsion.
- **Z** - Mark an area for collision.
- **X** - Toggle drawing colliders, represented by red circles with crosses.
- **IJKL** - Move the camera, moves faster during zoom.
- **M** - Toggle zoom, will zoom into an area with the cursor at top left.
- **O / P** - Save and load the map, uses the FILENAME constant to do either.

TODO
====

- Make the zoom suck less
- Split into more than one file, getting messy
- Add a HUD that shows keys
- Add map truncation or let user specify desired map size.
- Let user choose filename, and save/load to files of their choosing.
- Instead of having three files (space,props,tiles) find a way to just have one.

