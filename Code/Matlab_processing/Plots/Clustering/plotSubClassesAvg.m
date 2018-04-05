function plotSubClassesAvg(classId)
subclasses = getSubclasses(classId);
if numel(subclasses) > 0
    plotClassAvgResponses(subclasses, strcat(classId, ": Average Subclasses Response"));
end
