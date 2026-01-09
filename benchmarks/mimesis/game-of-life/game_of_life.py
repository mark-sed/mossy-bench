"""
Simulation of Conway's Game of Life.
"""

import random

W, H = 20, 10        # grid size
ALIVE = "█"
DEAD = " "

def random_grid():
    return [[random.choice([0, 1]) for _ in range(W)] for _ in range(H)]

def neighbors(grid, x, y):
    count = 0
    for dy in (-1, 0, 1):
        for dx in (-1, 0, 1):
            if dx == 0 and dy == 0:
                continue
            nx, ny = x + dx, y + dy
            if 0 <= nx < W and 0 <= ny < H:
                count += grid[ny][nx]
    return count

def step(grid):
    new = [[0] * W for _ in range(H)]
    for y in range(H):
        for x in range(W):
            n = neighbors(grid, x, y)
            if grid[y][x] == 1 and n in (2, 3):
                new[y][x] = 1
            elif grid[y][x] == 0 and n == 3:
                new[y][x] = 1
    return new

def draw(title, grid):
    print(title)
    for row in grid:
        print("".join(ALIVE if c else DEAD for c in row))
    print()

grid = random_grid()

draw("=== START ===", grid)

STEPS = 500
for i in range(STEPS):
    grid = step(grid)
    if i == STEPS//2:
        draw(f"=== MIDDLE (step {i}) ===", grid)

draw(f"=== END (step {STEPS}) ===", grid)