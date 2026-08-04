// Generated from SDL3_net/SDL_net.h by sdl-zig-codegen. Do not edit.

const std = @import("std");
const builtin = @import("builtin");
pub const c = @import("sdl3_net_c");
const sdl = @import("sdl");
const root = @This();

/// A tri-state for asynchronous operations.
///
/// Lots of tasks in SDL_net are asynchronous, as they can't complete until data passes over a network at some murky future point in time.
/// This includes sending data over a stream socket, resolving a hostname, connecting to a remote system, and other tasks.
/// The library never blocks on tasks that take time to complete, with the exception of functions named "Wait", which are intended to do nothing but block until a task completes. Functions that are attempting to do something that might block, or are querying the status of a task in-progress, will return a Status, so an app can see if a task completed, and its final outcome.
///
/// - **Since:** This enum is available since SDL_net 3.0.0.
pub const Status = enum(c.NET_Status) {
    /// Async operation complete, result was failure.
    failure = @intCast(c.NET_FAILURE),
    /// Async operation is still in progress, check again later.
    waiting = @intCast(c.NET_WAITING),
    /// Async operation complete, result was success.
    success = @intCast(c.NET_SUCCESS),
    _,
};

/// SDL handle `Address`.
pub const Address = opaque {};

/// The data provided for new incoming packets from DatagramSocket.receive().
///
/// - **Since:** This datatype is available since SDL_net 3.0.0.
/// - **See also:** DatagramSocket.receive
/// - **See also:** destroyDatagram
pub const Datagram = extern struct {
    /// Field `addr`.
    addr: ?*Address,
    /// Field `port`.
    port: u16,
    /// Field `buf`.
    buf: ?*u8,
    /// Field `buflen`.
    buflen: c_int,
};

/// SDL handle `DatagramSocket`.
pub const DatagramSocket = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Dispose of a previously-created datagram socket.
    ///
    /// This will *abandon* any data queued for sending that hasn't made it to the socket. If you need this data to arrive, you should wait for confirmation from the remote computer in some form that you devise yourself. Queued data is not guaranteed to arrive even if the library made efforts to transmit it here.
    /// Any data that has arrived from the remote end of the connection that hasn't been read yet is lost.
    ///
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** createDatagramSocket
    /// - **See also:** DatagramSocket.send
    /// - **See also:** DatagramSocket.receive
    /// This method invalidates the handle after SDL_net consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.NET_DestroyDatagramSocket(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Receive a new packet that a remote system sent to a datagram socket.
    ///
    /// Datagram sockets send packets of data. They either arrive as complete packets or they don't arrive at all, so you'll never receive half a packet.
    /// This call never blocks; if no new data is available at the time of the call, it returns true immediately. The caller can try again later.
    /// On a successful call to this function, it returns true, even if no new packets are available, so you should check for a successful return and a non-NULL value in `*dgram` to decide if a new packet is available.
    /// You must pass received packets to destroyDatagram when you are done with them. If you want to save the sender's address past this time, it is safe to call refAddress() on the address and hold onto the pointer, so long as you call unrefAddress() on it when you are done with it.
    /// Since datagrams can arrive from any address or port on the network without prior warning, this information is available in the Datagram object that is provided by this function, and this is the only way to know who to reply to. Even if you aren't acting as a "server," packets can still arrive at your socket if someone sends one.
    /// If there's a fatal error, this function will return false. Datagram sockets generally won't report failures, because there is no state like a "connection" to fail at this level, but may report failure for unrecoverable system-level conditions; once a datagram socket fails, you should assume it is no longer usable and should destroy it with SDL_DestroyDatagramSocket (C API outside this module)().
    ///
    /// - **Parameters:**
    ///   - `dgram`: a pointer to the datagram packet pointer.
    ///
    /// - **Returns:** true if data sent or queued for transmission, false on failure; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** DatagramSocket.send
    /// - **See also:** destroyDatagram
    pub inline fn receive(self: @This(), dgram: ?*?*Datagram) bool {
        return c.NET_ReceiveDatagram(@ptrCast(self.value), @ptrCast(dgram));
    }

    /// Send a new packet over a datagram socket to a remote system.
    ///
    /// Datagram sockets send packets of data. They either arrive as complete packets or they don't arrive at all, as opposed to stream sockets, where individual bytes might trickle in as they attempt to reliably deliver a stream of data.
    /// Datagram packets might arrive in a different order than you sent them, or they may just be lost while travelling across the network. You have to plan for this. As an added confusion, since SDL_net might send the same packet on multiple interfaces, you might get duplicate packets, possibly from different network addresses. You have to plan for this, too.
    /// You can send to any address and port on the network, but there has to be a datagram socket waiting for the data on the other side for the packet not to be lost.
    /// General wisdom is that you shouldn't send a packet larger than 1500 bytes over the Internet, as bad routers might fragment or lose larger ones, but this limit is not hardcoded into SDL_net and in good conditions you might be able to send significantly more.
    /// This call never blocks; if it can't send the data immediately, the library will queue it for later transmission. There is no query to see what is still queued, as datagram transmission is unreliable, so you should never assume anything about queued data.
    /// If there's a fatal error, this function will return false. Datagram sockets generally won't report failures, because there is no state like a "connection" to fail at this level, but may report failure for unrecoverable system-level conditions; once a datagram socket fails, you should assume it is no longer usable and should destroy it with SDL_DestroyDatagramSocket (C API outside this module)().
    /// Sending to a NULL address is treated as a request to broadcast a packet. Note that this will report failure immediately if the socket was not created with broadcast permission. Broadcast packets are (more or less) sent to every machine on the LAN, unconditionally.
    /// **WARNING**: It is possible to build a game where everyone is playing on the same LAN, and every player is simply broadcasting packets. This is absolutely the wrong thing to do, however. Broadcast packets go to every device on the LAN, whether they want them or not. The game DOOM, in its heyday, was capable of [bringing entire networks to their knees](https://doomwiki.org/wiki/Doom_in_workplaces) , as many players on the same network would all be broadcasting relentlessly.
    /// In practice, broadcasting sparingly can be useful for certain functionality: a LAN-only client broadcasting a few packets to ask for available servers, and running servers replying directly to that client without broadcasting at all, is reasonable and safe. Once clients and servers have found each other, they can communicate directly without any broadcasting at all. For peer-to-peer games, once connection is established, it's better to either send unique packets to each known player, or use a multicasting (which works like broadcast, but only routes packets to devices that are explicitly listening for it).
    /// With IPv6, which doesn't support broadcasts, broadcasting is faked with multicast to the all-nodes link-local multicast group, ff02::1, either on a specific interface or letting the OS choose the default. Other protocols might fake broadcast operations in similar ways in the future.
    ///
    /// - **Parameters:**
    ///   - `address`: the Address object address. May be NULL to broadcast.
    ///   - `port`: the address port.
    ///   - `buf`: a pointer to the data to send as a single packet.
    ///
    /// - **Returns:** true if data sent or queued for transmission, false on failure; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** DatagramSocket.receive
    pub inline fn send(self: @This(), address: ?*Address, port: u16, buf: []const u8) bool {
        return c.NET_SendDatagram(@ptrCast(self.value), @ptrCast(address), port, @ptrCast(buf.ptr), @intCast(buf.len));
    }

    /// Enable simulated datagram socket failures.
    ///
    /// Often times, testing a networked app on your development machinewhich might have a wired connection to a fast, reliable network servicewon't expose bugs that happen when networks intermittently fail in the real world, when the wifi is flakey and firewalls get in the way.
    /// This function allows you to tell the library to pretend that some percentage of datagram socket data transmission will fail.
    /// The library will randomly lose packets (both incoming and outgoing) at an average matching `percent_loss`. Setting this to zero (the default) will disable the simulation. Setting to 100 means *everything* fails unconditionally and no further data will get through. At what percent the system merely borders on unusable is left as an exercise to the app developer.
    /// This is intended for debugging purposes, to simulate real-world conditions that are various degrees of terrible. You probably should *not* call this in production code, where you'll likely see real failures anyhow.
    ///
    /// - **Parameters:**
    ///   - `percent_loss`: A number between 0 and 100. Higher means more failures. Zero to disable.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    pub inline fn simulatePacketLoss(self: @This(), percent_loss: c_int) void {
        c.NET_SimulateDatagramPacketLoss(@ptrCast(self.value), percent_loss);
    }
};

