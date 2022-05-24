function resampledTrace = resampleTrace(trace, freqVisualStim, freqCalciumImaging)
% Resample Stimuli
timeV = 0 : 1/freqVisualStim : (length(trace)/freqVisualStim - 1/freqVisualStim);
timeSeries = timeseries(trace, timeV);

resampleTimeV = 0 : 1/freqCalciumImaging : (length(trace)/freqVisualStim - 1/freqCalciumImaging);
resampledTimeSeries = resample(timeSeries, resampleTimeV);
resampledTrace = squeeze(resampledTimeSeries.data);
