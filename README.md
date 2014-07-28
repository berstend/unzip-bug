# Meta

crx is the file format of chrome extensions.
It's basically zip with some extra stuff in the beginning.

**Goal:** Fetch crx file, strip crx headers on the fly, pipe it to node-unzip, extract only contents of interest.

---


## Piping a crx directly to node-unzip:

	~/d/t/unzip-bug ❯❯❯ coffee bug.coffee
	stream.js:94
	      throw er; // Unhandled stream error in pipe.
	            ^
	Error: invalid signature: 0x34327243
	  at /Users/user/dev/testing/unzip-bug/node_modules/unzip/lib/parse.js:63:13
	  at process._tickCallback (node.js:343:11)


## node-unzip @parse.js

    var signature = data.readUInt32LE(0);
    if (signature === 0x04034b50) {
      self._readFile();
    } else if (signature === 0x02014b50) {
      self._readCentralDirectoryFileHeader();
    } else if (signature === 0x06054b50) {
      self._readEndOfCentralDirectoryRecord();
    } else {
      err = new Error('invalid signature: 0x' + signature.toString(16));
      self.emit('error', err);
    }


## Slicing away the first 306 bytes off the first chunk results in true .zip

	~/d/t/unzip-bug ❯❯❯ coffee bug.coffee
	Signature pre transform 34327243
	Signature post transform 4034b50
	128.png File undefined
	events.js:85
	      throw er; // Unhandled 'error' event
	            ^
	Error: invalid signature: 0x8080014
	  at /Users/user/dev/testing/unzip-bug/node_modules/unzip/lib/parse.js:63:13
	  at process._tickCallback (node.js:343:11)

4034b50 is a correct .zip

For some reason node-unzip still receives the wrong or corrupt chunk.

## Testing
	npm install
	coffee bug.coffee