function buildData_to_h5(experimentFolder)
% For each TracesData.h5 file in each experiment folder,
% Extract the ROIs, eliminates the doubles or empty ones,
% Computes the calcium traces, and saves everything back
% in the TracesData.h5 file

tracesPath = strcat(projectPath(), '/Experiments/', experimentFolder, '/traces/TracesData.h5');
if exist(tracesPath, 'file') == 0
    error('ROIs information missing!');
end

fprintf('building Traces for Experiment #%s\n', experimentFolder);
[MapId, Centers] = loadROIs_from_h5(experimentFolder);
[MapId, Centers] = filterBadROIs(MapId, Centers);
saveROIs_to_mat(MapId, Centers, experimentFolder);
saveROIs_to_h5(MapId, Centers, experimentFolder);
generateTraces_to_h5(experimentFolder);



