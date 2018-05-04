clear;
close all;
clc;
disp 'PARSING EULER RESPONSES'
parseEulerResponses();
disp 'PARSING BARS RESPONSES'
parseBarsResponses();
disp 'BUILDING DATASET'
buildDatasetTable();
disp 'CLUSTERING'
treeClassification();
disp 'BUILDING RESULTS TABLE'
buildClassesTable();