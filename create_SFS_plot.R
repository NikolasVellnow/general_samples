
setwd("~/sciebo/Postdoc TU Dortmund/general_samples")

# function to calculate proportion of snps
normalize <- function(x) x/sum(x)
sfs <- scan("teutoburg_sfs.sfs")
# take only the first counts because it is a "folded" spectrum
sfs <- sfs[2:11]
sfs <- normalize(sfs)

barplot(sfs,
        names = seq(1:10),
        main = "Teutoburg SFS",
        xlab = "Allele frequency",
        ylab = "Proportion of SNPs",
        ylim = c(0.0, 0.4))
grid(nx = NA,
     ny = 8,
     lty = 2, col = "gray", lwd = 1.5)
barplot(sfs,
        names = seq(1:10),
        main = "Teutoburg SFS (no quality filter)",
        xlab = "Allele frequency",
        ylab = "Proportion of SNPs",
        ylim = c(0.0, 0.4),
        add = TRUE)
