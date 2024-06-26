% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test_distances.R
\name{pcs_distances}
\alias{pcs_distances}
\title{pcs_distances}
\usage{
pcs_distances(pca_input, output_name, sources_file, return_plot = NULL)
}
\arguments{
\item{pca_input}{Dataframe or table with PCA results}

\item{output_name}{String indicating output name}

\item{sources_file}{Two columns table: S1 and S2. Contains the pairs of sources that will be compared.}

\item{return_plot}{NULL by default or 'YES' to plot with ggplot2}
}
\value{
Returns an output_name.csv file with the cumulative distances

Returns a output_name.pdf file with the cumulative distances
}
\description{
pcs_distances allows to estimate the cumulative euclidean distances of the PCs between the Sources, and plot the results (return_plot = 'YES').
}
\examples{
\dontrun{
Source_D = read.table('data/Sources_Distances', header =T)
pca = read_flash(pca_input = 'data/TOY_flash.pca')
pcs_distances(pca, 'data/output_distances', sources_file = Source_D, return_plot = 'YES')
}
}
