addpath('harris')
addpath('transformation')

readnew = 1;

tic
if readnew
    clear
    I1 = imread('images/rescaled/00.jpg');
    I2 = imread('images/rescaled/22.jpg');
    if length(size(I1)) == 3
        I1 = rgb2gray(I1);
        I2 = rgb2gray(I2);        
    end
    
    I1 = im2single(I1);
    I2 = im2single(I2);    
    
    % Automatic Point of Interest Detector
    qual = 0.01;
    poi1 = myHarris(I1,qual);
    poi2 = myHarris(I2,qual);
    
    [f1, validpts1] = extractFeatures(I1, poi1);
    [f2, validpts2] = extractFeatures(I2, poi2);
    
    map12 = nnMatch(f1, f2, 0.6);
    mp12_1 = validpts1(map12(:,1),:);
    mp12_2 = validpts2(map12(:,2),:);
end


ransacTh = 50;

%% DONT FORGET TO INCLUDE THIS NOTE IN THE REPORT
% NOTE: HA is only high in H12 because of a few outliers in the matched
% points which have a distance >300. The actual image(turn vis on) is
% actually a reasonably close match
rng default
niter = 100;
N = round(logspace(log10(4),log10(size(mp12_1,1)),10));
HA_ransac = zeros(length(N),1);
HA_noRansac = zeros(length(N),1);
Noutliers = zeros(length(N),1);
for i = 1:length(N)
    n = N(i);        
    % Run for each n multiple times to get statistical convergence
    ha = zeros(1,niter); 
    haransac = zeros(1,niter); 
    noutliers = zeros(1,niter);
    for iter = 1:niter        
        idx = randperm(size(mp12_1,1),n);
        MP1 = mp12_1(idx,:);
        MP2 = mp12_2(idx,:);
        % Without RANSAC
        H = homography_solve(MP2', MP1');
        [HA, ~] = homography_accuracy(H, MP2, MP1);
        % [HA, ~] = homography_accuracy(H, MP2, MP1);
        ha(iter) = HA;
        % With RANSAC
        [H,inliers] = homography_solveRANSAC(MP2, MP1, ransacTh);
        [HA, ~] = homography_accuracy(H, MP2(inliers,:), MP1(inliers,:));
%         [HA, ~] = homography_accuracy(H, MP2, MP1);
        haransac(iter) = HA;
        noutliers(iter) = size(MP2,1)-length(inliers);
    end
    %% Remove outliers(90% confidence interval)
    ha = sort(ha);
    ha = ha(10:end-10);
    ha = mean(ha);
    haransac = sort(haransac);
    haransac = haransac(10:end-10);    
    haransac = mean(haransac);
    noutliers = sort(noutliers);
    noutliers = noutliers(10:end-10);
    noutliers = mean(noutliers);   
    HA_noRansac(i) = ha;
    HA_ransac(i) = haransac;
    Noutliers(i) = round(noutliers);
    fprintf('n=%i (HA=%.2f  |  HAransac=%.2f  |  Noutliers=%.0f)\n',n,ha,haransac,noutliers)
end
toc

%% Plot results
figure;
plot(N,HA_noRansac,'bx-');
xlabel('Number of Correspondences Used');
ylabel('Homography Accuracy');
title('HA as a function of # of Correspondences Used(No RANSAC)')
axis([0,inf,0,inf])
grid minor
set(gcf,'units','points','position',[100,100,400,200])

figure;
plot(N,HA_ransac,'bx-');
xlabel('Number of Correspondences Used');
ylabel('Homography Accuracy');
title('HA as a function of # of Correspondences Used(RANSAC)')
axis([0,inf,0,inf])
grid minor
set(gcf,'units','points','position',[100,100,400,200])

figure;
plot(N,Noutliers,'bx-');
xlabel('Number of Correspondences Used');
ylabel('Number of Outliers');
title('Number of Outliers vs # of Correspondences Used')
axis([0,inf,0,inf])
grid minor
set(gcf,'units','points','position',[100,100,400,200])














