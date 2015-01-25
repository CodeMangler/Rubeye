require 'optparse'
require 'opencv'
include OpenCV

@video_file = nil

OptionParser.new do |opts|
  opts.on('-v', '--video VIDEO_FILE', 'Path to the video file to be analyzed') do |video|
    @video_file = video
  end
end.parse! ARGV

SKIN_LOW = CvScalar.new(0, 48, 80)
SKIN_HIGH = CvScalar.new(20, 255, 255)

camera = CvCapture.open(@video_file || 0)
window = GUI::Window.new('Skin Detector')
loop do
  image = camera.query

  # Convert to HSV
  hsv_image = image.BGR2HSV

  # Obtain pixel intensities within the skin range
  skin_mask = hsv_image.in_range(SKIN_LOW, SKIN_HIGH)

  # Apply a series of erosions and dilations to the mask using an elliptical kernel
  kernel = IplConvKernel.new(11, 11, 0, 0, :ellipse)
  skin_mask = skin_mask.erode(kernel, 2)
  skin_mask = skin_mask.dilate(kernel, 2)

  # Blur the mask to dampen noise
  skin_mask = skin_mask.smooth(CV_GAUSSIAN, 3, 3, 0).GRAY2BGR

  # Apply mask to the frame
  skin = image.and(skin_mask)

  window.show skin
  break if image.nil? || GUI::wait_key(100)
end
