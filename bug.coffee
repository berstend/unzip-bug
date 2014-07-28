request = require 'request'
unzip = require 'unzip'
fs = require 'fs'
crx2zip = require './crx2zip'

main = ->
  itemid = 'mpkodmmncpmecaandemchjamhamhjnep'
  url = "http://clients2.google.com/service/update2/crx?response=redirect&x=id%3D#{itemid}%26uc"
  # Vanilla zip file for testing
  # url = "https://dl.dropboxusercontent.com/u/4819069/facebook_share_v2_1200x630_a3.png.zip"
  req = request.get url
  req
    .pipe(new crx2zip())
    .pipe(unzip.Parse())
    .on 'entry', (entry) ->
      console.info entry.path, entry.type, entry.size
      fileName = entry.path
      type = entry.type # 'Directory' or 'File'
      size = entry.size
      if fileName.indexOf('.json') > -1
        console.info 'Found .json', entry.path
        entry.pipe fs.createWriteStream("/tmp/#{entry.path}")
      else
        entry.autodrain()
      return


# Test downloading a .crx while transforming it to .zip, without unpacking.
# Output is a valid zip file and can be unpacked with unzip.
test_case_download_with_crx2zip = ->
  itemid = 'mpkodmmncpmecaandemchjamhamhjnep'
  url = "http://clients2.google.com/service/update2/crx?response=redirect&x=id%3D#{itemid}%26uc"
  output = fs.createWriteStream('/tmp/crx.zip')
  req = request.get url
  req
    .pipe new crx2zip()
    .pipe output


main()
#test_case_download_with_crx2zip()
