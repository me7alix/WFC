package main

import rl "vendor:raylib"

TILE_SIZE :: 3
DEPTH_MAX :: 7
DIM: i32 = 15

RIGHT :: 0
LEFT  :: 1
UP	  :: 2
DOWN  :: 3

DIRS :: []int{
	RIGHT, LEFT,
	UP, DOWN,
}

cnt := 0
main :: proc() {
	screen_width, screen_height: i32 = 600, 600

	rl.SetTraceLogLevel(rl.TraceLogLevel.NONE)
	rl.SetTargetFPS(60)

	rl.InitWindow(screen_width, screen_height, "Wave function collapse")
	defer rl.CloseWindow()

	src_img := rl.LoadImage("./samples/city.png")
	defer rl.UnloadImage(src_img)

	valid_options = make([dynamic]^Tile)
	defer delete(valid_options)

	min_entropy_cells = make([dynamic][2]int)
	defer delete(min_entropy_cells)

	tiles := tiles_from_image(src_img)
	defer delete(tiles)

	tiles_check_neighbors(tiles)

	w := int(screen_height / DIM)
	h := int(screen_width / DIM) 

	grid = make([]Cell, w * h)
	defer delete(grid)
	grid_init(tiles)
	
	grid_buf = make([]Cell, w * h)
	defer delete(grid_prev)

	grid_prev = make([]Cell, w * h)
	defer delete(grid_prev)

	grid_copy(grid_buf, grid)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLUE)

		if cnt % 180  == 0 {
			grid_copy(grid_prev, grid_buf)
			grid_copy(grid_buf, grid)
		}

		cnt += 1
		grid_wfc(w, h)

		grid_draw(grid, i32(w), i32(h), DIM)
		rl.EndDrawing()
	}
}
