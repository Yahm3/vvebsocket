module main
import net

const f_text   = 0x01 // f -> frame data
const f_binary = 0x02
const f_close  = 0x08
const f_ping   = 0x09
const f_pong   = 0x0A
const tcp_ip   = '127.0.0.1'
const tcp_port = 80
const buffer_size = 1024 * 1024

fn client_handshake(mut socket net.TcpConn, host string, port int) !net.Addr {
  mut handshake := "GET / HTTP/1.1\r\n"
  handshake += "Host: ${host}:${port}\r\n"
  handshake += "Upgrade: websocket\r\n"
  handshake += 'Connection: Upgrade\r\n'
  handshake += "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
  handshake += "Sec-WebSocket-Version: 13\r\n"
  handshake += "\r\n"

  socket.write_string(handshake)!
  return socket.addr()!
}

fn main() {
}