/// SDL handle `Server`.
pub const Server = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Dispose of a previously-created server.
    ///
    /// This will immediately disconnect any pending client connections that had not yet been accepted, but will not disconnect any existing accepted connections (which can still be used and must be destroyed separately). Further attempts to make new connections to this server will fail on the client side.
    ///
    /// - **Thread safety:** You should not operate on the same server from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different servers at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** createServer
    /// This method invalidates the handle after SDL_net consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.NET_DestroyServer(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Create a stream socket for the next pending client connection.
    ///
    /// When a client connects to a server, their connection will be pending until the server *accepts* the connection. Once accepted, the server will be given a stream socket to communicate with the client, and they can send data to, and receive data from, each other.
    /// Unlike createClient, stream sockets returned from this function are already connected and do not have to wait for the connection to complete, as server acceptance is the final step of connecting.
    /// This function does not block. If there are no new connections pending, this function will return true (for success, but `*client_stream` will be set to NULL. This is not an error and a common condition the app should expect. In fact, this function should be called in a loop until this condition occurs, so all pending connections are accepted in a single batch.
    /// If you want the server to sleep until there's a new connection, you can use waitUntilInputAvailable().
    /// When done with the newly-accepted client, you can disconnect and dispose of the stream socket by calling StreamSocket.deinit().
    ///
    /// - **Returns:** true on success (even if no new connections were pending), false on error; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same server from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different servers at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** waitUntilInputAvailable
    /// - **See also:** StreamSocket.deinit
    /// Returns `error.SdlFailure` when SDL_net reports failure.
    pub inline fn acceptClient(self: @This()) sdl.Error!root.AcceptClientResult {
        var client_stream_raw: ?*c.NET_StreamSocket = null;
        if (!c.NET_AcceptClient(@ptrCast(self.value), &client_stream_raw)) return error.SdlFailure;
        return root.AcceptClientResult{
            .client_stream = StreamSocket{ .value = @ptrCast(client_stream_raw orelse return error.SdlFailure) },
        };
    }
};

/// SDL handle `StreamSocket`.
pub const StreamSocket = struct {
    /// Opaque handle storage; use generated operations instead of modifying it.
    value: *anyopaque,

    /// Dispose of a previously-created stream socket.
    ///
    /// This will immediately disconnect the other side of the connection, if necessary. Further attempts to read or write the socket on the remote end will fail.
    /// This will *abandon* any data queued for sending that hasn't made it to the socket. If you need this data to arrive, you should wait for it to transmit before destroying the socket with StreamSocket.getPendingWrites() or StreamSocket.waitUntilDrained(). Any data that has arrived from the remote end of the connection that hasn't been read yet is lost.
    ///
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** createClient
    /// - **See also:** Server.acceptClient
    /// - **See also:** StreamSocket.getPendingWrites
    /// - **See also:** StreamSocket.waitUntilDrained
    /// This method invalidates the handle after SDL_net consumes it.
    pub inline fn deinit(self: *@This()) void {
        c.NET_DestroyStreamSocket(@ptrCast(self.value));
        self.* = undefined;
    }

    /// Check if a stream socket is connected, without blocking.
    ///
    /// The StreamSocket objects returned by createClient take time to do negotiate a connection to a server, so it does so *asynchronously* instead of making your program wait an indefinite amount of time.
    /// This function allows you to check the progress of that work without blocking.
    /// Connection can fail after some time (server took a while to respond, and then rejected the connection), so be sure to check the result of this function instead of assuming it worked because it's non-zero!
    /// Once a connection is successfully made, the stream socket can be used to send and receive data with the server.
    /// Note that if the connection succeeds, but later the connection is dropped, this will still report the connection as successful, as it only deals with the initial asynchronous work of getting connected; you'll know the connection dropped later when your reads and writes report failures.
    ///
    /// - **Returns:** Status.success if successfully connected, Status.failure if connection failed, Status.waiting if still connecting; if Status.failure, call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** StreamSocket.waitUntilConnected
    pub inline fn getConnectionStatus(self: @This()) Status {
        const result = c.NET_GetConnectionStatus(@ptrCast(self.value));
        return @enumFromInt(result);
    }

    /// Get the remote address of a stream socket.
    ///
    /// This reports the address of the remote side of a stream socket, which might still be pending connnection.
    /// This adds a reference to the address; the caller *must* call unrefAddress() when done with it.
    ///
    /// - **Returns:** the socket's remote address, or NULL on error; call sdl.error_.get() for details.
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    pub inline fn getAddress(self: @This()) ?*Address {
        const result = c.NET_GetStreamSocketAddress(@ptrCast(self.value));
        return if (result == null) null else @ptrCast(result);
    }

    /// Query bytes still pending transmission on a stream socket.
    ///
    /// If StreamSocket.writeTo() couldn't send all its data immediately, it will queue it to be sent later. This function lets the app see how much of that queue is still pending to be sent.
    /// The library will try to send more queued data before reporting what's left, but it will not block to do so.
    /// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning -1. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
    ///
    /// - **Returns:** number of bytes still pending transmission, -1 on failure; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** StreamSocket.writeTo
    /// - **See also:** StreamSocket.waitUntilDrained
    /// Returns `error.SdlFailure` when SDL_net reports failure.
    pub inline fn getPendingWrites(self: @This()) sdl.Error!c_int {
        const result = c.NET_GetStreamSocketPendingWrites(@ptrCast(self.value));
        if (result < 0) return error.SdlFailure;
        return result;
    }

    /// Receive bytes that a remote system sent to a stream socket.
    ///
    /// Stream sockets are *reliable*, which means data sent over them will arrive in the order it was transmitted, and the system will retransmit data as necessary to ensure its delivery. Which is to say, short of catastrophic failure, data will arrive, possibly with severe delays. Also, "catastrophic
    /// failure" isn't an uncommon event.
    /// (This is opposed to Datagram sockets, which send chunks of data that might arrive in any order, or not arrive at all, but you never wait for missing chunks to show up.)
    /// Stream sockets are *bidirectional*; you can read and write from the same stream, and the other end of the connection can, too.
    /// This function returns data that has arrived for the stream socket that hasn't been read yet. Data is provided in the order it was sent on the remote side. This function may return less data than requested, depending on what is available at the time, and also the app isn't required to read all available data at once.
    /// This call never blocks; if no new data is available at the time of the call, it returns 0 immediately. The caller can try again later.
    /// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning -1. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
    ///
    /// - **Parameters:**
    ///   - `buf`: a pointer to a buffer where received data will be collected.
    ///
    /// - **Returns:** number of bytes read from the stream socket (which can be less than `buflen` or zero if none available), -1 on failure; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** StreamSocket.writeTo
    /// Returns `error.SdlFailure` when SDL_net reports failure.
    pub inline fn readFrom(self: @This(), buf: []u8) sdl.Error!c_int {
        const result = c.NET_ReadFromStreamSocket(@ptrCast(self.value), @ptrCast(buf.ptr), @intCast(buf.len));
        if (result < 0) return error.SdlFailure;
        return result;
    }

    /// Enable simulated stream socket failures.
    ///
    /// Often times, testing a networked app on your development machinewhich might have a wired connection to a fast, reliable network servicewon't expose bugs that happen when networks intermittently fail in the real world, when the wifi is flakey and firewalls get in the way.
    /// This function allows you to tell the library to pretend that some percentage of stream socket data transmission will fail.
    /// Since stream sockets are reliable, failure in this case pretends that packets are getting lost on the network, making the stream retransmit to deal with it. To simulate this, the library will introduce some amount of delay before it sends or receives data on the socket. The higher the percentage, the more delay is introduced for bytes to make their way to their final destination. The library may also decide to drop connections at random, to simulate disasterous network conditions.
    /// Setting this to zero (the default) will disable the simulation. Setting to 100 means *everything* fails unconditionally and no further data will get through (and perhaps your sockets eventually fail). At what percent the system merely borders on unusable is left as an exercise to the app developer.
    /// This is intended for debugging purposes, to simulate real-world conditions that are various degrees of terrible. You probably should *not* call this in production code, where you'll likely see real failures anyhow.
    ///
    /// - **Parameters:**
    ///   - `percent_loss`: A number between 0 and 100. Higher means more failures. Zero to disable.
    ///
    /// - **Thread safety:** It is safe to call this function from any thread.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    pub inline fn simulatePacketLoss(self: @This(), percent_loss: c_int) void {
        c.NET_SimulateStreamPacketLoss(@ptrCast(self.value), percent_loss);
    }

    /// Block until a stream socket has connected to a server.
    ///
    /// The StreamSocket objects returned by createClient take time to do their work, so it does so *asynchronously* instead of making your program wait an indefinite amount of time.
    /// However, if you want your program to sleep until the connection is complete, you can call this function.
    /// This function takes a timeout value, represented in milliseconds, of how long to wait for resolution to complete. Specifying a timeout of -1 instructs the library to wait indefinitely, and a timeout of 0 just checks the current status and returns immediately (and is functionally equivalent to calling StreamSocket.getConnectionStatus).
    /// Connections can fail after some time (server took awhile to respond at all, and then refused the connection outright), so be sure to check the result of this function instead of assuming it worked!
    /// Once a connection is successfully made, the socket may read data from, or write data to, the connected server.
    /// If you don't want your program to block, you can call StreamSocket.getConnectionStatus() from time to time until you get a non-zero result.
    ///
    /// - **Parameters:**
    ///   - `timeout`: Number of milliseconds to wait for resolution to complete. -1 to wait indefinitely, 0 to check once without waiting.
    ///
    /// - **Returns:** Status.success if successfully connected, Status.failure if connection failed, Status.waiting if still connecting (this function timed out without resolution); if Status.failure, call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different socket at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** StreamSocket.getConnectionStatus
    pub inline fn waitUntilConnected(self: @This(), timeout: i32) Status {
        const result = c.NET_WaitUntilConnected(@ptrCast(self.value), timeout);
        return @enumFromInt(result);
    }

    /// Block until all of a stream socket's pending data is sent.
    ///
    /// If StreamSocket.writeTo() couldn't send all its data immediately, it will queue it to be sent later. This function lets the app sleep until all the data is transmitted.
    /// This function takes a timeout value, represented in milliseconds, of how long to wait for transmission to complete. Specifying a timeout of -1 instructs the library to wait indefinitely, and a timeout of 0 just checks the current status and returns immediately (and is functionally equivalent to calling StreamSocket.getPendingWrites).
    /// If you don't want your program to block, you can call StreamSocket.getPendingWrites from time to time until you get a result <= 0.
    /// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning -1. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
    ///
    /// - **Parameters:**
    ///   - `timeout`: Number of milliseconds to wait for draining to complete. -1 to wait indefinitely, 0 to check once without waiting.
    ///
    /// - **Returns:** number of bytes still pending transmission, -1 on failure; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** StreamSocket.writeTo
    /// - **See also:** StreamSocket.getPendingWrites
    /// Returns `error.SdlFailure` when SDL_net reports failure.
    pub inline fn waitUntilDrained(self: @This(), timeout: i32) sdl.Error!c_int {
        const result = c.NET_WaitUntilStreamSocketDrained(@ptrCast(self.value), timeout);
        if (result < 0) return error.SdlFailure;
        return result;
    }

    /// Send bytes over a stream socket to a remote system.
    ///
    /// Stream sockets are *reliable*, which means data sent over them will arrive in the order it was transmitted, and the system will retransmit data as necessary to ensure its delivery. Which is to say, short of catastrophic failure, data will arrive, possibly with severe delays. Also, "catastrophic
    /// failure" isn't an uncommon event.
    /// (This is opposed to Datagram sockets, which send chunks of data that might arrive in any order, or not arrive at all, but you never wait for missing chunks to show up.)
    /// Stream sockets are *bidirectional*; you can read and write from the same stream, and the other end of the connection can, too.
    /// This call never blocks; if it can't send the data immediately, the library will queue it for later transmission. You can use StreamSocket.getPendingWrites() to see how much is still queued for later transmission, or StreamSocket.waitUntilDrained() to block until all pending data has been sent.
    /// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning false. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
    ///
    /// - **Parameters:**
    ///   - `buf`: a pointer to the data to send.
    ///
    /// - **Returns:** true if data sent or queued for transmission, false on failure; call sdl.error_.get() for details.
    /// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
    /// - **Since:** This function is available since SDL_net 3.0.0.
    /// - **See also:** StreamSocket.getPendingWrites
    /// - **See also:** StreamSocket.waitUntilDrained
    /// - **See also:** StreamSocket.readFrom
    pub inline fn writeTo(self: @This(), buf: []const u8) bool {
        return c.NET_WriteToStreamSocket(@ptrCast(self.value), @ptrCast(buf.ptr), @intCast(buf.len));
    }
};

