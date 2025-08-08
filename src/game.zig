const std = @import("std");
const raylib = @import("raylib");
const cell = @import("cell.zig");

pub const GameConfig = struct {
    windowHeight: ?u16 = 1000,
    windowWidth: ?u16 = 1000,
    blockSize: ?u8 = 10,
    fps: ?i16 = 10,
};

pub fn ConwayGame(config: GameConfig) type {
    const gridWidth: u16 = @divFloor(config.windowWidth orelse 1000, config.blockSize orelse 10);
    const gridHeight: u16 = @divFloor(config.windowHeight orelse 1000, config.blockSize orelse 10);
    const size = gridHeight * gridWidth;
    return struct {
        const Self = @This();
        windowHeight: u16 = config.windowHeight orelse 1000,
        windowWidth: u16 = config.windowWidth orelse 1000,
        gridHeight: u16 = gridHeight,
        gridWidth: u16 = gridWidth,
        blockSize: u8 = config.blockSize orelse 10,
        fps: i16 = config.fps orelse 10,
        gameState: [size]cell.Cell = undefined,
        nextGen: [size]cell.Cell = undefined,

        pub fn init(self: *Self) void {
            for (0..self.gameState.len) |index| {
                self.gameState[index] = .LongDead;
                self.nextGen[index] = .LongDead;
            }
        }

        pub fn getCell(self: *const Self, y: u16, x: u16) cell.Cell {
            return self.gameState[(y * self.gridWidth) + x];
        }

        pub fn drawAll(self: *const Self) void {
            for (0..self.gridHeight) |rowIdx| {
                for (0..self.gridWidth) |colIdx| {
                    const index = (rowIdx * self.gridWidth) + colIdx;
                    const positionX: i32 = @intCast(rowIdx * self.blockSize);
                    const positionY: i32 = @intCast(colIdx * self.blockSize);
                    raylib.drawRectangle(positionX, positionY, @as(i32, @intCast(self.blockSize)), @as(i32, @intCast(self.blockSize)), self.gameState[index].color());
                }
            }
        }

        // draw grid lines
        pub fn drawGrid(self: *const Self) void {
            const light_gray_50 = raylib.Color{
                .r = 200,
                .g = 200,
                .b = 200,
                .a = 122,
            };
            for (0..self.gridHeight) |y| {
                raylib.drawLine(0, @as(i32, @intCast(y * self.blockSize)), @as(i32, @intCast(self.windowWidth)), @as(i32, @intCast(y * self.blockSize)), light_gray_50);
            }
            for (0..self.gridWidth) |x| {
                raylib.drawLine(@as(i32, @intCast(x * self.blockSize)), 0, @as(i32, @intCast(x * self.blockSize)), @as(i32, @intCast(self.windowHeight)), light_gray_50);
            }
        }

        pub fn aliveNeighbours(self: *const Self, y: u16, x: u16) i8 {
            var alive: i8 = 0;

            // checks cell on the left
            if (x > 0 and self.getCell(y, x - 1) == .Alive) {
                alive += 1;
            }
            // checks cell on the right
            if (x < self.gridWidth - 1 and self.getCell(y, x + 1) == .Alive) {
                alive += 1;
            }
            // checks cell on the top
            if (y > 0 and self.getCell(y - 1, x) == .Alive) {
                alive += 1;
            }
            // checks cell on the bottom
            if (y < self.gridHeight - 1 and self.getCell(y + 1, x) == .Alive) {
                alive += 1;
            }
            // checks cell on the top-left
            if (y > 0 and x > 0 and self.getCell(y - 1, x - 1) == .Alive) {
                alive += 1;
            }
            // checks cell on the top-right
            if (y > 0 and x < self.gridWidth - 1 and self.getCell(y - 1, x + 1) == .Alive) {
                alive += 1;
            }
            // checks cell on the bottom-left
            if (y < self.gridHeight - 1 and x > 0 and self.getCell(y + 1, x - 1) == .Alive) {
                alive += 1;
            }
            // checks cell on the bottom-right
            if (y < self.gridHeight - 1 and x < self.gridWidth - 1 and self.getCell(y + 1, x + 1) == .Alive) {
                alive += 1;
            }

            return alive;
        }

        // sets the cell at coordinates (x,y) to recently Dead (i.e. OneGenDead)
        pub fn killCell(self: *Self, y: u16, x: u16) void {
            const index = (y * self.gridWidth) + x;
            self.gameState[index] = .OneGenDead;
        }

        // sets the cell at coordinates (x,y) to alive
        pub fn resurrectCell(self: *Self, y: u16, x: u16) void {
            const index = (y * self.gridWidth) + x;
            self.gameState[index] = .Alive;
        }

        // updated all cell in the next generation game state based on
        // their neighboring cells in the current generation
        pub fn updateAll(self: *Self) void {
            var nextGrid = self.*.gameState;
            for (0..self.gridHeight) |y| {
                for (0..self.gridWidth) |x| {
                    const alive = self.aliveNeighbours(@as(u16, @intCast(y)), @as(u16, @intCast(x)));
                    const index = (@as(u16, @intCast(y)) * self.gridWidth) + @as(u16, @intCast(x));

                    if (self.gameState[index] == .Alive) {
                        // over and under population
                        if (alive < 2 or alive > 3) {
                            nextGrid[index] = .OneGenDead;
                        }
                    } else {
                        if (alive == 3) {
                            nextGrid[index] = .Alive;
                        } else if (self.gameState[index] == .OneGenDead) {
                            nextGrid[index] = .TwoGenDead;
                        } else if (self.gameState[index] == .TwoGenDead) {
                            nextGrid[index] = .LongDead;
                        }
                    }
                }
            }
            self.gameState = nextGrid;
        }
    };
}
