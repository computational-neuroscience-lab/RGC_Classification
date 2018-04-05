function [X, coeff] = doPca(ER, nPrincipalComponents)

% Principal Components Reduction
[nResponses, ~] = size(ER);
meanER = mean(ER, 1);
normER = ER - ones(nResponses,1) * meanER;
[~, ~, coeff] = svd(normER);
X = normER * coeff(:, 1:nPrincipalComponents);