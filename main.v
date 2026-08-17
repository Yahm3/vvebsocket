module main
import websocket

fn main() {
  println('Connecting...')
  mut ws_sockect := connect(tcp_ip, tcp_port) or {
    eprintln('Failed to connect:${err}')
    return
  }
}
