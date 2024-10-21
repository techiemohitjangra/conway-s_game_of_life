const std = @import("std");
const raylib = @import("raylib");
const gameLib = @import("game.zig");

pub fn main() !void {
    const Game = gameLib.ConwayGame(gameLib.GameConfig{ .blockSize = 5 });
    var game = Game{};
    game.init();

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
                const y: usize = @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.y)), @as(u32, @intCast(game.blockSize))));
                const x: usize = @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.x)), @as(u32, @intCast(game.blockSize))));
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