/// SDL constant `prop_datagram_socket_allow_broadcast_boolean`.
pub const prop_datagram_socket_allow_broadcast_boolean = c.NET_PROP_DATAGRAM_SOCKET_ALLOW_BROADCAST_BOOLEAN;
/// SDL constant `prop_datagram_socket_reuseaddr_boolean`.
pub const prop_datagram_socket_reuseaddr_boolean = c.NET_PROP_DATAGRAM_SOCKET_REUSEADDR_BOOLEAN;
/// SDL constant `prop_server_reuseaddr_boolean`.
pub const prop_server_reuseaddr_boolean = c.NET_PROP_SERVER_REUSEADDR_BOOLEAN;

/// Named output values.
pub const AcceptClientResult = struct {
    /// Output `client_stream`.
    client_stream: StreamSocket,
};

/// Create a stream socket for the next pending client connection.
///
/// When a client connects to a server, their connection will be pending until the server *accepts* the connection. Once accepted, the server will be given a stream socket to communicate with the client, and they can send data to, and receive data from, each other.
/// Unlike createClient, stream sockets returned from this function are already connected and do not have to wait for the connection to complete, as server acceptance is the final step of connecting.
/// This function does not block. If there are no new connections pending, this function will return true (for success, but `*client_stream` will be set to NULL. This is not an error and a common condition the app should expect. In fact, this function should be called in a loop until this condition occurs, so all pending connections are accepted in a single batch.
/// If you want the server to sleep until there's a new connection, you can use waitUntilInputAvailable().
/// When done with the newly-accepted client, you can disconnect and dispose of the stream socket by calling StreamSocket.deinit().
///
/// - **Parameters:**
///   - `server`: the server object to check for pending connections.
///
/// - **Returns:** true on success (even if no new connections were pending), false on error; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same server from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different servers at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** waitUntilInputAvailable
/// - **See also:** StreamSocket.deinit
/// Returns named output values.
pub inline fn acceptClient(server: ?Server) sdl.Error!AcceptClientResult {
    var client_stream_raw: ?*c.NET_StreamSocket = null;
    if (!c.NET_AcceptClient(if (server) |resource| @ptrCast(resource.value) else null, &client_stream_raw)) return error.SdlFailure;
    return AcceptClientResult{
        .client_stream = StreamSocket{ .value = @ptrCast(client_stream_raw orelse return error.SdlFailure) },
    };
}

/// Compare two Address objects.
///
/// This compares two addresses, returning a value that is useful for qsort (or sdl.stdinc.qsort).
///
/// - **Parameters:**
///   - `a`: first address to compare.
///   - `b`: second address to compare.
///
/// - **Returns:** a value less than zero if `a` is "less than" `b`, a value greater than zero if "greater than", zero if equal.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn compareAddresses(a: ?*const Address, b: ?*const Address) c_int {
    return c.NET_CompareAddresses(@ptrCast(a), @ptrCast(b));
}

