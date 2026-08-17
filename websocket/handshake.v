module websocket

const tcp_ip = '127.0.0.1'
const tcp_port = 80

// client_handshake manages the opening upgrade sequence to initialize a WebSocket connection.
pub fn client_handshake(mut socket net.TcpConn, host string, port int) ! {
  mut handshake := 'GET / HTTP/1.1\r\n'
  handshake += 'Host: ${host}:${port}\r\n'
  handshake += 'Upgrade: websocket\r\n'
  handshake += 'Connection: Upgrade\r\n'
  handshake += 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n'
  handshake += 'Sec-WebSocket-Version: 13\r\n'
  handshake += '\r\n'

  socket.write_string(handshake)! //:NOTE: Send the Handshake to the server

  mut buffer := []u8{len: 1024}
  bytes_read := socket.read(mut buffer)!
  response   := buffer[..bytes_read].bytestr()

  if !response.starts_with('HTTP/1.1 101') {
    return error('Handshake failed: Server did not return 101 Switching Protocols.\nResponse:\n${response}')
  }
  //:TODO: Validate the 'Sec-WebSocket-Accept' header
}

// connect establishes an active TCP stream to the target host and validates the handshake protocols.
pub fn connect(host string, port int) !net.TcpConn {
  mut socket := net.dial_tcp('${host}:${port}')!
  socket.set_read_timeout(5 * time.second) //:NOTE: Let's avoid some hanging
  client_handshake(mut socket, host, port)!
  println('WebSocket connected successfully!')
  return *socket
}
