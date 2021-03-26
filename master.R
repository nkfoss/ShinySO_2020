# Translate the selected dev variable into the appropriate title
selectedDevTitle <- function(devSelect) {
  return(switch(devSelect,
                "DEVdea" = "Developer, Desktop or Enterprise", 
                "DEVfs" = "Developer, Full-Stack", 
                "DEVmob" = "Developer, Mobile", 
                "DEVdes" = "Designer", 
                "DEVfe" = "Developer, Front End", 
                "DEVba" = "Developer, Back End", 
                "DEVqa" = "Developer, QA or Testing", 
                "DEVops" = "DevOps Specialist", 
                "DEVgg" = "Developer, Games or Graphics",
                "DEVdba" = "Database Admin", 
                "DEVemb" = "Developer, Embedded Applications", 
                'DEVde' = "Data Engineer",
                'DEVedu' = "Educator", 
                'DEVsysadm' = "Systems Administrator", 
                'DEVmaneng' = "Engineer, Manager", 
                'DEVmanprod' = "Product Manager", 
                'DEVbiz' = "Business Analyst", 
                'DEVacdres' = "Academic Researcher", 
                'DEVmlds' = "Data Scientist  / ML Specialist", 
                "DEVsci" = "Scientist", 
                'DEVdbag' = "Executive  / VP", 
                'DEVengsr' = "Engineer, Site Reliability", 
                'DEVsales' = "Sales / Marketing",
                devSelect))
}

########################################################################

# Turn the tech variable into an appropriate string titles/labels
formatTechString <-function(techSelect) {
  techSelect <- switch(techSelect, 
                 "NEWCollabToolsDesireNextYear" = "Collaboration tool",
                 "MiscTechDesireNextYear" = "Misc. technologie",
                 "DatabaseDesireNextYear" = "Database technolgie",
                 "LanguageDesireNextYear" = "Language",
                 "PlatformDesireNextYear" = "Platform",
                 "WebframeDesireNextYear" = "Webframe",
                 techSelect)
  return( paste0(techSelect, 's') )  # Add an 's' before returning
}

#############################################################################

# Let devTypes be the column from the devs table.
# BE SURE THAT THE COLUMN IS THE DOUBLE BRACKETS VERSION ( so2020[["DevType"]] )
getDevBools <- function(devTypes, column) {
  boolMatrix = matrix(nrow = length(column), ncol=length(devTypes))
  for (i in 1:length(devTypes)) {
    devType = devTypes[i]  # Set aside the devtype.
    boolMatrix[,i] = grepl(devType, column)  # Set the corresponding matrix column to the boolean vector for matching the devtype.
  }
  toReturn = data.frame(boolMatrix)
  colnames(toReturn) = c("DEVdea", "DEVfs", "DEVmob", "DEVdes", "DEVfe", "DEVba", "DEVqa", "DEVops", "DEVgg",
                         "DEVdba", "DEVemb", 'DEVde', 'DEVedu', 'DEVsysadm', 'DEVmaneng', 'DEVmanprod', 'DEVbiz', 
                         'DEVacdres', 'DEVmlds', "DEVsci", 'DEVdbag', 'DEVengsr', 'DEVsales')
  return( toReturn )
}

###############################################################################

## Notes about this, be sure to convert your column first.
# Like this: column = table[[columnName]] ...
# BE SURE TO USE THE DOUBLE BRACKETS!
countEntries <- function(column) {
  
  colVector = as.vector(column); # You must turn this into vector first.
  
  techVector = vector();
  countVector = vector(); # Initialize vectors for the entries and counts
  
  # Go through each response, and exclude NAs
  for (repsonse in colVector[!is.na(colVector)] ) { 
    entriesVector <- strsplit(repsonse, ";")[[1]] ;
    
    # For each entry indicated in the response...
    for (entry in entriesVector) {
      nameIndex = match(entry, techVector); # See if it already exists in nameVector
      
      # If we can't find the name of the technology in our vector, then we need to add it (and the count).
      if (is.na(nameIndex)) {
        techVector = c(techVector, entry);
        countVector = c(countVector, 1);
      } 
      # If did find it, we use the nameIndex to increment it in the count vector
      else {
        countVector[nameIndex] = countVector[nameIndex] + 1
      }
    }
  }
  return( data.frame(techVector, countVector) )
}

