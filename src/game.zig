const std = @import("std");
const expect = std.testing.expect;
const raylib = @import("raylib");

pub const Queue = struct {
    data: std.ArrayListUnmanaged(raylib.Vector2).init,
};

pub const CellState = enum {
    Alive,
    OneGenDead,
    TwoGenDead,
    LongDead,
};

pub const Cell = struct {
    x: usize,
    y: usize,
    cellState: CellState = CellState.LongDead,
    pub fn color(self: *const Cell) raylib.Color {
        switch (self.cellState) {
            CellState.Alive => {
                return raylib.Color.black;
            },
            CellState.OneGenDead => {
                return raylib.Color.blue;
            },
            CellState.TwoGenDead => {
                return raylib.Color.sky_blue;
            },
            CellState.LongDead => {
                return raylib.Color.white;
            },
        }
    }
};

pub const Game = struct {
    windowHeight: usize = 1000,
    windowWidth: usize = 1000,
    gridWidth: usize = 100,
    gridHeight: usize = 100,
    fps: i32 = 10,
    blockSize: usize = 10,
    gameState: std.ArrayList(Cell) = undefined,
    nextGen: std.ArrayList(Cell) = undefined,
    updatedCells: std.ArrayList(raylib.Vector2) = undefined,

    pub fn init(
        windowHeight: ?usize,
        windowWidth: ?usize,
        gridHeight: ?usize,
        gridWidth: ?usize,
        blockSize: ?usize,
        fps: ?i32,
        allocator: *std.mem.Allocator,
    ) !Game {
        const gridH: usize = gridHeight orelse 100;
        const gridW: usize = gridWidth orelse 100;
        var gameState: std.ArrayList(Cell) = try std.ArrayList(Cell).initCapacity(allocator.*, gridH * gridW);
        var nextGen: std.ArrayList(Cell) = try std.ArrayList(Cell).initCapacity(allocator.*, gridH * gridW);

        for (0..gridH) |rowIdx| {
            for (0..gridW) |colIdx| {
                try gameState.append(Cell{
                    .y = rowIdx,
                    .x = colIdx,
                    .cellState = CellState.LongDead,
                });
                try nextGen.append(Cell{
                    .y = rowIdx,
                    .x = colIdx,
                    .cellState = CellState.LongDead,
                });
            }
        }
        return Game{
            .windowHeight = windowHeight orelse 1000,
            .windowWidth = windowWidth orelse 1000,
            .gridHeight = gridH,
            .gridWidth = gridW,
            .fps = fps orelse 10,
            .blockSize = blockSize orelse 10,
            .gameState = gameState,
        };
    }

    pub fn deinit(self: *Game) void {
        self.gameState.deinit();
    }

    pub fn getCellState(self: *Game, y: usize, x: usize) CellState {
        return self.gameState.items[(y * self.gridWidth) + x].cellState;
    }

    pub fn drawAll(self: *Game) void {
        for (0..self.gridHeight) |rowIdx| {
            for (0..self.gridWidth) |colIdx| {
                const index = (rowIdx * self.gridWidth) + colIdx;
                const positionX: i32 = @intCast(rowIdx * self.blockSize);
                const positionY: i32 = @intCast(colIdx * self.blockSize);
                raylib.drawRectangle(positionX, positionY, @as(i32, @intCast(self.blockSize)), @as(i32, @intCast(self.blockSize)), self.gameState.items[index].color());
            }
        }
    }

    // TODO: implement a function to only draw updated cells
    // pub fn drawUpdated(self: *Game) void {}

    pub fn drawGrid(self: *Game) void {
        for (0..self.gridHeight) |y| {
            raylib.drawLine(0, @as(i32, @intCast(y * self.blockSize)), @as(i32, @intCast(self.windowWidth)), @as(i32, @intCast(y * self.blockSize)), raylib.Color.light_gray);
        }
        for (0..self.gridWidth) |x| {
            raylib.drawLine(@as(i32, @intCast(x * self.blockSize)), 0, @as(i32, @intCast(x * self.blockSize)), @as(i32, @intCast(self.windowHeight)), raylib.Color.light_gray);
        }
    }

    pub fn aliveNeighbours(self: *Game, y: usize, x: usize) i8 {
        var alive: i8 = 0;

        // checks cell on the left
        if (x > 0 and self.getCellState(y, x - 1) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the right
        if (x < self.gridWidth - 1 and self.getCellState(y, x + 1) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the top
        if (y > 0 and self.getCellState(y - 1, x) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the bottom
        if (y < self.gridHeight - 1 and self.getCellState(y + 1, x) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the top-left
        if (y > 0 and x > 0 and self.getCellState(y - 1, x - 1) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the top-right
        if (y > 0 and x < self.gridWidth - 1 and self.getCellState(y - 1, x + 1) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the bottom-left
        if (y < self.gridHeight - 1 and x > 0 and self.getCellState(y + 1, x - 1) == CellState.Alive) {
            alive += 1;
        }
        // checks cell on the bottom-right
        if (y < self.gridHeight - 1 and x < self.gridWidth - 1 and self.getCellState(y + 1, x + 1) == CellState.Alive) {
            alive += 1;
        }

        return alive;
    }

    // sets the cell at coordinates (x,y) to recently Dead (i.e. OneGenDead)
    pub fn killCell(self: *Game, y: usize, x: usize) void {
        const index = (y * self.gridWidth) + x;
        self.gameState.items[index].cellState = CellState.OneGenDead;
    }

    // sets the cell at coordinates (x,y) to alive
    pub fn resurrectCell(self: *Game, y: usize, x: usize) void {
        const index = (y * self.gridWidth) + x;
        self.gameState.items[index].cellState = CellState.Alive;
    }

    // updated the cell at coordinates (x, y) based on its neighboring cells
    // pub fn updateCell(self: *Game, y: usize, x: usize) void {
    //     const alive = self.aliveNeighbours(y, x);
    //     const index = (y * self.gridWidth) + x;
    //
    //     if (self.gameState.items[index].cellState == CellState.Alive) {
    //         // over and under population
    //         if (alive < 2 or alive > 3) {
    //             self.nextGen.items[index].cellState = CellState.OneGenDead;
    //         }
    //     } else {
    //         if (alive == 3) {
    //             self.nextGen.items[index].cellState = CellState.Alive;
    //         } else if (self.gameState.items[index].cellState == CellState.OneGenDead) {
    //             self.nextGen.items[index].cellState = CellState.TwoGenDead;
    //         } else if (self.gameState.items[index].cellState == CellState.TwoGenDead) {
    //             self.nextGen.items[index].cellState = CellState.LongDead;
    //         }
    //     }
    // }

    // updated all cell in the next generation game state based on
    // their neighboring cells in the current generation
    pub fn updateAll(self: *Game) !void {
        const nextGrid = try self.gameState.clone();
        for (0..self.gridHeight) |y| {
            for (0..self.gridWidth) |x| {
                const alive = self.aliveNeighbours(y, x);
                const index = (y * self.gridWidth) + x;

                if (self.gameState.items[index].cellState == CellState.Alive) {
                    // over and under population
                    if (alive < 2 or alive > 3) {
                        nextGrid.items[index].cellState = CellState.OneGenDead;
                    }
                } else {
                    if (alive == 3) {
                        nextGrid.items[index].cellState = CellState.Alive;
                    } else if (self.gameState.items[index].cellState == CellState.OneGenDead) {
                        nextGrid.items[index].cellState = CellState.TwoGenDead;
                    } else if (self.gameState.items[index].cellState == CellState.TwoGenDead) {
                        nextGrid.items[index].cellState = CellState.LongDead;
                    }
                }
            }
        }
        self.gameState.deinit();
        self.gameState = nextGrid;
    }
};
