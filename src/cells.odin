package main

import "core:slice"
import "core:sort"
import "core:math/rand"
import rl "vendor:raylib"

Cell :: struct {
	collapsed: bool,
	checked: bool,
	options: [dynamic]^Tile,
}

grid_prev: []Cell
grid_buf: []Cell
grid: []Cell

grid_copy :: proc(dst: []Cell, src: []Cell) {
	for i := 0; i < len(src); i+=1 {
		dst[i].collapsed = src[i].collapsed
		dst[i].checked = src[i].checked

		resize(&dst[i].options, 0)
		for option in src[i].options {
			append(&dst[i].options, option)
		}
	}
}

cell_collapse :: proc(this: ^Cell) {
	//if len(this.options) == 0 { return }

	if len(this.options) == 0 {
		grid_copy(grid, grid_prev)
		cnt = 0
		return
	}

	rind := rand.uint32() % u32(len(this.options))
	chosen := this.options[rind]
	resize(&this.options, 0)
	append(&this.options, chosen)
	this.collapsed = true
}

valid_options: [dynamic]^Tile

cell_check_options :: proc(this, other: ^Cell, dir: int) -> bool {
	if this.collapsed { return false }

	resize(&valid_options, 0)

	for option in other.options {
		for neighbor in option.neighbors[dir] {
			append(&valid_options, neighbor)
		}
	}

	for i := 0; i < len(this.options); i+=1 {
		if !slice.contains(valid_options[:], this.options[i]) {
			unordered_remove(&this.options, i); i-=1
		}
	}

	if len(this.options) == 0 {
		grid_copy(grid, grid_prev)
		cnt = 0
		return false
	}

	return true
}

grid_init :: proc(tiles: []Tile) {
	for &tile in grid {
		tile.options = make([dynamic]^Tile, len(tiles), len(tiles))

		for i := 0; i < len(tiles); i+=1 {
			tile.collapsed = false
			tile.checked = false
			tile.options[i] = &tiles[i]
		}
	}
}

grid_reduce_entropy :: proc(w, h, x, y, depth: int) {
	if depth >= DEPTH_MAX { return }

	if grid[y * w + x].checked { return }
	grid[y * w + x].checked = true

	if x > 0 {
		if cell_check_options(&grid[(y) * w + x-1], &grid[(y) * w + x], LEFT) {
			grid_reduce_entropy(w, h, x-1, y, depth + 1)
		}
	}

	if x < w-1 {
		if cell_check_options(&grid[(y) * w + x+1], &grid[(y) * w + x], RIGHT) {
			grid_reduce_entropy(w, h, x+1, y, depth + 1)
		}
	}

	if y > 0 {
		if cell_check_options(&grid[(y-1) * w + x], &grid[(y) * w + x], UP) {
			grid_reduce_entropy(w, h, x, y-1, depth + 1)
		}
	}

	if y < h-1 {
		if cell_check_options(&grid[(y+1) * w + x], &grid[(y) * w + x], DOWN) {
			grid_reduce_entropy(w, h, x, y+1, depth + 1)
		}
	}

	return
}

min_entropy_cells: [dynamic][2]int

grid_wfc :: proc(w, h: int) {
	for i := 0; i < w * h; i+=1 {
		grid[i].checked = false
	}

	resize(&min_entropy_cells, 0)

	min_entropy := 9999
	for i := 0; i < h; i+=1 {
		for j := 0; j < w; j+=1 {
			options_cnt := len(grid[i*w+j].options)
			if options_cnt < min_entropy && !grid[i*w+j].collapsed && options_cnt != 0 {
				min_entropy = options_cnt 
			}
		}
	}

	for i := 0; i < h; i+=1 {
		for j := 0; j < w; j+=1 {
			if len(grid[i*w+j].options) == min_entropy && !grid[i*w+j].collapsed {
				append(&min_entropy_cells, [2]int{i, j})
			}
		}
	}

	if len(min_entropy_cells) == 0 {
		return
	}

	rind := int(rand.int31() % i32(len(min_entropy_cells)))
	cell := min_entropy_cells[rind]
	cell_collapse(&grid[cell[0] * w + cell[1]])

	grid_reduce_entropy(w, h, cell[1], cell[0], 0)
}
