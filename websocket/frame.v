module websocket

import crypto.rand
import net

// f_text represents a text frame opcode (0x01).
pub const f_text = 0x01
// f_binary represents a binary data frame opcode (0x02).
pub const f_binary = 0x02
// f_close represents a connection close control frame opcode (0x08).
pub const f_close = 0x08
// f_ping represents a connection ping validation control frame opcode (0x09).
pub const f_ping = 0x09
// f_pong represents a connection pong response validation control frame opcode (0x0A).
pub const f_pong = 0x0A
// buffer_size sets the threshold limit allocating byte blocks.
pub const buffer_size = 1024 * 1024

// read_frame reads and parses an incoming WebSocket frame header and payload from the server.
// It automatically handles unmasking if the server frame is masked.
pub fn read_frame(mut socket net.TcpConn) !([]u8, u8) {
  mut header := []u8{len: 2}
  socket.read(header)!

  opcode := header[0] & 0xff
  mask_bit := (header[1] & 0x80) != 0
  mut payload_len := u64(header[1] & 0x7f)

  if payload_len == 126 {
    mut ext_len := []u8{len: 2}
    socket.read(mut ext_len)!
    payload_len = (u64(ext_len[0] << 8) | u64(ext_len[1]))
  } else if payload_len == 127 {
    mut ext_len := []u8{len: 8}
    socket.read(mut ext_len)!
    payload_len = 0
    for i in 0 .. 8 {
      payload_len = (payload_len << 8) | u64(ext_len[i])
    }
  }

  mut server_mask := []u8{len: 4}
  if mask_bit {
    socket.read(mut server_mask)!
  }

  mut payload := []u8{len: int(payload_len)}
  socket.read(mut payload)!

  if mask_bit {
    for i in 0 .. payload_len {
      payload[i] = payload[i] ^ server_mask[i % 4]
    }
  }

  return payload, opcode
}

// write_frame writes the frame header from the client
// It accepts a mutable net.TcpConn `socket`, u8 `opcode` and a []u8 `payload`
// Returns nothing or an error otherwise
pub fn write_frame(mut socket net.TcpConn, opcode u8, payload []u8) ! {
  mut header := []u8{}
  header << (0x080 | opcode)
  length := payload.len

  if length <= 125 {
    header << u8(0x80 | length)
  } else if length <= 65535 {
    header << u8(0x80 | 126)
    header << u8((length >> 8) & 0xff)
    header << u8(length & 0xff)
  } else {
    header << u8(0x80 | 127)
    for i := 7; i >= 0; i-- {
      header << u8((length >> (i * 8)) & 0xff)
    }
  }

  mask_key := rand.bytes(4)!
  header << mask_key
  mut mask_payload := []u8{len: length}

  for i in 0 .. length {
    mask_payload[i] = payload[i] ^ mask_key[i % 4]
  }

  socket.write(header)!
  socket.write(mask_payload)!
}

// send_text transmits standard UTF-8 text encoded payload frames to the server.
pub fn send_text(mut socket net.TcpConn, text string) ! {
  write_frame(mut socket, f_text, text.bytes())!
}
