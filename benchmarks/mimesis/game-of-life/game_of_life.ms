d"""
Simulation of Conway's Game of Life.
"""

// Grid size
W = 20
H = 10
ALIVE = "█"
DEAD = " "

fun random_grid() = [[rand_int(0, 1) : _ = 0..W] : __ = 0..H]

fun neighbors(grid, x, y) {
    count = 0
    for (dy : [-1, 0, 1]) {
        for (dx : [-1, 0, 1]) {
            if (dx == 0 && dy == 0)
                continue
            nx = x + dx
            ny = y + dy
            if (0 <= nx && nx < W && 0 <= ny && ny < H)
                count += grid[ny][nx]
        }
    }
    return count
}

fun step(grid) {
    new = [[0] * W : _ = 0..H]
    for (y : 0..H) {
        for (x: 0..W) {
            n = neighbors(grid, x, y)
            if (grid[y][x] == 1 && n in [2, 3])
                new[y][x] = 1
            else if (grid[y][x] == 0 && n == 3)
                new[y][x] = 1
        }
    }
    return new
}

fun draw(title, grid) {
    ~print(title)
    for(row: grid) {
        ~print("".join([ALIVE if(c != 0) else DEAD : c = row]))
    }
    ~print()
}

grid = random_grid()
~draw("=== START ===", grid)

STEPS = 500
for (i : 0..STEPS) {
    grid = step(grid)
    if (i == STEPS/2)
        ~draw(f"=== MIDDLE (step {i}) ===", grid)
}

~draw(f"=== END (step {STEPS}) ===", grid)