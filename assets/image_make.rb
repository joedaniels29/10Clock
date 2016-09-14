require 'JSON'
require 'ERB'
require 'mini_magick'
require 'fileutils'

DEFAULT_CARD_HEIGHT=380
DEFAULT_CARD_WIDTH=410
ICON_WIDTH = 200
LOGO_WIDTH = ICON_WIDTH * 2

IMAGE_ASSET_LOCATION = './originals'
IMAGE_ASSET_OUTPUT_LOCATION = File.join(".", 'computed')

def base(src)
  File.basename(src, File.extname(src))
end

def asset_relative(string, src)
  File.join('images', string, base(src))
end

def opacify(image)
  image.background 'none'
  image.channel 'rgba'
  image.alpha 'Set'
end

def render(img, output_dir, width, height, dpi=1, fit)
  image = MiniMagick::Image.open(img)
  size_string = "#{(width||1)*dpi}x#{dpi*height}"
  image.format("png") do |cmd|
    # opacify cmd
    cmd.scale(size_string+fit)
    cmd.gravity 'center'
    # cmd.density 300
    # if offset = img['offset']
    #   cmd.crop "+#{dpi*offset['width']}+#{dpi*offset['height']}"
    # end
    cmd.extent size_string
  end


  # opacify image
  image.write File.join(output_dir, "#{base img}#{dpi == 1 ? ".png" : "_#{dpi}x.png"}")
end

HASH = {
    clock: {width: DEFAULT_CARD_WIDTH, height: DEFAULT_CARD_HEIGHT },#fit: "^"
    display: {width: LOGO_WIDTH, height: ICON_WIDTH},
}
types = HASH


# images
Dir[IMAGE_ASSET_LOCATION + "/*"].each do |p|
    render(p, IMAGE_ASSET_OUTPUT_LOCATION, types[:clock][:width], types[:clock][:height], 1, types[:clock][:fit] || "")
end