#####################################################################################

# Returns a vector for the desired technology, BUT ONLY WITH THE SELECTED DEVS
makeDevVector <- function(devTechTable, techSelect, devSelect) {
  devBool = devTechTable[[devSelect]]  #  boolean vector...the respondents who matched that dev role.
  return (devTechTable[devBool, ][[techSelect]])
}



#########################################################################################
#####    The mother of all functions. Returns the graph to be rendered.   ###############
#########################################################################################



makeBarGraph <- function(devTechTable, techSelect, devSelect) {
  
  tallied = countEntries(devTechTable[[techSelect]]) # A tally of desire for selected technology
  n1 = nrow(devTechTable) # For calculations, and labels
  tallied$countVector = tallied$countVector/n1  # Translate counts to proportions
  
  
  # If we are comparing a specific role to the average...
  if (devSelect != 'all') {
    devVector = makeDevVector(devTechTable, techSelect, devSelect) # Make a vector selecting for rows matching the dev-type
    tallied_DEV = countEntries(devVector)  # Make a tally table, to be combined with the first tally table.
    n2 = length(devVector)  # reset n2 for calculations and labels
    tallied_DEV$countVector = tallied_DEV$countVector/n2 # Translate counts to proportions
    
    tallied_DEV$role = selectedDevTitle(devSelect)   # add a new column to differentiate when we combine
    tallied$role = 'all' # add a new column to differentiate when we combine
    tallied = rbind(tallied, tallied_DEV) # COMBINE THEM
  }
  
  techString <- formatTechString(techSelect)  # Format selectedTech for readability in title
  title <- paste0(techString, ' that respondents desire to learn in the next year') # Create title
  ylabel <- "Proportion of Respondents" # Create label
  
  
  # Now check the tally table. If it has 2 columns, we are not doign a comparison. Render the plot.
  if (ncol(tallied) == 2) {
    ggplot(data=tallied, aes(x=techVector, y=countVector)) +                  # Point to the data
      labs(title=paste0(title, " n=", nrow(devTechTable)), x=techString, y=ylabel) +  # Set title, x and y labels
      geom_bar(stat="identity", fill="steelblue") +                      # render the bars
      geom_text(aes( label=round(tallied[,2],2) ), vjust=-0.3, size=3.5) +    # rounding and position of 'total' label above bar
      theme(axis.text.x = element_text(face = "bold", color = "black",   # diagnonal x-labels
                                       size = 12, angle = 45))
  }
  
  # In this case, we are doing a comparison.
  else {
    jf = nrow(tallied)/2  # Justification-factor to be used in v/h justification
    ggplot(
      data=tallied, aes(x=techVector, y=countVector, fill=role)) +    # Point to the data, differentiate on 'role'
      labs(title=title, x=techString, y=ylabel) +                     # Set title, x and y labels
      geom_bar(stat="identity", position=position_dodge()) +          # render the bars pairs, side-by-side
      geom_text(aes( label=round( countVector, 2 ) ),                 # rounding and position of 'total' label above bar
                hjust=c( rep(0.7,ceiling(jf)), rep(0,floor(jf)) ),    # ...and modify the positions, so they dont stack
                vjust=c( rep(0.8,ceiling(jf)), rep(0,floor(jf)) ), 
                size=3.5) +
      theme(legend.position = "top", 
            axis.text.x = element_text(face = "bold", color = "black",             # diagnonal x-labels
                                       size = 12, angle = 45)) +
      scale_fill_discrete("", labels=c( paste0("all (n=", nrow(devTechTable), ")"),            # custom legend labels
                                            paste0(selectedDevTitle(devSelect), " (n=", n2, ")"))) 
      
  }
  
}

##############################################################################################
##############################################################################################
##############################################################################################

## It is important to know what people value in a company.





  