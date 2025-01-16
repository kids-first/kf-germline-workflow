#!/usr/bin/env Rscript

# plotting.R script loads ggplot and gridExtra libraries and defines functions to plot variant annotations
# Usage:
# Rscript gatk_plot_annotations.R <output_basename> <input_type> <input_file> <input_field_1> <input_field_2> ... <input_field_n>
#     <output_basename> <input_type> and <input_file> are required
#     <input_field_1> <input_field_2> ... <input_field_n> are optional overrides to the field names that will be plotted

library(ggplot2)
library(gridExtra)
library(readr)

# Function for making density plots of a single annotation
makeDensityPlot <- function(dataframe, xvar, split, xmin=min(dataframe[xvar], na.rm=TRUE), xmax=max(dataframe[xvar], na.rm=TRUE), alpha=0.5, log10=FALSE) {
    if(missing(split)) {
        plot = ggplot(data=dataframe, aes_string(x=xvar)) + xlim(xmin,xmax) + geom_density()
        if (log10) {
            plot = plot + scale_x_log10()
        }
        return(plot)
    }
    else {
        return(ggplot(data=dataframe, aes_string(x=xvar, fill=split)) + xlim(xmin,xmax) + geom_density(alpha=alpha) )
    }
}

args <- commandArgs(trailingOnly=TRUE)

if (length(args) < 3) {
    stop("Three arguments are required. First, an ouptut_basename. Second, the input type. Third, the input table.", call.=FALSE)
}

output_basename <- args[1]
input_type <- args[2]
input_file <- args[3]
input_fields <- if (length(args) > 3) tail(args, -3)

message(paste("Loading", input_file))
sampleSNP <- read_delim(input_file, "\t", escape_double = FALSE, trim_ws = TRUE)

message(paste("Picking annotations for", input_type))
snp_annots <- c("QD", "QUAL", "SOR", "FS", "MQ", "MQRankSum", "ReadPosRankSum")
indel_annots <- c("QD", "QUAL", "FS", "ReadPosRankSum")
mode_annots <- if (input_type=="SNP") snp_annots else indel_annots
picked_annots <- if (is.null(input_fields)) mode_annots else input_fields

for (annot in picked_annots) {
    message(paste("Creating Density Plot for", annot))
    if (annot %in% c("FS", "QUAL")) {
        plot <- makeDensityPlot(sampleSNP, annot, log10 = TRUE)
    }
    else {
        plot <- makeDensityPlot(sampleSNP, annot)
    }
    message(paste("Saving plot to", paste(output_basename, input_type, annot, "plot.pdf", sep=".")))
    ggsave(plot, filename=paste(output_basename, input_type, annot, "plot.pdf", sep="."))
}
