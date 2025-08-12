package main

import "core:math"
import rl "vendor:raylib"

grid_draw :: proc(tiles: []Cell, width, height, sc: i32) {
	for i: i32 = 0; i < height; i+=1 {
		for j: i32 = 0; j < width; j+=1 {
			pos := rl.Vector2{f32(j * sc), f32(i * sc)}
			if len(tiles[i * width + j].options) == 0 {
				rl.DrawRectangle(i32(pos.x), i32(pos.y), sc, sc, rl.MAGENTA)
			} else if tiles[i * width + j].collapsed {
				clr := tiles[i * width + j].options[0].image[(TILE_SIZE*TILE_SIZE-1)/2]
				rl.DrawRectangle(i32(pos.x), i32(pos.y), sc, sc, clr)
			} else {
				clr := [3]int{0, 0, 0}

				for option in tiles[i * width + j].options {
					clr[0] += int(option.image[(TILE_SIZE*TILE_SIZE-1)/2].r)
					clr[1] += int(option.image[(TILE_SIZE*TILE_SIZE-1)/2].g)
					clr[2] += int(option.image[(TILE_SIZE*TILE_SIZE-1)/2].b)
				}

				clr[0] /= len(tiles[i * width + j].options)
				clr[1] /= len(tiles[i * width + j].options)
				clr[2] /= len(tiles[i * width + j].options)

				rl.DrawRectangle(i32(pos.x), i32(pos.y), sc, sc, {u8(clr[0]), u8(clr[1]), u8(clr[2]), 255})
			}
		}
	}
}