/// Begin connecting a socket as a client to a remote server.
///
/// Each StreamSocket represents a single connection between systems. Usually, a client app will have one connection to a server app on a different computer, and the server app might have many connections from different clients. Each of these connections communicate over a separate stream socket.
/// Connecting is an asynchronous operation; this function does not block, and will return before the connection is complete. One has to then use StreamSocket.waitUntilConnected() or StreamSocket.getConnectionStatus() to see when the operation has completed, and if it was successful.
/// Once connected, you can read and write data to the returned socket. Stream sockets are a mode of *reliable* transmission, which means data will be received as a stream of bytes in the order you sent it. If there are problems in transmission, the system will deal with protocol negotiation and retransmission as necessary, transparent to your app, but this means until data is available in the order sent, the remote side will not get any new data. This is the tradeoff vs datagram sockets, where data can arrive in any order, or not arrive at all, without waiting, but the sender will not know.
/// Stream sockets don't employ any protocol (above the TCP level), so they can connect to servers that aren't using SDL_net, but if you want to speak any protocol beyond an abritrary stream of bytes, such as HTTP, you'll have to implement that yourself on top of the stream socket.
/// This function will fail if `address` is not finished resolving.
/// When you are done with this connection (whether it failed to connect or not), you must dispose of it with StreamSocket.deinit().
/// Unlike BSD sockets or WinSock, you specify the port as a normal integer; you do not have to byteswap it into "network order," as the library will handle that for you.
/// There are currently no extra properties for creating a client, so `props` should be zero. A future revision of SDL_net may add additional (optional) properties.
///
/// - **Parameters:**
///   - `address`: the address of the remote server to connect to.
///   - `port`: the port on the remote server to connect to.
///   - `props`: properties of the new client. Specify zero for defaults.
///
/// - **Returns:** a new StreamSocket, pending connection, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.waitUntilConnected
/// - **See also:** StreamSocket.getConnectionStatus
/// - **See also:** StreamSocket.deinit
pub inline fn createClient(address: ?*Address, port: u16, props: sdl.properties.Id) ?StreamSocket {
    const result = c.NET_CreateClient(@ptrCast(address), port, props);
    return if (result) |value| StreamSocket{ .value = @ptrCast(value) } else null;
}

/// Create and bind a new datagram socket.
///
/// Datagram sockets follow different rules than stream sockets. They are not a reliable stream of bytes but rather packets, they are not limited to talking to a single other remote system, they do not maintain a single "connection" that can be dropped, and they are more nimble about network failures at the expense of being more complex to use. What makes sense for your app depends entirely on what your app is trying to accomplish.
/// Generally the idea of a datagram socket is that you send data one chunk ("packet") at a time to any address you want, and it arrives whenever it gets there, even if later packets get there first, and maybe it doesn't get there at all, and you don't know when anything of this happens by default.
/// This function creates a new datagram socket.
/// This function does not block, and is not asynchronous, as the system can decide immediately if it can create a socket or not. If this returns success, you can immediately start talking to the network.
/// You can specify an address to listen for connections on; this address must be local to the system, and probably one returned by getLocalAddresses(), but almost always you just want to specify NULL here, to listen on any address available to the app.
/// If you need to bind to a specific port (like a server), you should specify it in the `port` argument; datagram servers should do this, so they can be reached at a well-known port. If you only plan to initiate communications (like a client), you should specify 0 and let the system pick an unused port. Only one process can bind to a specific port at a time, so if you aren't acting as a server, you should choose 0. Datagram sockets can send individual packets to any port, so this just declares where data will arrive for your socket.
/// Datagram sockets don't employ any protocol (above the UDP level), so they can talk to apps that aren't using SDL_net, but if you want to speak any protocol beyond arbitrary packets of bytes, such as WebRTC, you'll have to implement that yourself on top of the stream socket.
/// Unlike BSD sockets or WinSock, you specify the port as a normal integer; you do not have to byteswap it into "network order," as the library will handle that for you.
/// The caller may supply properties to customize behavior. This is optional, and a value of zero for `props` will request defaults for all properties.
/// These are the supported properties:
/// - `prop_datagram_socket_reuseaddr_boolean`: true if the socket should be created even if a previous socket has recently used this address. For various reasons, networks prefer that there be some delay between apps reusing the same address, but this can be problematic when iterating quickly, for software development purposes or just restarting a crashed service. This property defaults to true (although it should be noted that, at the operating system level, this defaults to false!). If this property is false and the OS feels that not enough time has elapsed, socket creation will fail and this function will report an error.
/// - `prop_datagram_socket_allow_broadcast_boolean`: true if the socket should allow broadcasting. At the lower level, this will set `SO_BROADCAST` for IPv4 sockets, to allow sending to the subnet's broadcast address at the OS level. For IPv6, it'll join the all-nodes link-local multicast group, ff02::1, allowing sending and receiving there, more or less simulating the usual IPv4 broadcast semantics. Other protocols take similar approaches. If you do not intend to send or receive broadcast packets on this socket, set this property to false, or omit it, as it defaults to false. Note: IPv4 will still be able to receive broadcast packets without this option, but IPv6 will not. Also see notes about sending to a broadcast address in DatagramSocket.send().
///
/// - **Parameters:**
///   - `addr`: the local address to listen for connections on, or NULL to listen on all available local addresses.
///   - `port`: the port on the local address to listen for connections on, or zero for the system to decide.
///   - `props`: properties of the new socket. Specify zero for defaults.
///
/// - **Returns:** a new DatagramSocket, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** getLocalAddresses
/// - **See also:** DatagramSocket.deinit
pub inline fn createDatagramSocket(addr: ?*Address, port: u16, props: sdl.properties.Id) ?DatagramSocket {
    const result = c.NET_CreateDatagramSocket(@ptrCast(addr), port, props);
    return if (result) |value| DatagramSocket{ .value = @ptrCast(value) } else null;
}

/// Create a server, which listens for connections to accept.
///
/// An app that initiates connection to a remote computer is called a "client," and the thing the client connects to is called a "server."
/// Servers listen for and accept connections from clients, which spawns a new stream socket on the server's end, which it can then send/receive data on.
/// Use this function to create a server that will accept connections from other systems.
/// This function does not block, and is not asynchronous, as the system can decide immediately if it can create a server or not. If this returns success, you can immediately start accepting connections.
/// You can specify an address to listen for connections on; this address must be local to the system, and probably one returned by getLocalAddresses(), but almost always you just want to specify NULL here, to listen on any address available to the app.
/// After creating a server, you get stream sockets to talk to incoming client connections by calling Server.acceptClient().
/// Stream sockets don't employ any protocol (above the TCP level), so they can accept connections from clients that aren't using SDL_net, but if you want to speak any protocol beyond an abritrary stream of bytes, such as HTTP, you'll have to implement that yourself on top of the stream socket.
/// Unlike BSD sockets or WinSock, you specify the port as a normal integer; you do not have to byteswap it into "network order," as the library will handle that for you.
/// The caller may supply properties to customize behavior. This is optional, and a value of zero for `props` will request defaults for all properties.
/// These are the supported properties:
/// - `prop_server_reuseaddr_boolean`: true if the server should be created even if a previous server has recently used this address. For various reasons, networks prefer that there be some delay between apps reusing the same address, but this can be problematic when iterating quickly, for software development purposes or just restarting a crashed service. This property defaults to true (although it should be noted that, at the operating system level, this defaults to false!). If this property is false and the OS feels that not enough time has elapsed, server creation will fail and this function will report an error.
///
/// - **Parameters:**
///   - `addr`: the *local* address to listen for connections on, or NULL.
///   - `port`: the port on the local address to listen for connections on.
///   - `props`: properties of the new server. Specify zero for defaults.
///
/// - **Returns:** a new Server, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** getLocalAddresses
/// - **See also:** Server.acceptClient
/// - **See also:** Server.deinit
pub inline fn createServer(addr: ?*Address, port: u16, props: sdl.properties.Id) ?Server {
    const result = c.NET_CreateServer(@ptrCast(addr), port, props);
    return if (result) |value| Server{ .value = @ptrCast(value) } else null;
}

