# test image processing
pkg load image;

# stand in function for reading from disk and cropping (and scaling if speeds up)
function new_img = load_image(name)
    new_img = rgb2gray(imread(name)(412:711, 226:1705, :));
    #new_img = imresize(new_img, 0.5);
endfunction

# posterize function creating synthetic colours. This might be better done using
# greyscal image and a standard matlap function - see the bottom and the 2nd image drawn
function new_img = posterize(img)
    threshRGB = [20, 45, 70, 93, 120, 145, 170];
    value =   [10, 22, 33, 89, 193, 223, 238, 251]; # non-linear mapping need to play with this
    new_img = zeros(size(img)); # new empty image
    new_img = imquantize(img, threshRGB, value);
    new_img = uint8(new_img); # has to be converted back to bytes for some reason
endfunction

im1 = load_image('testframes/vid_fr1.bmp');
im2 = load_image('testframes/vid_fr10.bmp');
im3 = load_image('testframes/vid_fr8.bmp');
im4 = load_image('testframes/vid_fr51.bmp');

im = im4 - im1; # differnce from start frame

impo = posterize(im);

figure 34
title('at tm 2.22');
colormap(jet); # more dramatic - look at the docs for available colormaps
imagesc(impo);

THRESH_R = 25; # these might need some tweaking, also crop ranges to get rid of bits at edges
THRESH_C = 7;
dk_orange = impo(:,:) == 193; # look for the red value, 1 if it is, 0 otherwise

##### following lines should print the top and front of the cloud to terminal.
r_edge = find(sum(dk_orange, dim=2) >= THRESH_R)(8) # add rows then find (nearly) first one above threshld count
c_edge = find(sum(dk_orange, dim=1) >= THRESH_C)(end) # add cols and take last one above different thshld
# TODO draw lines on the image
hold on
line([1, c_edge, c_edge], [r_edge, r_edge, size(impo)(1)]);
hold off
