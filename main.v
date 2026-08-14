module main
import net

const f_text   = 0x1 // f -> frame data
const f_binary = 0x2
const tcp_ip   = '127.0.0.1'
const tcp_port = 5006
const buffer_size = 1024 * 1024

fn main() {
}

fn client_handshake(client_socket net.Socket,host string) {
  mut handshake := ""
  handshake += "GET / HTTP/1.1\r\n"
  handshake += "Host: ${host}"
  handshake += "Upgrade: websocket\r\n"
  handshake += "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\n"
  handshake += "Sec-WebSocket-Version: 13\r\n"
  handshake += "\r\n"

  client_socket.address(handshake.)
}
