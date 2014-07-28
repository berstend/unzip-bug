util = require 'util'

# node v0.10+ use native Transform, else polyfill
Transform = require('stream').Transform or require('readable-stream').Transform

class Crx2zip extends Transform
  firstChunk = true

  calcLength: (a, b, c, d) ->
    length = 0
    length += a
    length += b << 8
    length += c << 16
    length += d << 24
    return length

  _transform: (chunk, enc, cb) ->
    if firstChunk
      firstChunk = false

      console.info 'Signature pre transform', chunk.readUInt32LE(0).toString(16)

      # 50 4b 03 04
      if chunk[0] is 80 and chunk[1] is 75 and chunk[2] is 3 and chunk[3] is 4
        return cb new Error('Input is not a CRX file, but a ZIP file.')
      # 43 72 32 34
      if chunk[0] isnt 67 or chunk[1] isnt 114 or chunk[2] isnt 50 or chunk[3] isnt 52
        return cb new Error('Invalid header: Does not start with Cr24.')
      # 02 00 00 00
      if chunk[4] isnt 2 or chunk[5] or chunk[6] or chunk[7]
        return cb new Error('Unexpected crx format version number.')

      publicKeyLength = @calcLength(chunk[8], chunk[9], chunk[10], chunk[11])
      signatureLength = @calcLength(chunk[12], chunk[13], chunk[14], chunk[15])

      # 16 = Magic number (4), CRX format version (4), lengths (2x4)
      zipStartOffset = 16 + publicKeyLength + signatureLength

      chunk = chunk.slice zipStartOffset # Slice off 306 bytes
      console.info 'Signature post transform', chunk.readUInt32LE(0).toString(16)

    @push chunk, enc
    cb()

module.exports = Crx2zip