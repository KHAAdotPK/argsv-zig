### argsv-zig
A Zig command line argument processing library

#### Example 1

```zig
const std = @import("std");
const Argsv = @import("argsv");

const commands = "h,-h,(Displays the help screen)\nv,-v,verbose,(Does the detailed output)\nf,-f,(This option expects a full path of the file)";

// !void: Returns nothing on success, but can return an error.
// You can also explicitly state the error set. For example, MyError!void means the function can only return errors defined in MyError or a void value.
// In the absence of explicit MyError, the compiler will infer the error set based on the return statements in the function.
pub fn main() !void {

    // Boiler plate code
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var arenaAllocator = arena.allocator();

    // Instantiate command line processor
    var argsv = Argsv.Argsv.new(&arenaAllocator);
    // This line is causig the compile time error.....
    try argsv.build(commands);
    std.debug.print("Argc = {} \n", .{argsv.getArgc()});
    argsv.traverse();
    
    std.debug.print("Number of common arguments = {}\n", .{argsv.getCommonArgc()});

    // Returns an instance/s of Argsv for help command line option 
    var argsvForHelp = argsv.find(commands, "h");
    std.debug.print("Length(Length of linked list a.k.a total types of command line options) = {} \n", .{argsvForHelp.getLength()});
    argsvForHelp.traverse();
    //std.debug.print("Help = {s} \n", .{argsvForHelp.help(commands)});
    //std.debug.print("Help = {s} \n", .{argsvForHelp.help(commands)});

    std.debug.print("Help = {s} \n", .{argsvForHelp.help(commands)});

    // Returns an instance/s of Argsv for verbose command line option 
    var argsvForVerbose = argsv.find(commands, "v");
    std.debug.print("Length(Length of linked list a.k.a total types of command line options) = {} \n", .{argsvForVerbose.getLength()});
    argsvForVerbose.traverse();

    std.debug.print("Help = {s} \n", .{argsvForVerbose.help(commands)});

    // Returns an instance/s of Argsv for some command line option which is not given 
    var argsvForNotGiven = argsv.find(commands, "NotGiven");
    std.debug.print("Length(Length of linked list a.k.a total types of command line options) = {} \n", .{argsvForNotGiven.getLength()});
    argsvForNotGiven.traverse();

    while (argsv.nextCommonOption()) {
        
        std.debug.print(" HELLO WORLD \n", .{});

        const message = try argsv.getCommonOption();

        std.debug.print("--> {s} \n", .{message});
    }

    while (argsv.next() == true) {

    std.debug.print("-- \n", .{});

    }

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
```

#### Example 2

```zig
const std = @import("std");
const Argsv = @import("argsv");

const commands = "h,-h,(Displays the help screen)\nv,-v,verbose,(Does the detailed output)\nf,-f,(This option expects a full path of the file)";

// !void: Returns nothing on success, but can return an error.
// You can also explicitly state the error set. For example, MyError!void means the function can only return errors defined in MyError or a void value.
// In the absence of explicit MyError, the compiler will infer the error set based on the return statements in the function.
pub fn main() !void {

    // Boiler plate code

    // 1. Setup Allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var arenaAllocator = arena.allocator();

    // 2. GET ARGV / ARGC EQUIVALENT
    // argsAlloc returns a slice ([][]const u8)
    const args = try std.process.argsAlloc(arenaAllocator);
    // Note: Since we use Arena, we don't strictly need argsFree, 
    // but it's good practice.
    defer std.process.argsFree(arenaAllocator, args);

    //const argc = args.len;     // argc equivalent
    const argv = args;         // argv equivalent (can access as argv[0], etc.)

    // Instantiate command line processor
    var argsv = Argsv.Argsv.new(&arenaAllocator);   

    argsv.build(commands) catch |err| switch (err) {
        error.OutOfMemory => return error.OutOfMemory,
        error.InvalidCmdLine => return error.InvalidCmdLine,
    };

    var argsvForFile = argsv.find(commands, "-f"); 

    var fName: []const u8 = "";

    if (argsvForFile.index() != 0) {
        if (argsvForFile.n() > 1) {
            fName = argv[argsvForFile.index() + 1];
        } else {
            std.debug.print("{s}\n", .{argsvForFile.help(commands)});            
            return;
        }
    }

    std.debug.print("{s}\n", .{fName});

    argsvForFile.traverse();    
} 
```

### License
This project is governed by a license, the details of which can be located in the accompanying file named 'LICENSE.' Please refer to this file for comprehensive information.
