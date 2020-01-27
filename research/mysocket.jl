struct MySocket <: IO
    socket
end

import Base.read
read(socket::MySocket,x::Type{UInt8}) = read(socket.socket,x) 

import Base.readavailable
readavailable(socket::MySocket) = readavailable(socket.socket)

#import Base.eof
#eof(socket::MySocket) = eof(socket.socket)

import Base.write
write(socket::MySocket,x::UInt8) = write(socket.socket,x)
write(socket::MySocket,x::String) = write(socket.socket,x)
write(socket::MySocket,x::Vector{UInt8}) = write(socket.socket,x)

# serialize seems to be easally replacable with write. Issue however seems to be how can I read what I send to the socket. Seems I need to implement my own serialize and deserialize methods.

using Sockets

server = listen(2000)
@async global socketA = MySocket(accept(server))
socketB = MySocket(connect(2000))
