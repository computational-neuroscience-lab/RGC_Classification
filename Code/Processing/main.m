clear;
close all;
clc;
% disp 'PARSING EULER RESPONSES'
parseEulerResponses();
% disp 'PARSING BARS RESPONSES'
parseBarsResponses();
disp 'BUILDING DATASET'
buildDatasetTable();
disp 'CLUSTERING'
mainClustering();
disp 'BUILDING RESULTS TABLE'
buildClassesTable();