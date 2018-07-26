function pcSpace = getPCASpace(classId)

if  endsWith(classId, ".")
    classId = extractBefore(classId, strlength(classId));
end

nLvl = length(strsplit(classId, "."));
pcSpace = strcat("lvl", num2str(nLvl));