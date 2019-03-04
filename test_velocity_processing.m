t = linspace(1.0, 5.0, 401); # 4s data at 100fps
a = floor(rand * 3);
x = 4 * a * sin(3 * a * t) - 0.1 * t .^ (2 + a) - 2.0 * t .^ (1 + a) - 12.4; # some random polynomial
v = 4 * a ^ 2 * 3 * cos(3 * a * t) - 0.1 * (2 + a) * t .^ (1 + a) - 2.0 * (1 + a) * t .^ a; # derivative - this is what we're aiming for

# the actual reading have noise and position is 'rounded' to the nearest pixel
x_pix = round(x + (randn(size(t)) * 1.0 - 0.5));

# to work out the velocity take the difference in position and divide by the time
v_pix = (x_pix(2:end) - x_pix(1:end-1)) ./ (t(2:end) - t(1:end-1));

# it's obvious on the left graphs that the rounding to nearest pixel swamps the
# underlying physical data
useful_functions; # now contains movmean

# option 0. simple smoothing without removing outliers
######################################################
L = 21;
v_smoothed_0 = movmean(v_pix, L); # movmean() now in useful_functions
# this doesn't look too bad: magenta on the graphs

# option 1. do noise reduction as per Wilson et al
##################################################
# add N on start and end with mean of first and last M values
N = 50; # half the window size (i.e. 100 points)
M = 5; # used for finding the mean to extrapolate either end
P = 21; # final moving average window.

v_smoothed_1 = wilson(v_pix, N, M, P, 2.0); # wilson() now in useful_functions
# final result is yellow in the graphs. This processing definitely seems to have produced
# some anomolous variation.

# option 2. do simple smoothing of simple smoothing!.
######################################################
Q = 21;
v_smoothed_2 = movmean(v_smoothed_0, Q); # smooth the already averaged figures
# shown as blue and black on the graphs. These are definitely closer to the expected
# line apart from the initial 'window' number of points.
v_smoothed_3 = movmean(v_pix, L + Q);
# final comparison using a single wider smoothing window

figure
subplot(2,2,1);
plot(t, x, '-r', t, x_pix, '+g');
title("Displacement");
legend("underlying physical reality", "experimental readings");

subplot(2,2,3);
plot(t(2:end), v(2:end), '-r', t(2:end), v_pix, '+g', t(2:end), v_smoothed_0, '+m');
title("Velocity");

subplot(2,2,2);
plot(t(2:end), v(2:end), '-r', t(2:end), v_pix_culled, '+b', t(2:end), v_smoothed_1, '+y', t(2:end), v_smoothed_0, '+m');
title("Using Wilson et al method");

subplot(2,2,4);
plot(t(2:end), v(2:end), '-r', t(2:end), v_smoothed_2, '.k', t(2:end), v_smoothed_1, '+y', t(2:end), v_smoothed_0, '+m', t(2:end), v_smoothed_3, 'ob');