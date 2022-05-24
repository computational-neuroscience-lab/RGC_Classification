function leafClasses = getLeafClasses(class)

if ~exist('class','var')
    class = "";
end

subclasses = getSubclasses(class);

if isempty(subclasses)
    leafClasses = class;
    return;
end

leafClasses =  [];
for subclass = subclasses
    leafClasses = [leafClasses, getLeafClasses(subclass)];
end