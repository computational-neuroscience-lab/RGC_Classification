function filtered = filterTrace(trace, samplingFreq)

% filter
filterOrder = 3;
filterType = 'high';
cutOffFreq =  0.1 ./ (samplingFreq/2);
[b,a] = butter(filterOrder, cutOffFreq, filterType);
filtered = filtfilt(b, a, trace);

% subtract baseline
% baseline = median(filtered(:, 1:8), 2);
% filtered = filtered - baseline;
