---
title: "Oct 26th - Prof David Degras"
weight: 11
---

__Presentation resourses:__

<!-- - [Presentation slides (pdf version)](PR2.pdf) -->

__Title:__ Online Principal Component Analysis in High Dimension: Which Algorithm to Choose?
</br>
</br>
__Abstract:__ Principal component analysis (PCA) is one of the most widely used statistical techniques for exploring multivariate data and reducing data dimension before further statistical analysis. Over the past, applications of PCA have mostly involved static datasets (“offline” or “batch” PCA). In the current era of data deluge, however, many analytic tasks require performing PCA on time-varying data (e.g. data streams) and/or on massive datasets that do not fit in computer random access memory. Examples include industrial process monitoring, video surveillance, face and voice recognition, natural language processing, network intrusion detection, sensor networks, and stock market tracking. The goal in these applications is to develop online algorithms that can efficiently update the PCA of a dataset when this dataset is modified, as opposed to recalculating an entire PCA from scratch.

In this talk, I will give an overview of the available online PCA algorithms, discuss their mathematical foundations, and compare their empirical performances. Time permitting, I will give a demonstration of the R package onlinePCA that implements these approaches. The talk is based on a joint paper with Hervé Cardot and can be found here in open access: 
https://onlinelibrary.wiley.com/doi/10.1111/insr.12220
The package onlinePCA can be downloaded on the CRAN website: https://CRAN.R-project.org/package=onlinePCA

