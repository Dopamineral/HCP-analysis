function [jac_score,dice_score, rel_volume] = metrics(V1,V2)
%METRICS Summary of this function goes here
%   Detailed explanation goes here
bin1 = ~isnan(V1); % everything that is not nan -> 1, every nan -> 0
bin2 = ~isnan(V2); % everything that is not nan -> 1, every nan -> 0

jac_score = jaccard(bin1,bin2);
dice_score = dice(bin1,bin2);
rel_volume = sum(bin2(:)) / sum(bin1(:));
end

