const std = @import("std");
const expect = std.testing.expect;
const gameLib = @import("game.zig");
const cell = @import("cell.zig");
var test_allocator = std.testing.allocator;

const testConfig = gameLib.GameConfig{
    .windowHeight = 300,
    .windowWidth = 300,
    .blockSize = 100,
    .fps = 5,
};

test "alive neighbours top-left cell without diagonal" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .Alive;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(0, 0) == 2);
}

test "alive neighbours top-left cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .Alive;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .Alive;
    game.gameState[4] = .Alive;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(0, 0) == 3);
}

test "alive neighbours top cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .LongDead;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .Alive;
    game.gameState[5] = .Alive;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(0, 1) == 5);
}

test "alive neighbours for top-right cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .Alive;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .Alive;
    game.gameState[5] = .Alive;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(0, 2) == 3);
}

test "alive neighbours for left cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .Alive;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .Alive;
    game.gameState[7] = .Alive;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 0) == 5);
}

test "alive neighbours center cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .Alive;
    game.gameState[6] = .Alive;
    game.gameState[7] = .Alive;
    game.gameState[8] = .Alive;

    try expect(game.aliveNeighbours(1, 1) == 8);
}

test "alive neighbours right cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .Alive;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .Alive;
    game.gameState[8] = .Alive;

    try expect(game.aliveNeighbours(1, 2) == 5);
}

test "alive neighbours bottom-left cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .LongDead;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .Alive;
    game.gameState[4] = .Alive;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .Alive;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(2, 0) == 3);
}

test "alive neighbours bottom cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .LongDead;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .Alive;
    game.gameState[4] = .Alive;
    game.gameState[5] = .Alive;
    game.gameState[6] = .Alive;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .Alive;

    try expect(game.aliveNeighbours(2, 1) == 5);
}

test "alive neighbours for bottom-right cell" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .LongDead;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .Alive;
    game.gameState[5] = .Alive;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .Alive;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(2, 2) == 3);
}

test "alive neighbours 0 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .LongDead;
    game.gameState[1] = .LongDead;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 0);
}

test "alive neighbours 1 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .LongDead;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 1);
}

test "alive neighbours 2 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .LongDead;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 2);
}

test "alive neighbours 3 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .LongDead;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 3);
}

test "alive neighbours 4 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .LongDead;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 4);
}

test "alive neighbours 5 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .Alive;
    game.gameState[6] = .LongDead;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 5);
}

test "alive neighbours 6 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .Alive;
    game.gameState[6] = .Alive;
    game.gameState[7] = .LongDead;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 6);
}

test "alive neighbours 7 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .Alive;
    game.gameState[6] = .Alive;
    game.gameState[7] = .Alive;
    game.gameState[8] = .LongDead;

    try expect(game.aliveNeighbours(1, 1) == 7);
}

test "alive neighbours 8 of center" {
    const Game = gameLib.ConwayGame(testConfig);
    var game = Game{};
    game.init();

    game.gameState[0] = .Alive;
    game.gameState[1] = .Alive;
    game.gameState[2] = .Alive;
    game.gameState[3] = .Alive;
    game.gameState[4] = .LongDead;
    game.gameState[5] = .Alive;
    game.gameState[6] = .Alive;
    game.gameState[7] = .Alive;
    game.gameState[8] = .Alive;

    try expect(game.aliveNeighbours(1, 1) == 8);
}
