clear;
disp 'PARSING EULER RESPONSES'
parseEulerResponses();
disp 'PARSING BARS RESPONSES'
parseBarsResponses();
disp 'BUILDING DATASET'
buildDataset();
disp 'CLUSTERING'
gmClustering();