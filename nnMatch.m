function [map] = nnMatch( hist1, hist2, ambigTh )
% map: Nx4 matrix
%      column 1 - index in hist1
%      column 2 - index in hist2
%      column 3 - distance from point in hist1 to closest in hist2
%      column 4 - distance from point in hist1 to 2nd closest in hist2

hist1 = (normalize(hist1'))';
hist2 = (normalize(hist2'))';

for i = 1:size(hist1,1)
    for j = 1:size(hist2,1)
        X = hist1(i,:) - hist2(j,:);
        dist(j) = sum(X(:).^2);
    end
     
    [metric, pair] = min(dist);
    dist(pair) = inf;
    metric2 = min(dist);
    map(i,1) = i;
    map(i,2) = pair;
    map(i,3) = metric;
    map(i,4) = metric2;
    
end

%Remove Ambiguous matches
%Handle divide by 0

zeroIdx = (map(:, 4) < 1e-6);
map(zeroIdx,3:4) = 1;

ratio = map(:, 3) ./ map(:,4);
idx = (ratio <= ambigTh);
% All map(zeroIdx) will have ratio = 1 > 0.6 and will be removed
map = map(idx,:);
newmap = zeros(1,4);

for i = 1:size(map,1)
    duplicates = find(map(:,2) == map(i,2));
    v = map(duplicates,3) == min(map(duplicates,3));
    newmap = [newmap;map(duplicates(v),:)];
end 
map = unique(newmap(:,:), 'rows');
map(1,:) = [];
end

function X = normalize(X)
Xnorm = sqrt(sum(X.^2, 1));
X = bsxfun(@rdivide, X, Xnorm);

% Set effective zero length vectors to zero
X(:, (Xnorm <= eps(single(1))) ) = 0;

end