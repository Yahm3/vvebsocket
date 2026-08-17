module main
import websocket as ws

fn main() {
  println('Connecting...')
  mut ws_sockect := ws.connect(ws.tcp_ip, ws.tcp_port) or {
    eprintln('Failed to connect:${err}')
    return
  }
}
