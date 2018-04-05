function plotSubClusters(classId, pcaSpace)
if ~exist('pcaSpace', 'var')
    pcaSpace = getPCASpace(classId);
end
subclasses = getSubclasses(classId);
if numel(subclasses) > 0
    plotClassClusters(subclasses,  pcaSpace);
end
