const std = @import("std");
const assert = std.debug.assert;
const expect = std.testing.expect;
const raylib = @import("raylib");

pub fn GameType(
    comptime Type: type,
    windowSize: i32,
    gridSize: i32,
    fps: ?i32,
) type {
    return struct {
        blockSize: i32 = @divTrunc(windowSize, gridSize),
        windowSize: i32 = windowSize,
        backgroundColor: raylib.Color = raylib.Color.gray,
        activatedBlockColor: raylib.Color = raylib.Color.black,
        deactivatedBlockColor: raylib.Color = raylib.Color.white,
        fps: i32 = fps orelse 60,
        gridSize: i32 = gridSize,
        grid: [@as(usize, @intCast(gridSize))]Type = undefined,

        pub fn getCell(self: *@This(), row: Type, col: Type) bool {
            const bitIndex = gridSize - col - 1;
            return (self.grid[@intCast(row)] & (@as(Type, 1) << @intCast(bitIndex))) != 0;
        }

        pub fn getCellWithBitIndex(self: *@This(), row: Type, bitIndex: Type) bool {
            // std.log.err("{any}, {any}\n", .{ row, bitIndex });
            return (self.grid[@intCast(row)] & (@as(Type, 1) << @intCast(bitIndex))) != 0;
        }

        pub fn setCell(self: *@This(), row: Type, col: Type) void {
            const bitIndex = gridSize - col - 1;
            self.grid[@intCast(row)] |= (@as(Type, 1) << @intCast(bitIndex));
        }

        pub fn clearCell(self: *@This(), row: Type, col: Type) void {
            const bitIndex = gridSize - col - 1;
            self.grid[@intCast(row)] &= ~(@as(Type, 1) << @intCast(bitIndex));
        }

        pub fn aliveNeighbours(self: *@This(), row: Type, col: Type) i8 {
            var alive: i8 = 0;
            const bitIndex: Type = @intCast(gridSize - col - 1);

            // cardinal sides
            // left
            if (bitIndex > 0 and self.getCellWithBitIndex(row, bitIndex - 1)) {
                alive += 1;
                // std.debug.print("left alive\n", .{});
            }
            // right
            if (bitIndex < gridSize - 1 and self.getCellWithBitIndex(row, bitIndex + 1)) {
                alive += 1;
                // std.debug.print("right alive\n", .{});
            }
            // top
            if (row > 0 and self.getCellWithBitIndex(row - 1, bitIndex)) {
                alive += 1;
                // std.debug.print("top alive\n", .{});
            }
            // bottom
            if (row < gridSize - 1 and self.getCellWithBitIndex(row + 1, bitIndex)) {
                alive += 1;
                // std.debug.print("bottom alive\n", .{});
            }

            // diagonal sides
            // top-left
            if (row > 0 and bitIndex > 0 and self.getCellWithBitIndex(row - 1, bitIndex - 1)) {
                alive += 1;
                // std.debug.print("top-left alive\n", .{});
            }
            // top-right
            if (row > 0 and bitIndex < gridSize - 1 and self.getCellWithBitIndex(row - 1, bitIndex + 1)) {
                alive += 1;
                // std.debug.print("top-right alive\n", .{});
            }
            // bottom-left
            if (row < gridSize - 1 and bitIndex > 0 and self.getCellWithBitIndex(row + 1, bitIndex - 1)) {
                alive += 1;
                // std.debug.print("bottom-left alive\n", .{});
            }
            // bottom-right
            if (row < gridSize - 1 and bitIndex < gridSize - 1 and self.getCellWithBitIndex(row + 1, bitIndex + 1)) {
                alive += 1;
                // std.debug.print("bottom-right alive\n", .{});
            }

            return alive;
        }

        pub fn updateGrid(self: *@This()) void {
            var nextGrid = self.grid;
            for (0..self.grid.len) |row| {
                for (0..@intCast(self.gridSize)) |col| {
                    const bitIndex: Type = @intCast(gridSize - col - 1);
                    const cellAlive: bool = self.getCellWithBitIndex(row, bitIndex);
                    const alive = self.aliveNeighbours(@intCast(row), @intCast(col));

                    if (cellAlive) {
                        // over and under population
                        if (alive < 2 or alive > 3) {
                            nextGrid[@intCast(row)] &= ~(@as(Type, 1) << @intCast(bitIndex));
                        }
                        if (alive == 2 or alive == 3) {
                            continue;
                        }
                    } else {
                        if (alive == 3) {
                            nextGrid[@intCast(row)] |= (@as(Type, 1) << @intCast(bitIndex));
                        }
                    }
                }
            }
            self.grid = nextGrid;
        }

        pub fn drawCells(self: *@This()) void {
            for (0..self.grid.len) |rowNo| {
                for (0..@intCast(self.gridSize)) |colNo| {
                    raylib.drawRectangle(
                        @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, @intCast(colNo)))),
                        @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, @intCast(rowNo)))),
                        self.blockSize,
                        self.blockSize,
                        if (self.getCell(@as(Type, @intCast(rowNo)), @as(Type, @intCast(colNo)))) self.activatedBlockColor else self.deactivatedBlockColor,
                    );
                }
            }
        }
        pub fn drawGrid(self: *@This()) void {
            for (0..self.grid.len) |row| {
                raylib.drawLine(
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, 0))),
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, @intCast(row)))),
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, self.windowSize))),
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, @intCast(row)))),
                    raylib.Color.light_gray,
                );
            }
            for (0..@intCast(self.gridSize)) |col| {
                raylib.drawLine(
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, @intCast(col)))),
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, 0))),
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, @intCast(col)))),
                    @as(i32, @intCast(@divTrunc(self.windowSize, self.gridSize) * @as(i32, self.windowSize))),
                    raylib.Color.light_gray,
                );
            }
            // for (0..gridSize) |col| {}
        }
    };
}
