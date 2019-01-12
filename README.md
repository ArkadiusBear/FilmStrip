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
-Size | No | String | Size of final image, different sizes are given below in separate table, default is Medium
-Ratio | No | Int | Ratio of Width to Height, default is 3, minimum value is 1, maximum value is 10
-Density | No | Int | The number of strips created, default value is 200. Greater number will take longer as more frames have to be extracted and added to final image
-Orientation | No | String | Must be either Landscape or Portrait, default being Landscape
-KeepFrames | No | Switch | Decides whether to keep the frames generated, default is false (delete temp frames and folder)

Final image size is determined using the Size, Ratio and orientation. The Size parameter always determines the length of the shorter side and the Ratio is used to calculate the length of the longer side. For example, using a Medium size with a ratio of 3 and an orientation of landscape (i.e. all the defaults) you will generate an image 1500 pixels in width and 500 pixels in height. Note that although the ratio and size have a maximum, generating a image 2000x20000 will not only take a long time but will be a big file:

Value | Pixels
--- | ---
Tiny | 100
Small | 300
Medium | 500
Large | 1000
Massive | 2000

Note also that if a density is entered larger than the width/height of the image (depending on the orientation), the density will simply be set to the width/height as there is no point trying to draw strips less than a pixel in width.

Originally I was using the PNG format for the final image file however I switched to BMP as this greatly improved the speed of the overall process however this does create a far greater file size but as it's only a single image file this shouldn't be much of an issue. The frames created by ffmpeg are all in PNG as the program only needs the average colour, image quality is not much of a concern.
