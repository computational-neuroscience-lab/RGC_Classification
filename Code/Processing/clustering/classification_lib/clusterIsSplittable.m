function isSplittable = clusterIsSplittable(indexesClass)

global refFeatures;
global splittableMinSize;
global splittableMinSTD;

sizeClass = length(indexesClass);
classFeatures = refFeatures(indexesClass, :);
avgSTD = mean(std(classFeatures, [], 1));

isSplittable = and(sizeClass > splittableMinSize, avgSTD > splittableMinSTD);