VarRAW = metaEX$var
VarRAW = gsub("median", "med", VarRAW)
VarRAW = gsub("HYP", "H", VarRAW)
VarRAW = gsub("alpha", "a", VarRAW)
VarRAW = gsub("epsilon", "e", VarRAW)
tmp = gsub("^.*[_]", "", VarRAW)
tmp = gsub("([{])|([}])", "", tmp)
tmp[!grepl("[_]", VarRAW)] = ""
tmp = strrep(".", nchar(tmp))
VarRAW = gsub("[{].*[}]", "", VarRAW)
VarRAW = gsub("[_].*$", "", VarRAW)
VarRAW = paste0(VarRAW, tmp)
VarRAW = strsplit(VarRAW, "*")

convert2space = function (X) {
    X = gsub("[[:digit:]]", "1", X)
    X = gsub("[[:upper:]]", "2", X)
    X = gsub("[[:lower:]]", "1", X)
    X = gsub("([.])|([-])", "1", X)
    return (X)    
}
Space = lapply(VarRAW, convert2space)
Space = lapply(Space, as.numeric)
Space = lapply(Space, sum)
Space = unlist(Space)
