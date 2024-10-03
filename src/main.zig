const std = @import("std");
const expect = std.testing.expect;
const assert = std.debug.assert;
const raylib = @import("raylib");
const gameObj = @import("game.zig");

pub fn main() !void {
    const Game = gameObj.GameType(u100, 1000, 100, 10);
    var game = Game{};
    // std.debug.print("{any}", .{game});

    raylib.initWindow(game.windowSize, game.windowSize, "Conway's Game of Life");
    defer raylib.closeWindow();

    raylib.setTargetFPS(0);

    var isPaused: bool = false;

    while (!raylib.windowShouldClose()) {
        const mousePosition = raylib.getMousePosition();

        if (raylib.isMouseButtonDown(raylib.MouseButton.mouse_button_left)) {
            if (@as(i32, @intFromFloat(mousePosition.x)) > 0 and
                @as(i32, @intFromFloat(mousePosition.x)) < game.windowSize and
                @as(i32, @intFromFloat(mousePosition.y)) > 0 and
                @as(i32, @intFromFloat(mousePosition.y)) < game.windowSize)
            {
                game.setCell(
                    @as(u7, @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.y)), @as(u32, @intCast(game.blockSize))))),
                    @as(u7, @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.x)), @as(u32, @intCast(game.blockSize))))),
                );
            }
        }

        raylib.beginDrawing();
        defer raylib.endDrawing();

        raylib.clearBackground(game.backgroundColor);
        game.drawCells();
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
            const textStartX: i32 = @intFromFloat(raylib.measureTextEx(
                raylib.Font.init("/home/mohitjangra/.fonts/UbuntuNerdFont-Regular.ttf"),
                "PAUSED",
                128,
                0,
            ).x / 2);
            const textStartY: i32 = @intFromFloat(raylib.measureTextEx(
                raylib.Font.init("/home/mohitjangra/.fonts/UbuntuNerdFont-Regular.ttf"),
                "PAUSED",
                128,
                0,
            ).y / 2);
            raylib.drawText("PAUSED", textStartX, textStartY, 124, raylib.Color.red);
        } else {
            game.updateGrid();
        }

        const fps: i32 = raylib.getFPS();
        raylib.drawText(raylib.textFormat("%i", .{fps}), 0, 0, 36, raylib.Color.black);
    }
}

test "alive neighbours for top-left cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 2), @as(u3, 4), @as(u3, 0) };

    try expect(game.getCellWithBitIndex(0, @intCast(game.gridSize - 0 - 1)) == false);
    try expect(game.getCellWithBitIndex(0, @intCast(game.gridSize - 1 - 1)) == true);
    try expect(game.getCellWithBitIndex(0, @intCast(game.gridSize - 2 - 1)) == false);
    try expect(game.getCellWithBitIndex(1, @intCast(game.gridSize - 0 - 1)) == true);
    try expect(game.getCellWithBitIndex(1, @intCast(game.gridSize - 1 - 1)) == false);
    try expect(game.getCellWithBitIndex(1, @intCast(game.gridSize - 2 - 1)) == false);
    try expect(game.getCellWithBitIndex(2, @intCast(game.gridSize - 0 - 1)) == false);
    try expect(game.getCellWithBitIndex(2, @intCast(game.gridSize - 1 - 1)) == false);
    try expect(game.getCellWithBitIndex(2, @intCast(game.gridSize - 2 - 1)) == false);

    // try expect(game.getCell(0, 1) == true);
    // try expect(game.getCell(0, 2) == false);
    // try expect(game.getCell(1, 0) == true);
    // try expect(game.getCell(1, 1) == false);
    // try expect(game.getCell(1, 2) == false);
    // try expect(game.getCell(2, 0) == false);
    // try expect(game.getCell(2, 1) == false);
    // try expect(game.getCell(2, 2) == false);

    try expect(game.aliveNeighbours(0, 0) == 2);
}

test "alive neighbours top-left cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 2), @as(u3, 6), @as(u3, 0) };

    try expect(game.aliveNeighbours(0, 0) == 3);
}

test "alive neighbours top cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 5), @as(u3, 7), @as(u3, 0) };

    try expect(game.aliveNeighbours(0, 1) == 5);
}

test "alive neighbours for top-right cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 2), @as(u3, 3), @as(u3, 0) };
    try expect(game.aliveNeighbours(0, 2) == 3);
}

test "alive neighbours for left cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 6), @as(u3, 2), @as(u3, 6) };
    try expect(game.aliveNeighbours(1, 0) == 5);
}

test "alive neighbours center cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 7), @as(u3, 5), @as(u3, 7) };

    try expect(game.aliveNeighbours(1, 1) == 8);
}

test "alive neighbours right cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 3), @as(u3, 2), @as(u3, 3) };

    try expect(game.aliveNeighbours(1, 2) == 5);
}

test "alive neighbours bottom-left cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 0), @as(u3, 4), @as(u3, 2) };

    try expect(game.aliveNeighbours(2, 0) == 2);
}

test "alive neighbours bottom cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 0), @as(u3, 7), @as(u3, 5) };

    try expect(game.aliveNeighbours(2, 1) == 5);
}

test "alive neighbours for bottom-right cell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 0), @as(u3, 1), @as(u3, 2) };
    try expect(game.aliveNeighbours(2, 2) == 2);
}

test "alive neighbours 0" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 0), @as(u3, 0), @as(u3, 0) };
    try expect(game.aliveNeighbours(1, 1) == 0);
}

test "alive neighbours 1" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 4), @as(u3, 0), @as(u3, 0) };

    try expect(game.aliveNeighbours(1, 1) == 1);
}

test "alive neighbours 2" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 6), @as(u3, 0), @as(u3, 0) };

    try expect(game.aliveNeighbours(1, 1) == 2);
}

test "alive neighbours 3" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 7), @as(u3, 0), @as(u3, 0) };

    try expect(game.aliveNeighbours(1, 1) == 3);
}

test "alive neighbours 4" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 7), @as(u3, 4), @as(u3, 0) };

    try expect(game.aliveNeighbours(1, 1) == 4);
}

test "alive neighbours 5" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 7), @as(u3, 5), @as(u3, 0) };

    try expect(game.aliveNeighbours(1, 1) == 5);
}

test "alive neighbours 6" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 7), @as(u3, 5), @as(u3, 4) };

    try expect(game.aliveNeighbours(1, 1) == 6);
}

test "alive neighbours 7" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 7), @as(u3, 5), @as(u3, 6) };

    try expect(game.aliveNeighbours(1, 1) == 7);
}

test "alive neighbours 7 with setCell and clearCell" {
    const Game = gameObj.GameType(u3, 300, 3, null);
    var game = Game{};

    game.grid = [_]u3{ @as(u3, 0), @as(u3, 0), @as(u3, 0) };
    // game.grid = [_]u3{ @as(u3, 7), @as(u3, 5), @as(u3, 6) };
    game.setCell(0, 0);
    game.setCell(0, 1);
    game.setCell(0, 2);

    game.setCell(1, 0);
    game.clearCell(1, 1);
    game.setCell(1, 2);

    game.setCell(2, 0);
    game.setCell(2, 1);
    game.clearCell(2, 2);

    try expect(game.aliveNeighbours(1, 1) == 7);
}
