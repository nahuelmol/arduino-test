const std       = @import("std");
const arduino   = @import("arduino");
const windows   = std.os.windows;

const HANDLE    = windows.HANDLE;
const DWORD     = windows.DWORD;
const BOOL      = windows.BOOL;
const INVALID_HANDLE_VALUE = @as(HANDLE, @ptrFromInt(std.math.maxInt(usize)));

const DCB = extern struct {
    DCBlength: DWORD,
    BaudRate: DWORD,
    flags: DWORD,
    wReserved: u16,
    XonLim: u16,
    XoffLim: u16,
    ByteSize: u8,
    Parity: u8,
    StopBits: u8,
    XonChar: u8,
    XoffChar: u8,
    ErrorChar: u8,
    EofChar: u8,
    EvtChar: u8,
    wReserved1: u16,
};

const COMMTIMEOUTS = extern struct {
    ReadIntervalTimeout: DWORD,
    ReadTotalTimeoutMultiplier: DWORD,
    ReadTotalTimeoutConstant: DWORD,
    WriteTotalTimeoutMultiplier: DWORD,
    WriteTotalTimeoutConstant: DWORD,
};

extern "kernel32" fn CreateFileA(
    lpFileName: [*:0]const u8,
    dwDesiredAccess: DWORD,
    dwShareMode: DWORD,
    lpSecurityAttributes: ?*anyopaque,
    dwCreationDisposition: DWORD,
    dwFlagsAndAttributes: DWORD,
    hTemplateFile: ?HANDLE,
) callconv(.winapi) HANDLE;

extern "kernel32" fn CloseHandle(
    hObject: HANDLE,
) callconv(.winapi) BOOL;

extern "kernel32" fn GetCommState(
    hFile: HANDLE,
    lpDCB: *DCB,
) callconv(.winapi) BOOL;

extern "kernel32" fn SetCommState(
    hFile: HANDLE,
    lpDCB: *DCB,
) callconv(.winapi) BOOL;

extern "kernel32" fn SetCommTimeouts(
    hFile: HANDLE,
    lpCommTimeouts: *const COMMTIMEOUTS,
) callconv(.winapi) BOOL;

extern "kernel32" fn ReadFile(
    hFile: HANDLE,
    lpBuffer: [*]u8,
    nNumberOfBytesToRead: DWORD,
    lpNumberOfBytesRead: *DWORD,
    lpOverlapped: ?*anyopaque,
) callconv(.winapi) BOOL;


pub fn main() void {
    const port_name = "\\\\.\\COM5";
    std.debug.print("opening port: {s}", .{port_name});

    const handle = CreateFileA(
        "COM5",
        0x80000000,
        0,
        null,
        3,
        0,
        null,
    );
    if (handle == INVALID_HANDLE_VALUE) {
        std.debug.print("Error opening port\n", .{});
        return;
    }
    defer _ = CloseHandle(handle);

    var dcb: DCB = undefined;
    dcb.DCBlength = @sizeOf(DCB);

    if (GetCommState(handle, &dcb) == 0) {
        std.debug.print("GetCommState failed\n", .{});
        return;
    }

    dcb.BaudRate = 9600;
    dcb.ByteSize = 8;
    dcb.Parity = 0;
    dcb.StopBits = 0;

    if (SetCommState(handle, &dcb) == 0) {
        std.debug.print("SetCommState failed\n", .{});
        return;
    }

    const timeouts = COMMTIMEOUTS{
        .ReadIntervalTimeout = 50,
        .ReadTotalTimeoutMultiplier = 0,
        .ReadTotalTimeoutConstant = 100,
        .WriteTotalTimeoutMultiplier = 0,
        .WriteTotalTimeoutConstant = 100,
    };

    if (SetCommTimeouts(handle, &timeouts) == 0) {
        std.debug.print("SetCommTimeouts failed\n", .{});
        return;
    }

    std.debug.print("\nlistening on COM5 (9600 8N1)\n\n", .{});

    var buffer: [128]u8 = undefined;

    while (true) {
        var bytes_read: DWORD = 0;

        const success = ReadFile(
            handle,
            &buffer,
            buffer.len,
            &bytes_read,
            null,
        );

        if (success == 0) {
            std.debug.print("ReadFile failed\n", .{});
            return;
        }

        for (buffer[0..bytes_read]) |byte| {
            if(!std.ascii.isPrint(byte)){
                continue;
            } else {
                if(byte == 'V') {
                    std.debug.print("\n", .{});
                }
                std.debug.print("{c}", .{byte});
            }
        }
    }
}