/// Dispose of a datagram packet previously received.
///
/// You must pass packets received through DatagramSocket.receive to this function when you are done with them. This will free resources used by this packet and unref its Address.
/// If you want to save the sender's address from the packet past this time, it is safe to call refAddress() on the address and hold onto its pointer, so long as you call unrefAddress() on it when you are done with it.
/// Once you call this function, the datagram pointer becomes invalid and should not be used again by the app.
///
/// - **Parameters:**
///   - `dgram`: the datagram packet to destroy.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn destroyDatagram(dgram: ?*Datagram) void {
    c.NET_DestroyDatagram(@ptrCast(dgram));
}

/// Free the results from getLocalAddresses.
///
/// This will unref all addresses in the array and free the array itself.
/// Since addresses are reference counted, it is safe to keep any addresses you want from this array even after calling this function, as long as you called refAddress() on them first.
/// It is safe to pass a NULL in here, it will be ignored.
///
/// - **Parameters:**
///   - `addresses`: A pointer returned by getLocalAddresses().
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn freeLocalAddresses(addresses: ?*?*Address) void {
    c.NET_FreeLocalAddresses(@ptrCast(addresses));
}

/// Get the protocol-level bytes of a network address from a resolved address.
///
/// This data is not human-readable, is protocol-specific, and might not even be in a specific byte order.
/// This is only useful for possibly hashing, to map a address to a specific player in a game, or possibly for handing to a system-level networking API (which is *not* recommended; an app does this at their own risk).
/// Do not store these bytes for future runs of the program; there is no promise the format won't change.
/// On return `*num_bytes` will hold the number of bytes provided with the address. Since the data is not NULL-terminated, this is the only way to determine its size; as such, this parameter must not be NULL.
/// Do not free or modify the returned data; it belongs to the Address that was queried, and is valid as long as the object lives. Either make sure the address has a reference as long as you need this or make a copy of the bytes.
/// This will return NULL if resolution is still in progress, or if resolution failed. You can use getAddressStatus() or waitUntilResolved() to make sure resolution has successfully completed before calling this.
/// A human-readable version is available in getAddressString() and isn't any less efficient to query than the raw bytes.
///
/// - **Parameters:**
///   - `address`: The Address to query.
///   - `num_bytes`: on return, will be set to the number of bytes returned.
///
/// - **Returns:** a pointer to bytes, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** getAddressString
/// - **See also:** getAddressStatus
/// - **See also:** waitUntilResolved
pub inline fn getAddressBytes(address: ?*Address, num_bytes: ?*c_int) ?*const anyopaque {
    const result = c.NET_GetAddressBytes(@ptrCast(address), @ptrCast(num_bytes));
    return if (result == null) null else @ptrCast(result);
}

/// Check if an address is resolved, without blocking.
///
/// The Address objects returned by resolveHostname take time to do their work, so it does so *asynchronously* instead of making your program wait an indefinite amount of time.
/// This function allows you to check the progress of that work without blocking.
/// Resolution can fail after some time (DNS server took awhile to reply that the hostname isn't recognized, etc), so be sure to check the result of this function instead of assuming it worked because it's non-zero!
/// Once an address is successfully resolved, it can be used to connect to the host represented by the address.
///
/// - **Parameters:**
///   - `address`: The Address to query.
///
/// - **Returns:** Status.success if successfully resolved, Status.failure if resolution failed, Status.waiting if still resolving (this function timed out without resolution); if Status.failure, call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** waitUntilResolved
pub inline fn getAddressStatus(address: ?*Address) Status {
    const result = c.NET_GetAddressStatus(@ptrCast(address));
    return @enumFromInt(result);
}

/// Get a human-readable string from a resolved address.
///
/// This returns a string that's "human-readable", in that it's probably a string of numbers and symbols, like "159.203.69.7" or "2604:a880:800:a1::71f:3001". It won't be the original hostname (like "icculus.org"), but it's suitable for writing to a log file, etc.
/// Do not free or modify the returned string; it belongs to the Address that was queried, and is valid as long as the object lives. Either make sure the address has a reference as long as you need this or make a copy of the string.
/// This will return NULL if resolution is still in progress, or if resolution failed. You can use getAddressStatus() or waitUntilResolved() to make sure resolution has successfully completed before calling this.
///
/// - **Parameters:**
///   - `address`: The Address to query.
///
/// - **Returns:** a string, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** getAddressStatus
/// - **See also:** waitUntilResolved
pub inline fn getAddressString(address: ?*Address) ?[:0]const u8 {
    const result = c.NET_GetAddressString(@ptrCast(address));
    return if (result == null) null else std.mem.span(@as([*:0]const u8, @ptrCast(result.?)));
}

/// Check if a stream socket is connected, without blocking.
///
/// The StreamSocket objects returned by createClient take time to do negotiate a connection to a server, so it does so *asynchronously* instead of making your program wait an indefinite amount of time.
/// This function allows you to check the progress of that work without blocking.
/// Connection can fail after some time (server took a while to respond, and then rejected the connection), so be sure to check the result of this function instead of assuming it worked because it's non-zero!
/// Once a connection is successfully made, the stream socket can be used to send and receive data with the server.
/// Note that if the connection succeeds, but later the connection is dropped, this will still report the connection as successful, as it only deals with the initial asynchronous work of getting connected; you'll know the connection dropped later when your reads and writes report failures.
///
/// - **Parameters:**
///   - `sock`: the stream socket to query.
///
/// - **Returns:** Status.success if successfully connected, Status.failure if connection failed, Status.waiting if still connecting; if Status.failure, call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.waitUntilConnected
pub inline fn getConnectionStatus(sock: ?StreamSocket) Status {
    const result = c.NET_GetConnectionStatus(if (sock) |resource| @ptrCast(resource.value) else null);
    return @enumFromInt(result);
}

/// Obtain a list of local addresses on the system.
///
/// This returns addresses that you can theoretically bind a socket to, to accept connections from other machines at that address.
/// You almost never need this function; first, it's hard to tell *what* is a good address to bind to, without asking the user (who will likely find it equally hard to decide). Second, most machines will have lots of *private* addresses that are accessible on the same LAN, but not public ones that are accessible from the outside Internet.
/// Usually it's better to use createServer() or createDatagramSocket() with a NULL address, to say "bind to all interfaces."
/// The array of addresses returned from this is guaranteed to be NULL-terminated. You can also pass a pointer to an int, which will return the final count, not counting the NULL at the end of the array.
/// Pass the returned array to freeLocalAddresses when you are done with it. It is safe to keep any addresses you want from this array even after calling that function, as long as you called refAddress() on them.
///
/// - **Returns:** A NULL-terminated array of Address pointers, one for each bindable address on the system, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn getLocalAddresses(allocator_: std.mem.Allocator) sdl.Error![]?*Address {
    const Count = @typeInfo(@typeInfo(@TypeOf(c.NET_GetLocalAddresses)).@"fn".params[0].type.?).pointer.child;
    var count: Count = 0;
    const result = c.NET_GetLocalAddresses(&count);
    if (result == null) return error.SdlFailure;
    defer c.NET_FreeLocalAddresses(@ptrCast(result));
    const length = std.math.cast(usize, count) orelse return error.SdlFailure;
    const copy = allocator_.alloc(?*Address, length) catch return error.OutOfMemory;
    errdefer allocator_.free(copy);
    for (copy, 0..) |*item, index| {
        item.* = if (result[index] == null) null else @ptrCast(result[index]);
    }
    return copy;
}

