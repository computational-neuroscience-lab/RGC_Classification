function printClassTree(class, spaces)

if ~exist('class','var')
    class = "";
end

if ~exist('spaces','var')
    spaces = "";
end
    
    classes = getSubclasses(class);
    for class = classes
        fprintf(strcat(spaces, class,"\n"))
        printClassTree(class, strcat(spaces, '\t'));
    end
end

