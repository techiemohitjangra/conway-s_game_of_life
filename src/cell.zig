const raylib = @import("raylib");

pub const CellState = enum(u2) {
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