/// Get the remote address of a stream socket.
///
/// This reports the address of the remote side of a stream socket, which might still be pending connnection.
/// This adds a reference to the address; the caller *must* call unrefAddress() when done with it.
///
/// - **Parameters:**
///   - `sock`: the stream socket to query.
///
/// - **Returns:** the socket's remote address, or NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn getStreamSocketAddress(sock: ?StreamSocket) ?*Address {
    const result = c.NET_GetStreamSocketAddress(if (sock) |resource| @ptrCast(resource.value) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Query bytes still pending transmission on a stream socket.
///
/// If StreamSocket.writeTo() couldn't send all its data immediately, it will queue it to be sent later. This function lets the app see how much of that queue is still pending to be sent.
/// The library will try to send more queued data before reporting what's left, but it will not block to do so.
/// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning -1. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
///
/// - **Parameters:**
///   - `sock`: the stream socket to query.
///
/// - **Returns:** number of bytes still pending transmission, -1 on failure; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.writeTo
/// - **See also:** StreamSocket.waitUntilDrained
///
/// Returns `error.SdlFailure` when SDL_net reports failure.
pub inline fn getStreamSocketPendingWrites(sock: ?StreamSocket) sdl.Error!c_int {
    const result = c.NET_GetStreamSocketPendingWrites(if (sock) |resource| @ptrCast(resource.value) else null);
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Initialize the SDL_net library.
///
/// This must be successfully called once before (almost) any other SDL_net function can be used.
/// It is safe to call this multiple times; the library will only initialize once, and won't deinitialize until quit() has been called a matching number of times. Extra attempts to init report success.
///
/// - **Returns:** true on success, false on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** quit
///
/// Returns `error.SdlFailure` when SDL_net reports failure.
pub inline fn init() sdl.Error!void {
    if (!c.NET_Init()) return error.SdlFailure;
}

/// Deinitialize the SDL_net library.
///
/// This must be called when done with the library, probably at the end of your program.
/// It is safe to call this multiple times; the library will only deinitialize once, when this function is called the same number of times as init was successfully called.
/// Once you have successfully deinitialized the library, it is safe to call init to reinitialize it for further use.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** init
pub inline fn quit() void {
    c.NET_Quit();
}

/// Receive bytes that a remote system sent to a stream socket.
///
/// Stream sockets are *reliable*, which means data sent over them will arrive in the order it was transmitted, and the system will retransmit data as necessary to ensure its delivery. Which is to say, short of catastrophic failure, data will arrive, possibly with severe delays. Also, "catastrophic
/// failure" isn't an uncommon event.
/// (This is opposed to Datagram sockets, which send chunks of data that might arrive in any order, or not arrive at all, but you never wait for missing chunks to show up.)
/// Stream sockets are *bidirectional*; you can read and write from the same stream, and the other end of the connection can, too.
/// This function returns data that has arrived for the stream socket that hasn't been read yet. Data is provided in the order it was sent on the remote side. This function may return less data than requested, depending on what is available at the time, and also the app isn't required to read all available data at once.
/// This call never blocks; if no new data is available at the time of the call, it returns 0 immediately. The caller can try again later.
/// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning -1. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
///
/// - **Parameters:**
///   - `sock`: the stream socket to receive data from.
///   - `buf`: a pointer to a buffer where received data will be collected.
///
/// - **Returns:** number of bytes read from the stream socket (which can be less than `buflen` or zero if none available), -1 on failure; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.writeTo
///
/// Returns `error.SdlFailure` when SDL_net reports failure.
pub inline fn readFromStreamSocket(sock: ?StreamSocket, buf: []u8) sdl.Error!c_int {
    const result = c.NET_ReadFromStreamSocket(if (sock) |resource| @ptrCast(resource.value) else null, @ptrCast(buf.ptr), @intCast(buf.len));
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Receive a new packet that a remote system sent to a datagram socket.
///
/// Datagram sockets send packets of data. They either arrive as complete packets or they don't arrive at all, so you'll never receive half a packet.
/// This call never blocks; if no new data is available at the time of the call, it returns true immediately. The caller can try again later.
/// On a successful call to this function, it returns true, even if no new packets are available, so you should check for a successful return and a non-NULL value in `*dgram` to decide if a new packet is available.
/// You must pass received packets to destroyDatagram when you are done with them. If you want to save the sender's address past this time, it is safe to call refAddress() on the address and hold onto the pointer, so long as you call unrefAddress() on it when you are done with it.
/// Since datagrams can arrive from any address or port on the network without prior warning, this information is available in the Datagram object that is provided by this function, and this is the only way to know who to reply to. Even if you aren't acting as a "server," packets can still arrive at your socket if someone sends one.
/// If there's a fatal error, this function will return false. Datagram sockets generally won't report failures, because there is no state like a "connection" to fail at this level, but may report failure for unrecoverable system-level conditions; once a datagram socket fails, you should assume it is no longer usable and should destroy it with SDL_DestroyDatagramSocket (C API outside this module)().
///
/// - **Parameters:**
///   - `sock`: the datagram socket to send data through.
///   - `dgram`: a pointer to the datagram packet pointer.
///
/// - **Returns:** true if data sent or queued for transmission, false on failure; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** DatagramSocket.send
/// - **See also:** destroyDatagram
pub inline fn receiveDatagram(sock: ?DatagramSocket, dgram: ?*?*Datagram) bool {
    return c.NET_ReceiveDatagram(if (sock) |resource| @ptrCast(resource.value) else null, @ptrCast(dgram));
}

/// Add a reference to an Address.
///
/// Since several pieces of the library might share a single Address, including a background thread that's working on resolving, these objects are referenced counted. This allows everything that's using it to declare they still want it, and drop their reference to the address when they are done with it. The object's resources are freed when the last reference is dropped.
/// This function adds a reference to an Address, increasing its reference count by one.
/// The documentation will tell you when the app has to explicitly unref an address. For example, resolveHostname() creates addresses that are already referenced, so the caller needs to unref it when done.
/// Generally you only have to explicit ref an address when you have different parts of your own app that will be sharing an address. In normal usage, you only have to unref things you've created once (like you might free() something), but you are free to add extra refs if it makes sense.
/// This returns the same address passed as a parameter, which makes it easy to ref and assign in one step:
/// ```c
/// myAddr=NET_RefAddress(yourAddr);
/// ```
///
/// - **Parameters:**
///   - `address`: The Address to add a reference to.
///
/// - **Returns:** the same address that was passed as a parameter.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn refAddress(address: ?*Address) ?*Address {
    const result = c.NET_RefAddress(@ptrCast(address));
    return if (result == null) null else @ptrCast(result);
}

/// Resolve a human-readable hostname.
///
/// SDL_net doesn't operate on human-readable hostnames (like `www.libsdl.org` but on computer-readable addresses. This function converts from one to the other. This process is known as "resolving" an address.
/// You can also use this to turn IP address strings (like "159.203.69.7") into Address objects.
/// Note that resolving an address is an asynchronous operation, since the library will need to ask a server on the internet to get the information it needs, and this can take time (and possibly fail later). This function will not block. It either returns NULL (catastrophic failure) or an unresolved Address. Until the address resolves, it can't be used.
/// If you want to block until the resolution is finished, you can call waitUntilResolved(). Otherwise, you can do a non-blocking check with getAddressStatus().
/// When you are done with the returned Address, call unrefAddress() to dispose of it. You need to do this even if resolution later fails asynchronously.
///
/// - **Parameters:**
///   - `host`: The hostname to resolve.
///
/// - **Returns:** A new Address on success, NULL on error; call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** waitUntilResolved
/// - **See also:** getAddressStatus
/// - **See also:** refAddress
/// - **See also:** unrefAddress
pub inline fn resolveHostname(host: ?[:0]const u8) ?*Address {
    const result = c.NET_ResolveHostname(if (host != null) @ptrCast(host.?.ptr) else null);
    return if (result == null) null else @ptrCast(result);
}

/// Send a new packet over a datagram socket to a remote system.
///
/// Datagram sockets send packets of data. They either arrive as complete packets or they don't arrive at all, as opposed to stream sockets, where individual bytes might trickle in as they attempt to reliably deliver a stream of data.
/// Datagram packets might arrive in a different order than you sent them, or they may just be lost while travelling across the network. You have to plan for this. As an added confusion, since SDL_net might send the same packet on multiple interfaces, you might get duplicate packets, possibly from different network addresses. You have to plan for this, too.
/// You can send to any address and port on the network, but there has to be a datagram socket waiting for the data on the other side for the packet not to be lost.
/// General wisdom is that you shouldn't send a packet larger than 1500 bytes over the Internet, as bad routers might fragment or lose larger ones, but this limit is not hardcoded into SDL_net and in good conditions you might be able to send significantly more.
/// This call never blocks; if it can't send the data immediately, the library will queue it for later transmission. There is no query to see what is still queued, as datagram transmission is unreliable, so you should never assume anything about queued data.
/// If there's a fatal error, this function will return false. Datagram sockets generally won't report failures, because there is no state like a "connection" to fail at this level, but may report failure for unrecoverable system-level conditions; once a datagram socket fails, you should assume it is no longer usable and should destroy it with SDL_DestroyDatagramSocket (C API outside this module)().
/// Sending to a NULL address is treated as a request to broadcast a packet. Note that this will report failure immediately if the socket was not created with broadcast permission. Broadcast packets are (more or less) sent to every machine on the LAN, unconditionally.
/// **WARNING**: It is possible to build a game where everyone is playing on the same LAN, and every player is simply broadcasting packets. This is absolutely the wrong thing to do, however. Broadcast packets go to every device on the LAN, whether they want them or not. The game DOOM, in its heyday, was capable of [bringing entire networks to their knees](https://doomwiki.org/wiki/Doom_in_workplaces) , as many players on the same network would all be broadcasting relentlessly.
/// In practice, broadcasting sparingly can be useful for certain functionality: a LAN-only client broadcasting a few packets to ask for available servers, and running servers replying directly to that client without broadcasting at all, is reasonable and safe. Once clients and servers have found each other, they can communicate directly without any broadcasting at all. For peer-to-peer games, once connection is established, it's better to either send unique packets to each known player, or use a multicasting (which works like broadcast, but only routes packets to devices that are explicitly listening for it).
/// With IPv6, which doesn't support broadcasts, broadcasting is faked with multicast to the all-nodes link-local multicast group, ff02::1, either on a specific interface or letting the OS choose the default. Other protocols might fake broadcast operations in similar ways in the future.
///
/// - **Parameters:**
///   - `sock`: the datagram socket to send data through.
///   - `address`: the Address object address. May be NULL to broadcast.
///   - `port`: the address port.
///   - `buf`: a pointer to the data to send as a single packet.
///
/// - **Returns:** true if data sent or queued for transmission, false on failure; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** DatagramSocket.receive
pub inline fn sendDatagram(sock: ?DatagramSocket, address: ?*Address, port: u16, buf: []const u8) bool {
    return c.NET_SendDatagram(if (sock) |resource| @ptrCast(resource.value) else null, @ptrCast(address), port, @ptrCast(buf.ptr), @intCast(buf.len));
}

/// Enable simulated address resolution failures.
///
/// Often times, testing a networked app on your development machinewhich might have a wired connection to a fast, reliable network servicewon't expose bugs that happen when networks intermittently fail in the real world, when the wifi is flakey and firewalls get in the way.
/// This function allows you to tell the library to pretend that some percentage of address resolutions will fail.
/// The higher the percentage, the more resolutions will fail and/or take longer for resolution to complete.
/// Setting this to zero (the default) will disable the simulation. Setting to 100 means *everything* fails unconditionally. At what percent the system merely borders on unusable is left as an exercise to the app developer.
/// This is intended for debugging purposes, to simulate real-world conditions that are various degrees of terrible. You probably should *not* call this in production code, where you'll likely see real failures anyhow.
///
/// - **Parameters:**
///   - `percent_loss`: A number between 0 and 100. Higher means more failures. Zero to disable.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn simulateAddressResolutionLoss(percent_loss: c_int) void {
    c.NET_SimulateAddressResolutionLoss(percent_loss);
}

/// Enable simulated datagram socket failures.
///
/// Often times, testing a networked app on your development machinewhich might have a wired connection to a fast, reliable network servicewon't expose bugs that happen when networks intermittently fail in the real world, when the wifi is flakey and firewalls get in the way.
/// This function allows you to tell the library to pretend that some percentage of datagram socket data transmission will fail.
/// The library will randomly lose packets (both incoming and outgoing) at an average matching `percent_loss`. Setting this to zero (the default) will disable the simulation. Setting to 100 means *everything* fails unconditionally and no further data will get through. At what percent the system merely borders on unusable is left as an exercise to the app developer.
/// This is intended for debugging purposes, to simulate real-world conditions that are various degrees of terrible. You probably should *not* call this in production code, where you'll likely see real failures anyhow.
///
/// - **Parameters:**
///   - `sock`: The socket to set a failure rate on.
///   - `percent_loss`: A number between 0 and 100. Higher means more failures. Zero to disable.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn simulateDatagramPacketLoss(sock: ?DatagramSocket, percent_loss: c_int) void {
    c.NET_SimulateDatagramPacketLoss(if (sock) |resource| @ptrCast(resource.value) else null, percent_loss);
}

