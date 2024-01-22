--package.cpath = package.cpath .. ";/usr/local/share/lua/5.4/;"
local socket = require "socket"

--[[
host = "www.lua.org"
file = "/manual/5.3/manual.html"
--]]
--[[
c = assert(socket.connect(host, 80))

local request = string.format("GET %s HTTP/1.0\r\nhost: %s\r\n\r\n", file, host)
c:send(request)

repeat
    local s, status, partial = c:receive(2^10)
    io.write(s or partial)
until status == "closed"
--]]

--[[
function download (host, file)
    local c = assert(socket.connect(host, 80))
    local count = 0 -- counts number of bytes read
    local request = string.format(
        "GET %s HTTP/1.0\r\nhost: %s\r\n\r\n", file, host)
    c:send(request)
    while true do
        local s, status = receive(c)
        count = count + #s
        if status == "closed" then break end
    end
    c:close()
    print(file, count)
end
--]]
--[[
function receive (connection)
    local s, status, partial = connection:receive(2^10)
    return s or partial, status
end
--]]
--[[
function receive (connection)
    connection:settimeout(0) -- do not block
    local s, status, partial = connection:receive(2^10)
    if status == "timeout" then
        coroutine.yield(connection)
    end
    return s or partial, status
end

tasks = {} -- list of all live tasks
function get (host, file)
    -- create coroutine for a task
    local co = coroutine.wrap(function ()
        download(host, file)
    end)
    -- insert it in the list
    table.insert(tasks, co)
end

function dispatch ()
    local i = 1
    while true do
        if tasks[i] == nil then -- no other tasks?
            if tasks[1] == nil then -- list is empty?
                break -- break the loop
            end
            i = 1 -- else restart the loop
        end
    
        local res = tasks[i]() -- run a task
        if not res then -- task finished?
            table.remove(tasks, i)
        else
            i = i + 1 -- go to next task
        end
    end
end

function dispatch ()
    local i = 1
    local timedout = {}
    while true do
        if tasks[i] == nil then  -- no other tasks?
            if tasks[1] == nil then  -- list is empty?
                break  -- break the loop
            end
            i = 1  -- else restart the loop
            timedout = {}
        end
        local res = tasks[i]() -- run a task
        if not res then -- task finished?
            table.remove(tasks, i)
        else -- time out
            i = i + 1
            timedout[#timedout + 1] = res
            if #timedout == #tasks then
                -- all tasks blocked?
                socket.select(timedout)
                -- wait
            end
        end
    end
end

get("www.lua.org", "/ftp/lua-5.3.2.tar.gz")
get("www.lua.org", "/ftp/lua-5.3.1.tar.gz")
get("www.lua.org", "/ftp/lua-5.3.0.tar.gz")
get("www.lua.org", "/ftp/lua-5.2.4.tar.gz")
get("www.lua.org", "/ftp/lua-5.2.3.tar.gz")
dispatch() -- main loop
--]]
--[===[
local socket = require("socket")

-- Create a TCP server socket
local server = assert(socket.bind("*", 8080))

-- Set the server socket as non-blocking
server:settimeout(0)

-- List of client sockets
local clients = {}

-- Main server loop
while true do
    -- Wait for any socket to become ready for I/O
    local ready, _, err = socket.select({server, table.unpack(clients)})

    -- Check for errors
    if err then
        print("Error in select:", err)
        break
    end

    -- Handle ready sockets
    for _, s in ipairs(ready) do
        if s == server then
            -- Accept a new connection and add it to the clients list
            local client = server:accept()
            if client then
                print("New connection:", client)
                table.insert(clients, client)
                client:settimeout(0)
            end
        else
            -- Read data from a client socket
            local data, err = s:receive()
            if data then
                print("Received data:", data)
            elseif err == "closed" then
                -- Remove the closed client socket
                print("Connection closed:", s)
                for i, client in ipairs(clients) do
                    if client == s then
                        table.remove(clients, i)
                        break
                    end
                end
            elseif err == "timeout" then
                -- No data available, do nothing
            else
                print("Error receiving data:", err)
            end
        end
    end

    -- Do some other processing in the main loop

    -- Simulate some non-blocking tasks
    print("Doing some other work...")
    socket.sleep(1)
end

-- Close all client sockets
for _, client in ipairs(clients) do
    client:close()
end

-- Close the server socket
server:close()
--]===]

