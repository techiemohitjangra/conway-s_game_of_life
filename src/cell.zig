const raylib = @import("raylib");

pub const Cell = enum(u2) {
    const Self = @This();
    LongDead=0,
    Alive,
    OneGenDead,
    TwoGenDead,

    pub fn color(self: Self) raylib.Color {
        switch (self) {
            .Alive => {
                return raylib.Color.black;
            },
            .OneGenDead => {
                const powder_blue = raylib.Color{
                    .r = 192,
                    .g = 220,
                    .b = 255,
                    .a = 255,
                };
                return powder_blue;
            },
            .TwoGenDead => {
                const light_blue_gray = raylib.Color{
                    .r = 202,
                    .g = 204,
                    .b = 245,
                    .a = 255,
                };
                return light_blue_gray;
            },
            .LongDead => {
                return raylib.Color.white;
            },
        }
    }
};
