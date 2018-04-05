clear;
close all;
clc;
disp 'BUILDING REPOSITORIES'
rebuildAllH5s();
disp 'PARSING EULER RESPONSES'
parseEulerResponses();
disp 'PARSING BARS RESPONSES'
parseBarsResponses();
disp 'BUILDING DATASET'
buildDatasetTable();
disp 'CLUSTERING'
doClassification();