/// Enable simulated stream socket failures.
///
/// Often times, testing a networked app on your development machinewhich might have a wired connection to a fast, reliable network servicewon't expose bugs that happen when networks intermittently fail in the real world, when the wifi is flakey and firewalls get in the way.
/// This function allows you to tell the library to pretend that some percentage of stream socket data transmission will fail.
/// Since stream sockets are reliable, failure in this case pretends that packets are getting lost on the network, making the stream retransmit to deal with it. To simulate this, the library will introduce some amount of delay before it sends or receives data on the socket. The higher the percentage, the more delay is introduced for bytes to make their way to their final destination. The library may also decide to drop connections at random, to simulate disasterous network conditions.
/// Setting this to zero (the default) will disable the simulation. Setting to 100 means *everything* fails unconditionally and no further data will get through (and perhaps your sockets eventually fail). At what percent the system merely borders on unusable is left as an exercise to the app developer.
/// This is intended for debugging purposes, to simulate real-world conditions that are various degrees of terrible. You probably should *not* call this in production code, where you'll likely see real failures anyhow.
///
/// - **Parameters:**
///   - `sock`: The socket to set a failure rate on.
///   - `percent_loss`: A number between 0 and 100. Higher means more failures. Zero to disable.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn simulateStreamPacketLoss(sock: ?StreamSocket, percent_loss: c_int) void {
    c.NET_SimulateStreamPacketLoss(if (sock) |resource| @ptrCast(resource.value) else null, percent_loss);
}

/// Drop a reference to an Address.
///
/// Since several pieces of the library might share a single Address, including a background thread that's working on resolving, these objects are referenced counted. This allows everything that's using it to declare they still want it, and drop their reference to the address when they are done with it. The object's resources are freed when the last reference is dropped.
/// This function drops a reference to an Address, decreasing its reference count by one.
/// The documentation will tell you when the app has to explicitly unref an address. For example, resolveHostname() creates addresses that are already referenced, so the caller needs to unref it when done.
///
/// - **Parameters:**
///   - `address`: The Address to drop a reference to.
///
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn unrefAddress(address: ?*Address) void {
    c.NET_UnrefAddress(@ptrCast(address));
}

/// This function gets the version of the dynamically linked SDL_net library.
///
/// - **Returns:** SDL_net version.
/// - **Thread safety:** It is safe to call this function from any thread.
/// - **Since:** This function is available since SDL_net 3.0.0.
pub inline fn version() c_int {
    return c.NET_Version();
}

