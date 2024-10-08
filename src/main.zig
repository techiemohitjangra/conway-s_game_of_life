const std = @import("std");
const expect = std.testing.expect;
const raylib = @import("raylib");
const gameObj = @import("game.zig");
var test_allocator = std.testing.allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var allocator = gpa.allocator();

    var game = try gameObj.Game.init(null, null, null, null, null, null, &allocator);
    defer game.deinit();

    raylib.initWindow(@as(i32, @intCast(game.windowWidth)), @as(i32, @intCast(game.windowHeight)), "Conway's Game of Life");
    defer raylib.closeWindow();

    raylib.setTargetFPS(game.fps);

    var isPaused: bool = false;

    // loading font
    const text = raylib.measureTextEx(
        raylib.Font.init("/home/mohitjangra/.fonts/UbuntuNerdFont-Regular.ttf"),
        "PAUSED",
        128,
        0,
    );
    const textStartX: i32 = @intFromFloat(text.x / 2);
    const textStartY: i32 = @intFromFloat(text.y / 2);

    while (!raylib.windowShouldClose()) {
        const mousePosition = raylib.getMousePosition();

        if (raylib.isMouseButtonDown(raylib.MouseButton.mouse_button_left)) {
            if (@as(i32, @intFromFloat(mousePosition.x)) > 0 and
                @as(i32, @intFromFloat(mousePosition.x)) < game.windowWidth and
                @as(i32, @intFromFloat(mousePosition.y)) > 0 and
                @as(i32, @intFromFloat(mousePosition.y)) < game.windowHeight)
            {
                const y = @as(u7, @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.y)), @as(u32, @intCast(game.blockSize)))));
                const x = @as(u7, @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.x)), @as(u32, @intCast(game.blockSize)))));
                game.resurrectCell(x, y);
            }
        }

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(raylib.Color.gray);
        game.drawAll();
        game.drawGrid();

        if (raylib.isKeyPressed(raylib.KeyboardKey.key_space)) {
            isPaused = !isPaused;
            if (isPaused) {
                raylib.setTargetFPS(0);
            } else {
                raylib.setTargetFPS(game.fps);
            }
        }

        if (isPaused) {
            raylib.drawText("PAUSED", textStartX, textStartY, 124, raylib.Color.red);
        } else {
            try game.updateAll();
        }

        const fps: i32 = raylib.getFPS();
        raylib.drawText(raylib.textFormat("%i", .{fps}), 0, 0, 36, raylib.Color.black);
    }
}

test "alive neighbours top-left cell without diagonal" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(0, 0) == 2);
}

test "alive neighbours top-left cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(0, 0) == 3);
}

test "alive neighbours top cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.LongDead;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(0, 1) == 5);
}

test "alive neighbours for top-right cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(0, 2) == 3);
}

test "alive neighbours for left cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.Alive;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 0) == 5);
}

test "alive neighbours center cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.Alive;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.Alive;

    try expect(game.aliveNeighbours(1, 1) == 8);
}

test "alive neighbours right cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.Alive;

    try expect(game.aliveNeighbours(1, 2) == 5);
}

test "alive neighbours bottom-left cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.LongDead;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(2, 0) == 3);
}

test "alive neighbours bottom cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.LongDead;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.Alive;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.Alive;

    try expect(game.aliveNeighbours(2, 1) == 5);
}

test "alive neighbours for bottom-right cell" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.LongDead;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.Alive;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(2, 2) == 3);
}

test "alive neighbours 0 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.LongDead;
    game.gameState.items[1].cellState = gameObj.CellState.LongDead;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 0);
}

test "alive neighbours 1 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.LongDead;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 1);
}

test "alive neighbours 2 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.LongDead;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 2);
}

test "alive neighbours 3 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.LongDead;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 3);
}

test "alive neighbours 4 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.LongDead;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 4);
}

test "alive neighbours 5 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.LongDead;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 5);
}

test "alive neighbours 6 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.Alive;
    game.gameState.items[7].cellState = gameObj.CellState.LongDead;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 6);
}

test "alive neighbours 7 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.Alive;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.LongDead;

    try expect(game.aliveNeighbours(1, 1) == 7);
}

test "alive neighbours 8 of center" {
    var game = try gameObj.Game.init(300, 300, 3, 3, 100, 1, &test_allocator);
    defer game.deinit();

    game.gameState.items[0].cellState = gameObj.CellState.Alive;
    game.gameState.items[1].cellState = gameObj.CellState.Alive;
    game.gameState.items[2].cellState = gameObj.CellState.Alive;
    game.gameState.items[3].cellState = gameObj.CellState.Alive;
    game.gameState.items[4].cellState = gameObj.CellState.LongDead;
    game.gameState.items[5].cellState = gameObj.CellState.Alive;
    game.gameState.items[6].cellState = gameObj.CellState.Alive;
    game.gameState.items[7].cellState = gameObj.CellState.Alive;
    game.gameState.items[8].cellState = gameObj.CellState.Alive;

    try expect(game.aliveNeighbours(1, 1) == 8);
}
