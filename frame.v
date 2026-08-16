import crypto.rand
import net

fn write_frame(mut socket net.TcpConn, opcode u8, payload []u8) ! {
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

fn send_text(mut socket net.TcpConn, text string) ! {
  write_frame(mut socket, f_text, text.bytes())!
}