/// Block until a stream socket has connected to a server.
///
/// The StreamSocket objects returned by createClient take time to do their work, so it does so *asynchronously* instead of making your program wait an indefinite amount of time.
/// However, if you want your program to sleep until the connection is complete, you can call this function.
/// This function takes a timeout value, represented in milliseconds, of how long to wait for resolution to complete. Specifying a timeout of -1 instructs the library to wait indefinitely, and a timeout of 0 just checks the current status and returns immediately (and is functionally equivalent to calling StreamSocket.getConnectionStatus).
/// Connections can fail after some time (server took awhile to respond at all, and then refused the connection outright), so be sure to check the result of this function instead of assuming it worked!
/// Once a connection is successfully made, the socket may read data from, or write data to, the connected server.
/// If you don't want your program to block, you can call StreamSocket.getConnectionStatus() from time to time until you get a non-zero result.
///
/// - **Parameters:**
///   - `sock`: The StreamSocket object to wait on.
///   - `timeout`: Number of milliseconds to wait for resolution to complete. -1 to wait indefinitely, 0 to check once without waiting.
///
/// - **Returns:** Status.success if successfully connected, Status.failure if connection failed, Status.waiting if still connecting (this function timed out without resolution); if Status.failure, call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different socket at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.getConnectionStatus
pub inline fn waitUntilConnected(sock: ?StreamSocket, timeout: i32) Status {
    const result = c.NET_WaitUntilConnected(if (sock) |resource| @ptrCast(resource.value) else null, timeout);
    return @enumFromInt(result);
}

/// Block on multiple sockets until at least one has data available.
///
/// This is a complex function that most apps won't need, but it could be used to implement a more efficient server or i/o thread in some cases.
/// This allows you to give it a list of objects and wait for new input to become available on any of them. The calling thread is put to sleep until such a time.
/// The following things can be specified in the `vsockets` array, cast to `void *`:
/// - Server (reports new input when a connection is ready to be accepted with Server.acceptClient())
/// - StreamSocket (reports new input when the remote end has sent more bytes of data to be read with StreamSocket.readFrom, or if the socket finished making its initial connection).
/// - DatagramSocket (reports new input when a new packet arrives that can be read with DatagramSocket.receive).
/// This function takes a timeout value, represented in milliseconds, of how long to wait for resolution to complete. Specifying a timeout of -1 instructs the library to wait indefinitely, and a timeout of 0 just checks the current status and returns immediately.
/// This returns the number of items that have new input, but it does not tell you which ones; since access to them is non-blocking, you can just try to read from each of them and see which are ready. If nothing is ready and the timeout is reached, this returns zero. On error, this returns -1.
///
/// - **Parameters:**
///   - `vsockets`: an array of pointers to various objects that can be waited on, each cast to a void pointer.
///   - `numsockets`: the number of pointers in the `vsockets` array.
///   - `timeout`: Number of milliseconds to wait for new input to become available. -1 to wait indefinitely, 0 to check once without waiting.
///
/// - **Returns:** the number of items that have new input, or -1 on error.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** createDatagramSocket
/// - **See also:** DatagramSocket.send
/// - **See also:** DatagramSocket.receive
///
/// Returns `error.SdlFailure` when SDL_net reports failure.
pub inline fn waitUntilInputAvailable(vsockets: ?*?*anyopaque, numsockets: c_int, timeout: i32) sdl.Error!c_int {
    const result = c.NET_WaitUntilInputAvailable(@ptrCast(vsockets), numsockets, timeout);
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Block until an address is resolved.
///
/// The Address objects returned by resolveHostname take time to do their work, so it does so *asynchronously* instead of making your program wait an indefinite amount of time.
/// However, if you want your program to sleep until the address resolution is complete, you can call this function.
/// This function takes a timeout value, represented in milliseconds, of how long to wait for resolution to complete. Specifying a timeout of -1 instructs the library to wait indefinitely, and a timeout of 0 just checks the current status and returns immediately (and is functionally equivalent to calling getAddressStatus).
/// Resolution can fail after some time (DNS server took awhile to reply that the hostname isn't recognized, etc), so be sure to check the result of this function instead of assuming it worked!
/// Once an address is successfully resolved, it can be used to connect to the host represented by the address.
/// If you don't want your program to block, you can call getAddressStatus from time to time until you get a non-zero result.
///
/// - **Parameters:**
///   - `address`: The Address object to wait on.
///   - `timeout`: Number of milliseconds to wait for resolution to complete. -1 to wait indefinitely, 0 to check once without waiting.
///
/// - **Returns:** Status.success if successfully resolved, Status.failure if resolution failed, Status.waiting if still resolving (this function timed out without resolution); if Status.failure, call sdl.error_.get() for details.
/// - **Thread safety:** It is safe to call this function from any thread, and several threads can block on the same address simultaneously.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** getAddressStatus
pub inline fn waitUntilResolved(address: ?*Address, timeout: i32) Status {
    const result = c.NET_WaitUntilResolved(@ptrCast(address), timeout);
    return @enumFromInt(result);
}

/// Block until all of a stream socket's pending data is sent.
///
/// If StreamSocket.writeTo() couldn't send all its data immediately, it will queue it to be sent later. This function lets the app sleep until all the data is transmitted.
/// This function takes a timeout value, represented in milliseconds, of how long to wait for transmission to complete. Specifying a timeout of -1 instructs the library to wait indefinitely, and a timeout of 0 just checks the current status and returns immediately (and is functionally equivalent to calling StreamSocket.getPendingWrites).
/// If you don't want your program to block, you can call StreamSocket.getPendingWrites from time to time until you get a result <= 0.
/// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning -1. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
///
/// - **Parameters:**
///   - `sock`: the stream socket to wait on.
///   - `timeout`: Number of milliseconds to wait for draining to complete. -1 to wait indefinitely, 0 to check once without waiting.
///
/// - **Returns:** number of bytes still pending transmission, -1 on failure; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.writeTo
/// - **See also:** StreamSocket.getPendingWrites
///
/// Returns `error.SdlFailure` when SDL_net reports failure.
pub inline fn waitUntilStreamSocketDrained(sock: ?StreamSocket, timeout: i32) sdl.Error!c_int {
    const result = c.NET_WaitUntilStreamSocketDrained(if (sock) |resource| @ptrCast(resource.value) else null, timeout);
    if (result < 0) return error.SdlFailure;
    return result;
}

/// Send bytes over a stream socket to a remote system.
///
/// Stream sockets are *reliable*, which means data sent over them will arrive in the order it was transmitted, and the system will retransmit data as necessary to ensure its delivery. Which is to say, short of catastrophic failure, data will arrive, possibly with severe delays. Also, "catastrophic
/// failure" isn't an uncommon event.
/// (This is opposed to Datagram sockets, which send chunks of data that might arrive in any order, or not arrive at all, but you never wait for missing chunks to show up.)
/// Stream sockets are *bidirectional*; you can read and write from the same stream, and the other end of the connection can, too.
/// This call never blocks; if it can't send the data immediately, the library will queue it for later transmission. You can use StreamSocket.getPendingWrites() to see how much is still queued for later transmission, or StreamSocket.waitUntilDrained() to block until all pending data has been sent.
/// If the connection has failed (remote side dropped us, or one of a million other networking failures occurred), this function will report failure by returning false. Stream sockets only report failure for unrecoverable conditions; once a stream socket fails, you should assume it is no longer usable and should destroy it with StreamSocket.deinit().
///
/// - **Parameters:**
///   - `sock`: the stream socket to send data through.
///   - `buf`: a pointer to the data to send.
///
/// - **Returns:** true if data sent or queued for transmission, false on failure; call sdl.error_.get() for details.
/// - **Thread safety:** You should not operate on the same socket from multiple threads at the same time without supplying a serialization mechanism. However, different threads may access different sockets at the same time without problems.
/// - **Since:** This function is available since SDL_net 3.0.0.
/// - **See also:** StreamSocket.getPendingWrites
/// - **See also:** StreamSocket.waitUntilDrained
/// - **See also:** StreamSocket.readFrom
pub inline fn writeToStreamSocket(sock: ?StreamSocket, buf: []const u8) bool {
    return c.NET_WriteToStreamSocket(if (sock) |resource| @ptrCast(resource.value) else null, @ptrCast(buf.ptr), @intCast(buf.len));
}
