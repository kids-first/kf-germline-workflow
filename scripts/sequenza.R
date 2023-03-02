
suppressPackageStartupMessages(library(optparse))
suppressPackageStartupMessages(library(sequenza))

option_list <- list(
    # Required
    make_option(c("--sample_name", "-s"), dest="sample_name", action="store", default = NA, type = 'character',
                help = "[Required] Name of the sample"),
    make_option(c("--sample_input", "-i"), dest="sample_input", action="store", default = NA, type = 'character',
                help = "[Required] Path to the sample.seqz.gz file"),
    make_option(c("--out_dir", "-o"), dest="out_dir", action="store", default = NA, type = 'character',
                help = "[Required] Output directory")
)

opt <- parse_args(OptionParser(option_list=option_list))

#reading in data
sample_name <- opt[["sample_name"]]
sample_input <- opt[["sample_input"]]
out_dir <- opt[["out_dir"]]

seqz.data <- read.seqz(sample_input)
str(seqz.data, vec.len=2)

brk<-list()
chromosome.list <- c(1:38,"X")
for (i in chromosome.list){
    brk[[i]] <- falcon.seg.seqz(sample_input, chromosome = i, centromeres = centromeres)
}
breaks <- do.call(rbind, brk)

options("scipen"=100, "digits"=4)
#this will force the program to read the regions as only straight values and not as exponential

sample <- sequenza.extract(sample_input, chromosome.list=chromosome.list, parallel = 4)

#estimates cellularity and ploidy
CP <- sequenza.fit(sample, mc.core = 4, segment.filter= 5e6)

sequenza.results(sample, CP, out.dir=out_dir, sample.id = sample_name, chromosome.list = chromosome.list)

png(file=paste(paste(out_dir,sample_name,sep='/'),'Maximum_Likelihood_plot.png',sep='_'),type='cairo')
cp.plot(CP)
cp.plot.contours(CP, add = TRUE,
   likThresh = c(0.999, 0.95),
   col = c("lightsalmon", "red"), pch = 20)
