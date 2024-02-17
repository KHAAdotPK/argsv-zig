// src/main.zig
// Q@khaa.pk

const std = @import("std");
const Argsv = @import("./lib/argsv/argsv.zig").Argsv;

const commands = "h,-h,(Displays the help screen)\nv,-v,verbose,(Does the detailed output)\n";

pub fn main() !void {
    // Boiler plate ccode to get the command line arguments
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //const gpaAllocator = gpa.allocator();
    //defer _ = gpa.deinit();
    //var args = try std.process.argsWithAllocator(gpaAllocator);
    //defer args.deinit();

    // Boiler plate code
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var arenaAllocator = arena.allocator();

    // Instantiate command line processor
    // TODO, should be made into one function call by the name of Argsv::init()
    //var argsv = try Argsv.new(&arenaAllocator);
    var argsv = Argsv.new(&arenaAllocator);

    //var argsv = try Argsv.new();
    //_ = try argsv.build(&args, commands);
    //_ = try argsv.build(commands);
    argsv.build(commands);
    std.debug.print("Argc = {} \n", .{argsv.getArgc()});
    //_ = try argsv.add();
    argsv.traverse();

    std.debug.print("Number of common arguments = {}\n", .{argsv.getCommonArgc()});

    // Returns an instance/s of Argsv for help command line option
    //var argsvForHelp = try argsv.find(commands, "h");
    var argsvForHelp = argsv.find(commands, "h");
    std.debug.print("Length(Length of linked list a.k.a total types of command line options) = {} \n", .{argsvForHelp.getLength()});
    argsvForHelp.traverse();

    // Returns an instance/s of Argsv for verpose command line option
    //var argsvForVerbose = try argsv.find(commands, "v");
    var argsvForVerbose = argsv.find(commands, "v");
    //std.debug.print("Length = {} \n", .{argsvForVerbose.getLength()});
    std.debug.print("Length(Length of linked list a.k.a total types of command line options) = {} \n", .{argsvForVerbose.getLength()});
    argsvForVerbose.traverse();

    // Returns an instance/s of Argsv for some command line option which is not given
    //var argsvForNotGiven = try argsv.find(commands, "NotGiven");
    var argsvForNotGiven = argsv.find(commands, "NotGiven");
    //std.debug.print("Length = {} \n", .{argsvForNotGiven.getLength()});
    std.debug.print("Length(Length of linked list a.k.a total types of command line options) = {} \n", .{argsvForNotGiven.getLength()});
    argsvForNotGiven.traverse();

    // ----------------------------------------------------------------
    var l: usize = 0;
    var o: usize = 0;
    while (argsv.next() == true) {
        l = l + 1;
        std.debug.print(" 1 ", .{});
        _ = argsv.getArgIndex();
        std.debug.print("Argc = {}:", .{argsv.getArgArgc()});
        //argsv.getArgOptions();

        while (argsv.nextOption() == true) {
            o = o + 1;
            std.debug.print(" - ", .{});

            const arg = try argsv.getArgOption(l, o);

            std.debug.print("{s} ", .{arg});
        }

        o = 0;

        std.debug.print("\n", .{});
    }
}
