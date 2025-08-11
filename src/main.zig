const std = @import("std");
const raylib = @import("raylib");
const gameLib = @import("game.zig");

pub const font_path = "/home/mohitjangra/.fonts/UbuntuNerdFont-Regular.ttf";

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
        try raylib.Font.init(font_path),
        "PAUSED",
        128,
        0,
    );

    const textStartX: i16 = @intFromFloat(text.x / 2);
    const textStartY: i16 = @intFromFloat(text.y / 2);

    game.drawAll();
    game.drawGrid();

    while (!raylib.windowShouldClose()) {
        const mousePosition = raylib.getMousePosition();

        if (raylib.isMouseButtonDown(raylib.MouseButton.left)) {
            if (@as(i16, @intFromFloat(mousePosition.x)) > 0 and
                @as(i16, @intFromFloat(mousePosition.x)) < game.windowWidth and
                @as(i16, @intFromFloat(mousePosition.y)) > 0 and
                @as(i16, @intFromFloat(mousePosition.y)) < game.windowHeight)
            {
                const y: u16 = @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.y)), @as(u32, @intCast(game.blockSize))));
                const x: u16 = @intCast(@divTrunc(@as(u32, @intFromFloat(mousePosition.x)), @as(u32, @intCast(game.blockSize))));
                game.resurrectCell(y, x);
            }
        }

        raylib.beginDrawing();
        defer raylib.endDrawing();

        if (!isPaused) {
            raylib.clearBackground(raylib.Color.gray);
            game.drawAll();
        } else {
            raylib.clearBackground(raylib.Color.white);
            game.drawActiveCells();
        }
        game.drawGrid();

        if (raylib.isKeyPressed(raylib.KeyboardKey.space)) {
            isPaused = !isPaused;
            const fps = @intFromBool(!isPaused) * game.fps;
            raylib.setTargetFPS(fps);
        }

        // if paused draw text "PAUSED"
        if (isPaused) {
            raylib.drawText("PAUSED", textStartX, textStartY, 124, raylib.Color.red);
            // if not paused progress game
        } else {
            game.updateAll();
        }

        const fps: i32 = raylib.getFPS();
        raylib.drawText(raylib.textFormat("%i", .{fps}), 0, 0, 36, raylib.Color.black);
    }
}
