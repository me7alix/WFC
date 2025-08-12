package main

import rl "vendor:raylib"

Tile :: struct {
	image: []rl.Color,
	neighbors: [4][dynamic]^Tile,
}

tile_from_image :: proc(src: rl.Image, x, y: i32) -> Tile {
	tile := Tile{
		image = make([]rl.Color, TILE_SIZE*TILE_SIZE),
	}

	for i := 0; i < 4; i+=1 {
		tile.neighbors[i] = make([dynamic]^Tile)
	}

	for i: i32 = 0; i < TILE_SIZE; i+=1 {
		for j: i32 = 0; j < TILE_SIZE; j+=1 {
			pixI := (i + y) % src.height
			pixJ := (j + x) % src.width

			tile.image[i * TILE_SIZE + j] = rl.GetImageColor(src, pixJ, pixI)
		}
	}

	return tile
}

tiles_from_image :: proc(src: rl.Image) -> []Tile {
	tiles := make([]Tile, src.width * src.height)

	for i: i32 = 0; i < src.height; i+=1 {
		for j: i32 = 0; j < src.width; j+=1 {
			tiles[i * src.width + j] = tile_from_image(src, j, i)
		}
	}

	return tiles
}

tile_check_neighbor :: proc(this, other: ^Tile, dir: int) -> bool {
	tdx, tdy: i32 = 0, 0
	odx, ody: i32 = 0, 0
	ix, iy: i32 = 0, 0

	switch (dir) {
	case RIGHT:
		ix = TILE_SIZE-2; odx = -(TILE_SIZE-2)
	case LEFT:
		ix = TILE_SIZE-2; tdx = -(TILE_SIZE-2)
	case UP:
		iy = TILE_SIZE-2; tdy = -(TILE_SIZE-2)
	case DOWN:
		iy = TILE_SIZE-2; ody = -(TILE_SIZE-2)
	}

	for i: i32 = iy; i < TILE_SIZE; i+=1 {
		for j: i32 = ix; j < TILE_SIZE; j+=1 {
			if this.image[(i+tdy) * TILE_SIZE + j+tdx] != other.image[(i+ody) * TILE_SIZE + j+odx] {
				return false
			}
		}
	}

	return true
}

tiles_check_neighbors :: proc(tiles: []Tile) {
	for i := 0; i < len(tiles); i+=1 {
		for j := 0; j < len(tiles); j+=1 {
			for dir in DIRS {
				if tile_check_neighbor(&tiles[i], &tiles[j], dir) {
					append(&tiles[i].neighbors[dir], &tiles[j])
				}
			}
		}
	}
}
