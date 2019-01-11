# FilmStrip
Generates colour schemes of films by calculating the average colour of a range of frames taken from a video file. Uses ffmpeg and image magick under the hood to do all the video manipulation and image conversion.

Stages of script are as follows:
* Validate video file exists and create image path in the same folder
* Get length of video file, create colour array and generate the base image file
* Within a loop:
    * Extract frame from video file
    * Compress this frame to a 1x1 image and extract colour
    * Add a strip of this colour to the base image file at the correct location
* Cleanup temp folder containing frames
* Display final image to user

The standalone binaries are used for the following purposes: 
* ffprobe.exe simply gets the length of the video file in seconds
* ffmpeg.exe extracts a frame from the video file at a specified time
* imagemagick.exe creates the base image and also adds strips to it

The script has multiple parameters, some mandatory and some optional: 

Parameter | Mandatory | Type | Description
--- | --- | --- | ---
-VideoFile | Yes | String | Path to the video file, has to be a valid path
-Height | No | Int | Height of final image in pixels, default value is 1500, can be within the range of 100 to 4000
-Width | No | Int | Width of final image in pixels, default value is 500, can be within the range of 100 to 4000
-Density | No | Int | The number of strips created, default value is 150. Greater number will take longer as more frames have to be extracted and added to final image
-KeepFrames | No | Switch | Decides whether to keep the frames generated, default is false

Note that although the width and height have limits set on them, they can be easily removed to create a huge image but obviously a larger image will slow down the process. Also note that there is not much point having a density greater than the height of the image as it will try and create a strip smaller than a pixel in width.

Originally I was using the PNG format for the final image file however I switched to BMP as this greatly improved the speed of the overall process however this does create a far greater file size but as it's only a single image file this shouldn't be much of an issue. The frames created by ffmpeg are all in PNG as the program only needs the average colour, image quality is not much of a concern.
