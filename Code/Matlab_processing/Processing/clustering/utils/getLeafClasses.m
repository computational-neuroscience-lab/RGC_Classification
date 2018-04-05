function leafClasses = getLeafClasses(class, minClassSize, maxSublevels)

if ~exist('class','var')
    class = "";
end

if ~exist('minClassSize','var')
    minClassSize = 1;
end
    
if ~exist('maxSublevels','var')
    maxSublevels = +Inf;
end

if maxSublevels <= 0
    leafClasses = class;
    return
end
    
subclasses = getSubclasses(class);
if isempty(subclasses)
    leafClasses = class;
    return;
end

leafClasses =  [];
for subclass = subclasses
    if  sum(classIndexes(subclass)) >= minClassSize
        leafClasses = [leafClasses, getLeafClasses(subclass, minClassSize, maxSublevels - 1)];
    end
end

if length(leafClasses) == 0
    leafClasses = class;
end
