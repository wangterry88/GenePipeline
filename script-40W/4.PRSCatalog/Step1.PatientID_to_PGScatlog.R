setwd("./")

#args = commandArgs(trailingOnly=TRUE)

############ Required Packages ######################

library(data.table)
library(dplyr)

###############################################################

cat(prompt="Input your patient list (Full directory): ")
Input_list<-readLines(con="stdin",1)


cat(prompt="Output PGS table name (Short Name): ")
Output_name<-readLines(con="stdin",1)

cat(prompt="Select the TPMI data type ( [1] 30W TPMI Chip data / [2] 40W TPMI Chip data): ")
Data_type<-readLines(con="stdin",1)


######## Read User input table ########

Input_table<-fread(Input_list,sep="\t",header=T)

# Selecting columns
pat_name<-colnames(Input_table)[1]
pheno_name<-colnames(Input_table)[2]
Input<-Input_table %>% select(all_of(pat_name),all_of(pheno_name))
colnames(Input)<-c("PatientID","Pheno")


######## Check user input data type ########

tmp_30W<-c("./data/PGScatlog/TPMI-imputed/PGSCatlog-result-30W.txt")
tmp_40W<-c("./data/PGScatlog/TPMI-imputed/PGSCatlog-result-40W.txt")

if (Data_type == "1"){
    selected_data_type=tmp_30W
    print("Your selected data type is: TPMI 30W data")
}else if(Data_type == "2") {
    selected_data_type=tmp_40W
    print("Your selected data type is: TPMI 40W data")
}else {
    selected_data_type=tmp_40W
    print("(Default) Your selected data type is: TPMI 40W data")
}

######## Read Required tables ########

# CMUH Information
CMUH_info<-fread("./TPMI-list/TPMI-40W-PTID-Name.txt")
Input_CMUH_info<-left_join(Input,CMUH_info,by=c("PatientID"="PatientID"))
Input_CMUH_info<-Input_CMUH_info[,c("GenotypeName","PatientID","Sex","Age","Pheno")]

# Prepare codebook + PRS result
PGS_CodeBook<- fread("./data/PGScatlog/PRSCatlog-Codebook.txt",sep="\t",header=T,encoding ='Latin-1')

Result<- fread(selected_data_type,sep="\t")

Phen_CodeBook<-fread("./data/PGScatlog/PRSCatlog-Codebook-Phecode.txt",sep="\t",header=T,encoding ='Latin-1')

cat('\n')
cat('############## Loading Required data ############')
cat('\n')
cat('\n')
cat('Dont move, Loading Required data........')
cat('\n')
cat('\n')
cat('Required data Loading successfully!')
cat('\n')
cat('\n')
############## Search Interested Disease: #########################
cat('\n')
cat('############## Search Interested Disease ############')
cat('\n')
cat('\n')
cat('For Example:')
cat('\n')
cat('One Disease Name: Dementia')
cat('\n')
cat('Mulitiple Disease Name: Dementia|Alzheimer')
cat('\n')
cat('\n')
cat('##################################################\n')
cat('\n')
cat(prompt="Please input your interested code type: ( [1]:PGS Trait / [2]:Phencode Trait )")
cat('\n')
code_type<-readLines(con="stdin",1)

if (code_type == "1"){
    CodeBook=PGS_CodeBook
    print("Your selected code type is: PGS Trait")
}else if(code_type == "2") {
    CodeBook=Phen_CodeBook
    print("Your selected code type is: Phencode Trait")
}else {
    CodeBook=PGS_CodeBook
    print("(Default) Your selected code type is: PGS Trait")
}

cat('\n')
cat(prompt="Input your interest phenotype name (Ex: Stroke,Dementia): ")
phenotype<-readLines(con="stdin",1)

if (code_type == "1") {
    PGS_related_df<-CodeBook[grepl(phenotype,CodeBook$Trait),]
}else if(code_type == "2") {
    PGS_related_df<-CodeBook[grepl(phenotype,CodeBook$Phecode),]
}else {
    PGS_related_df<-CodeBook[grepl(phenotype,CodeBook$Trait),]
}

cat('\n')
cat('Your input of PGS list is:')
cat('\n')
print(PGS_related_df[,c(1,2)])

############### Make Big PGS Table ######################

PGS_related_list<-PGS_related_df$PGSID
Full_PGS_list<-c("IID",PGS_related_list)
PGS_interested<-select(Result, matches(Full_PGS_list))
Final_Result<-inner_join(Input_CMUH_info,PGS_interested,by=c("GenotypeName"="IID"))

############### Output PGS Information: ######################

cat('Sample Num. of User Input List is:',nrow(Input))
cat('\n')
cat('\nSample Num. of User Input with TPMI Array (Passed QC) List is:',nrow(Final_Result))
cat('\n')
cat('\nInterested PRS in PGScatlog is:\n\n',sort(PGS_related_list))
cat('\n')
cat('\nNum. of Interested PRS in PGScatlog is:',length(PGS_related_list))
cat('\n')
tmp_final_PGS<-paste0('./output/PGS_of_intrested/',Output_name,'_PGS-table.txt',collapse = '')
fwrite(Final_Result,tmp_final_PGS,sep="\t",col.names = T)
cat('\n')
cat('PRS of Interested Output file is in:',tmp_final_PGS)
cat('\n')

