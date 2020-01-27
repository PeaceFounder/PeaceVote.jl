import Serialization

function stack(io::IO,msg::Vector{UInt8})
    frontbytes = reinterpret(UInt8,Int16[length(msg)])
    item = UInt8[frontbytes...,msg...]
    write(io,item)
end

function unstack(io::IO)
    sizebytes = [read(io,UInt8),read(io,UInt8)]
    size = reinterpret(Int16,sizebytes)[1]
    
    msg = UInt8[]
    for i in 1:size
        push!(msg,read(io,UInt8))
    end
    return msg
end

function unstack(io::IOBuffer)
    bytes = take!(io)
    size = reinterpret(Int16,bytes[1:2])[1]
    msg = bytes[3:size+2]
    if length(bytes)>size+2
        write(io,bytes[size+3:end])
    end
    return msg
end

function serialize(socket,msg)
    io = IOBuffer()
    Serialization.serialize(io,msg)
    bytes = take!(io)
    stack(socket,bytes)
end

function deserialize(socket)
    bytes = unstack(socket)
    io = IOBuffer(bytes)
    Serialization.deserialize(io)
end
