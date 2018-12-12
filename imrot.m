function [corr] = imrot(im, r1, c1, r2, c2, c, contour1, contour2, Np)
    #
    # [corr] = imrot(C,R,1)
    #
    # Function to rotate image with contour plot
    # (1) Fits a curve through values extracted from the contour plot (C,R)
    # (2) Finds the angle between the fit and the horizontal (= rotation angle)
    #
    # Inputs
    # im         image (converted to double, not yet squeezed to 2D
    # r1,r2      y coordinates of points on contour plot (rows)
    # c1,c2      x coordinates of points on contour plot (columns)
    # c          +1 or -1 for clockwise or counterclockwise rotation
    # contour1   contour 1 from which r1,c1 are extracted   
    # contour2   contour 2 from which r2,c2 are extracted
    # Np         Np is the highest power of the polynomial fit (1 = linear fit)
    #
    # Outputs
    # corr     rotation angle (degrees)

    im = squeeze(im);
    [R1, C1] = find(im(r1, c1) == contour1);
    [R2, C2] = find(im(r2, c2) == contour2);
    R = [R1; R2];
    C = [C1; C2];

    # fit linear curve through points
    p = polyfit(C, R, Np);
    min(C(:))
    max(C(:))
    Cr = min(C(:)) + (max(C(:)) - min(C(:))) * [0:100]' / 100;
    Rr = polyval(p, Cr);

    # calculate angle with tangent
    cc = max(Cr(:)) - min(Cr(:)); # adjacent
    rr = max(Rr(:)) - min(Rr(:)); # opposite
    corr = atand(rr / cc) * c;

    figure
    subplot(2, 1, 1), plot(C, R, '.k');
    subplot(2, 1, 2), plot(C, R, '.k', Cr, Rr);

    gaus1 = fspecial('gaussian', 1);
    gaus2 = fspecial('gaussian', 8);
    im1 = imfilter(im, gaus1);
    im2 = imfilter(im, gaus2);

    figure
    imagesc(imrotate(im2 - im1, corr));
endfunction