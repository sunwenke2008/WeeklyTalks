---
title: "Oct 05th - Corey O'Connor and Saman Farahmand"
weight: 6
---

__Presentation resourses:__

- [Presentation slides (pdf version)](Modeling Cellular Response and Casual Inference Engine.pdf)

__Title:__ Modeling Cellular Response and Causal Inference Engine
</br>
</br>
__Abstract:__ Identification of active regulatory pathways under specific molecular and environmental perturbations is crucial for understanding cellular function. However, inferring causal regulatory mechanisms directly from differential gene expression data is very difficult and remains a central challenge in computational biology. Over the past few decades, biomedical research has assembled vast repositories of regulatory biomolecular interactions and signaling cascades that can be utilized in conjunction with gene expression profiles to identify active regulators of differential gene expression. There are proprietary tools which facilitate discovery of causal regulators such as the Ingenuity Pathway. However, proprietary tools are prohibitively expensive for academia. There are also academic algorithms and methods such as those for Fisher, Ternary and Quaternary enrichment. These methods, combined with publicly available regulator-target databases (BEL, ChIP Atlas, STRINGdb, etc) and differential gene expression values, can identify causal regulators. ChIP Atlas had detailed information about interactions, such as the cell line it was observed in and the binding score. However, it does not include the directionality of the interaction because it is based on ChIP-seq experiments which do not elucidate this matter. Lack of directionality impairs the accurate prediction of causal regulators. As a result, we propose a text-mining pipeline as well as a statistical approach to find the signs of regulatory interactions. We have developed a R package and web application to facilitate the discovery of causal regulators.