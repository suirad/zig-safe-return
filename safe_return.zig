const std = @import("std");
const typeId = @import("builtin").TypeId;
const testing = std.testing;
const warn = std.debug.warn;


pub inline fn safeReturn(comptime T: type, ptr: T) !T {
    if (@typeId(T) != typeId.Pointer){
        @compileError("Only pointers can be used for safe return");
    }

    const retAddr: usize = @ptrToInt(@returnAddress());
    if (@ptrToInt(&retAddr) > @ptrToInt(ptr) and @ptrToInt(ptr) < retAddr){
        return error.ReturnedPointerToStackVariable;
    }

    return ptr;
}


test "safeReturn with error" {
    var a: u32 = 0;
    const b = &a;
    testing.expectError(error.ReturnedPointerToStackVariable, safeReturn(@typeOf(b), b));
}

test "safeReturn without error" {
    var num: u32 = 0;
    _ = test_without_error(&num);
}

fn test_without_error(num: *u32) !*u32 {
    return try safeReturn(@typeOf(num), num);
}

