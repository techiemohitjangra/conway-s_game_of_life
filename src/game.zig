const std = @import("std");
const raylib = @import("raylib");

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
                const powder_blue = raylib.Color{
                    .r = 192,
                    .g = 220,
                    .b = 255,
                    .a = 255,
                };
                return powder_blue;
            },
            CellState.TwoGenDead => {
                const light_blue_gray = raylib.Color{
                    .r = 202,
                    .g = 204,
                    .b = 245,
                    .a = 255,
                };
                return light_blue_gray;
            },
            CellState.LongDead => {
                return raylib.Color.white;
            },
        }
    }
};

pub const GameConfig = struct {
    windowHeight: ?usize = 1000,
    windowWidth: ?usize = 1000,
    blockSize: ?usize = 10,
    fps: ?i32 = 10,
};

pub fn ConwayGame(config: GameConfig) type {
    const gridWidth: usize = @divFloor(config.windowWidth orelse 1000, config.blockSize orelse 10);
    const gridHeight: usize = @divFloor(config.windowHeight orelse 1000, config.blockSize orelse 10);
    const size = gridHeight * gridWidth;
    return struct {
        windowHeight: usize = config.windowHeight orelse 1000,
        windowWidth: usize = config.windowWidth orelse 1000,
        gridHeight: usize = gridHeight,
        gridWidth: usize = gridWidth,
        blockSize: usize = config.blockSize orelse 10,
        fps: i32 = config.fps orelse 10,
        gameState: [size]Cell = undefined,
        nextGen: [size]Cell = undefined,

        pub fn init(
            self: *@This(),
        ) void {
            for (0..self.gameState.len) |index| {
                self.gameState[index] = Cell{
                    .y = @mod(index, self.gridWidth),
                    .x = @divFloor(index, self.gridWidth),
                    .cellState = CellState.LongDead,
                };
                self.nextGen[index] = Cell{
                    .y = @mod(index, self.gridWidth),
                    .x = @divFloor(index, self.gridWidth),
                    .cellState = CellState.LongDead,
                };
            }
        }

        pub fn getCellState(self: *@This(), y: usize, x: usize) CellState {
            return self.gameState[(y * self.gridWidth) + x].cellState;
        }

        pub fn drawAll(self: *@This()) void {
            for (0..self.gridHeight) |rowIdx| {
                for (0..self.gridWidth) |colIdx| {
                    const index = (rowIdx * self.gridWidth) + colIdx;
                    const positionX: i32 = @intCast(rowIdx * self.blockSize);
                    const positionY: i32 = @intCast(colIdx * self.blockSize);
                    raylib.drawRectangle(positionX, positionY, @as(i32, @intCast(self.blockSize)), @as(i32, @intCast(self.blockSize)), self.gameState[index].color());
                }
            }
        }

        // TODO: implement a function to only draw updated cells
        // pub fn drawUpdated(self: *@This()) void {}

        pub fn drawGrid(self: *@This()) void {
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

        pub fn aliveNeighbours(self: *@This(), y: usize, x: usize) i8 {
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
        pub fn killCell(self: *@This(), y: usize, x: usize) void {
            const index = (y * self.gridWidth) + x;
            self.gameState[index].cellState = CellState.OneGenDead;
        }

        // sets the cell at coordinates (x,y) to alive
        pub fn resurrectCell(self: *@This(), y: usize, x: usize) void {
            const index = (y * self.gridWidth) + x;
            self.gameState[index].cellState = CellState.Alive;
        }

        // updated the cell at coordinates (x, y) based on its neighboring cells
        // pub fn updateCell(self: *@This(), y: usize, x: usize) void {
        //     const alive = self.aliveNeighbours(y, x);
        //     const index = (y * self.gridWidth) + x;
        //
        //     if (self.gameState[index].cellState == CellState.Alive) {
        //         // over and under population
        //         if (alive < 2 or alive > 3) {
        //             self.nextGen[index].cellState = CellState.OneGenDead;
        //         }
        //     } else {
        //         if (alive == 3) {
        //             self.nextGen[index].cellState = CellState.Alive;
        //         } else if (self.gameState[index].cellState == CellState.OneGenDead) {
        //             self.nextGen[index].cellState = CellState.TwoGenDead;
        //         } else if (self.gameState[index].cellState == CellState.TwoGenDead) {
        //             self.nextGen[index].cellState = CellState.LongDead;
        //         }
        //     }
        // }

        // updated all cell in the next generation game state based on
        // their neighboring cells in the current generation
        pub fn updateAll(self: *@This()) !void {
            var nextGrid = self.*.gameState;
            for (0..self.gridHeight) |y| {
                for (0..self.gridWidth) |x| {
                    const alive = self.aliveNeighbours(y, x);
                    const index = (y * self.gridWidth) + x;

                    if (self.gameState[index].cellState == CellState.Alive) {
                        // over and under population
                        if (alive < 2 or alive > 3) {
                            nextGrid[index].cellState = CellState.OneGenDead;
                        }
                    } else {
                        if (alive == 3) {
                            nextGrid[index].cellState = CellState.Alive;
                        } else if (self.gameState[index].cellState == CellState.OneGenDead) {
                            nextGrid[index].cellState = CellState.TwoGenDead;
                        } else if (self.gameState[index].cellState == CellState.TwoGenDead) {
                            nextGrid[index].cellState = CellState.LongDead;
                        }
                    }
                }
            }
            self.gameState = nextGrid;
        }
    };
}
