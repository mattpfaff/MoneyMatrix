package money_matrix

import "core:fmt"
import "core:math/rand"
import k2 "karl2d"

gameboard: [100]i32
score1: i32
score2: i32
playerTurn: bool
activeRowCol: int

tile_width: f32
tile_height: f32
SPACER :: 5

main :: proc() {
    init()
    for step() {}
    shutdown()
}

init :: proc() {
    k2.init(1280, 720, "Money Matrix - Can You Beat The Bot?", { window_mode = .Windowed_Resizable })

    tile_width = cast(f32)k2.get_screen_width() / 14
    tile_height = cast(f32)k2.get_screen_height() / 12

    gameboard = [100]i32{
        0       = 100000,
        1       = 50000,
        2       = 25000,
        3..=4   = 10000,
        5..=15  = 1000,      
        16..=32 = 500,      
        33..=60 = 100,      
        61..=81 = -100,
        82..=92 = -500,
        93..=95 = -1000,
        96..=97 = -5000,
        98      = -15000,
        99      = -25000,
    }

    index: u32
    temp: i32

    for j in 0..<3 {
        for i := 99; i > 0; i -= 1 {
            index = rand.uint32_max(cast(u32)i)
            temp = gameboard[index]
            gameboard[index] = gameboard[i]
            gameboard[i] = temp
        }
    }

    playerTurn = true
    activeRowCol = 0
}

step :: proc() -> bool {
    if !k2.update() {
        return false
    }

    k2.clear(k2.BLACK)
    draw()
    k2.present()

    return true
}

draw :: proc() {
	ui_cam := k2.Camera {
		zoom = k2.get_window_scale()
	}
	k2.set_camera(ui_cam)

	full := k2.rect_from_pos_size({0, 0}, k2.screen_to_camera(k2.get_screen_size(), ui_cam))

    BOARD_WIDTH := cast(f32)10 * tile_width + (10 * SPACER)

    panel_size := (cast(f32)k2.get_screen_width() - BOARD_WIDTH) / 2
    yOffset := (cast(f32)k2.get_screen_height() - (tile_height + SPACER) * 10) / 2

    partial, right_panel := k2.rect_split_left(full, cast(f32)k2.get_screen_width() - panel_size, 0)
    left_panel, game_panel := k2.rect_split_left(partial, panel_size, 0)

    left_panel = k2.rect_shrink(left_panel, 20, yOffset*2)
    right_panel = k2.rect_shrink(right_panel, 20, yOffset*2)
    game_panel = k2.rect_shrink(game_panel, 0, yOffset)
    
    backColor: k2.Color
    fontColor: k2.Color
    borderColor: k2.Color

    for y in 0..<10 {
        row := k2.rect_cut_top(&game_panel, tile_height, SPACER)
        for x in 0..<10 {
            cell := k2.rect_cut_left(&row, tile_width, SPACER)
            tile_idx := y * 10 + x

            if gameboard[tile_idx] != 0 {
                if gameboard[tile_idx] > 0 {
                    if gameboard[tile_idx] > 9999 {
                        backColor = k2.LIGHT_GREEN
                        fontColor = k2.BLACK
                    }
                    else {
                        backColor = k2.DARK_GREEN
                        fontColor = k2.WHITE
                    }
                } else {
                    if gameboard[tile_idx] < -1000 {
                        backColor = k2.LIGHT_RED
                        fontColor = k2.BLACK
                    }
                    else {
                        backColor = k2.DARK_RED
                        fontColor = k2.WHITE
                    } 
                }

                active:= false
                if playerTurn {
                    if y == activeRowCol {
                        active = true
                    }
                } else {
                    if x == activeRowCol {
                        active = true
                    }
                }

                mp := k2.get_mouse_position() *  k2.get_window_scale()

                if active {
                    if k2.point_in_rect(mp, cell) {
                        borderColor = k2.YELLOW
                        if k2.mouse_button_went_up(.Left) {
                            if playerTurn {
                                score1 += gameboard[tile_idx]
                                activeRowCol = x
                            } else {
                                score2 += gameboard[tile_idx]
                                activeRowCol = y
                            }
                            gameboard[tile_idx] = 0
                            playerTurn = !playerTurn
                        }
                    } else {
                        borderColor = k2.WHITE
                    }
                }

                k2.draw_rect(cell, backColor);
                if active {
                    k2.draw_rect_outline(cell, 5, borderColor)
                }
                k2.draw_text(fmt.tprintf("$%d", gameboard[tile_idx]), {cell.x + 10, cell.y + 20}, cell.h/3, fontColor)
            }
        }
    }

    k2.draw_text("Player 1", {left_panel.x, left_panel.y}, 20, k2.WHITE)
    k2.draw_text(fmt.tprintf("$%d", score1), {left_panel.x, left_panel.y + 25}, 20, k2.WHITE)
    k2.draw_text("Robot", {right_panel.x, right_panel.y}, 20, k2.WHITE)
    k2.draw_text(fmt.tprintf("$%d", score2), {right_panel.x, right_panel.y + 25}, 20, k2.WHITE)
}

shutdown :: proc() {
    k2.shutdown()
}