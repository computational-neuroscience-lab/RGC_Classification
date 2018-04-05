function plotSubSets(classId)

subclasses = getSubclasses(classId);
for subclass = subclasses
    plotClassSet(subclass);
end
    


