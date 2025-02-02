function [harrCorn, poi, ptsStr] = harris_detector(img, qual, radius, method, disp)
    if isinteger(img)
        img = im2double(img);
    end
    if length(size(img)) == 3
        img = rgb2gray(img); %should i maybe use ycbcr
    end
    
    dx = [-1 0 1];
    dy = dx';
    
    Ix = conv2(img, dx, 'same');    % Image derivatives
    Iy = conv2(img, dy, 'same');    

    % g = fspecial('gaussian',max(1,fix(6*sigma)), sigma);
    g =  [0.03 0.105 0.222 0.286 0.222 0.105 0.03];
    
    Ix2 = conv2(Ix.^2, g, 'same'); % Smoothed squared image derivatives
    Iy2 = conv2(Iy.^2, g, 'same');
    Ixy = conv2(Ix.*Iy, g, 'same');
        
    harrCorn = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps); % Harris corner measure
    harrCorn = abs(harrCorn);
    harrCorn = harrCorn/max(harrCorn(:));
    if method == 1
        k = 0.04;
        harrCorn = (Ix2.*Iy2 - Ixy.^2) - k*(Ix2 + Iy2).^2;       
    end
    thresh = qual*max(harrCorn(:));
    % Non-maximum suppression
    sze = 2*radius+1;                   % Size of mask.
    Mc = ordfilt2(harrCorn,sze^2,ones(sze)); % Grey-scale dilate.
    harrCorn((harrCorn<Mc)|(harrCorn<thresh)) = 0;       % Find maxima.  
    
    % Exclude points very close to image boundaries
    harrCorn(1:3,:) = 0;
    harrCorn(end-2:end,:) = 0;
    harrCorn(:,1:3) = 0;
    harrCorn(:,end-2:end) = 0;
    [r,c] = find(harrCorn);                  % Find row,col coords.        
    if disp      % overlay corners on original image
        figure
        imagesc(img)
        axis image
        colormap(gray)
        hold on
        plot(c,r,'ys')
        title('corners detected');
    end    
    poi = [r,c];
    ptsStr = [];
    for i = 1:length(r)
        ptsStr = [ptsStr; harrCorn(poi(i,1), poi(i,2))];
    end  
%     poi = poi'; ptsStr = ptsStr';
end


