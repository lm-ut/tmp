#' read.resampling
#'
#' read.resampling reads all resampled PCAs and performs ASAP on each one. It returns a list containing all ASAP results per each resampling. The output can then be used in the se.resampling function, to estimate the standard error.
#' @param path_tofiles string containing directory path to the resampling files.
#' @param file_pattern string containing common pattern to find the all PCAs obtained by resampling
#' @param as_file R data.frame with two columns: POP and A/S, POP column lists all populations to be considered, A/S indicates whether the population should be considered as Admixed ('A') or as Source ('S')
#' @param eigentype if present, PCA will be read through read_eigen() function, if absent PCA will be loaded via read_flash()
#' @examples
#' \dontrun{
#' example_as = read.table('data/Example_AS', header=TRUE)
#' pca_jackknife = read.resampling(path_tofiles = 'data/', file_pattern = '*_Jack*', as_file = example_as, eigentype) #OR
#' pca_jackknife = read.resampling(path_tofiles = 'data/', file_pattern = '*_Jack*', as_file = example_as)
#' }
#' @return Returns a table containing the ASAP results per each resampled set.
#' @export

read.resampling <- function(path_tofiles, file_pattern, as_file, eigentype) {

jack_files = list.files(path = path_tofiles, pattern=file_pattern)
print(paste0("Now reading:", jack_files))

nnlsjack <- list()
t = 0
for (i in jack_files) {
  x = 1 + t
if (missing(eigentype)) {
  pca_tmp = read_flash(pca_input = paste0(path_tofiles,i))
} else {
  pca_tmp = read_eigen(pca_input = paste0(path_tofiles,i))
}

### ASAP step

  asap_tmp = asap(pca_input = pca_tmp, as_file)
  nnlsjack[[x]] <- asap_tmp[[1]]
  t = t + 1
}

return(nnlsjack)
}

#' se.resampling
#'
#' se.resampling estimates the Standard Error comparing a main ASAP run and multiple other ASAP runs, for example runs obtained with jackknife resampling. se.resampling takes three inputs: a list with the main ASAP result, a list with the resampling ASAP results, and a numeric vector containing the number of SNPs per each chromosome.
#' @param nnls_main list obtained from the asap() function on the main set.
#' @param nnls_resampling list contining multilpe asap() function results, on the resampled set.
#' @param chromovec a numeric vector containing the number of SNPs per each chromosome (ie. chromovec = rep(1000,times = 22))
#' @examples
#' \dontrun{
#' se.resampling(nnls_main = ASAP_main, nnls_resampling = ASAP_resampling, chromovec)
#' }
#' @return Returns a table containing the standard error per each target given the source group.
#' @export

se.resampling=function(nnls_main,nnls_resampling,chromovec){
  #nnls=my.newNNLSorig
  #nnlsjack=jacKnife
  #### FOR NOW
  nnls = nnls_main[[1]]

  poplist=matrix(NA,nrow=nrow(nnls),ncol=ncol(nnls))
  h.j=sum(chromovec)/chromovec
  jackValue=function(nnlsj.vec){sum((1.0-chromovec/sum(chromovec))*nnlsj.vec)}
  se.value=function(nnls.obs,nnls.jvec,jack.val){sum((1.0/(h.j-1.0))*
                                                       (h.j*nnls.obs-(h.j-1.0)*
                                                          nnls.jvec-length(chromovec)*nnls.obs+jack.val)^2)}
  i=1
  if (unique((rownames(nnls)==rownames(nnls_resampling[[1]])))==TRUE){
    for (x in rownames(nnls)){
      tmp.nnls=t(sapply(nnls_resampling,function(X)X[x,]))
      tmp.jack=apply(tmp.nnls,2,jackValue)
      a=list()
      for (y in 1:ncol(nnls)){
        a[[y]]=se.value(nnls[x,y],tmp.nnls[,y],tmp.jack[y])
      }
      a=unlist(a)
      poplist[i,]=a
      i=i+1

    } } else {stop ("Rownames of the two inputs are DIFFERENT")}
  colnames(poplist)=colnames(nnls)
  rownames(poplist)=rownames(nnls)
  ### This should be edited
  poplist=sqrt(poplist/20)
  return(poplist)}

