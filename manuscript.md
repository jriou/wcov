# Early transmission characteristics of Wuhan 2019-nCoV

Julien Riou and Christian L. Althaus

Institute of Social and Preventive Medicine, University of Bern, Bern, Switzerland

Correspondence to: julien.riou@ispm.unibe.ch or christian.althaus@ispm.unibe.ch

**‌
On December 30, 2019, Chinese authorities informed about a cluster of pneumonia of unknown etiology that was later identified to be caused by the emergence of a new coronavirus (2019-nCoV) in the city of Wuhan. As of January 22, 2020, 453 cases have been confirmed in China and 10 cases in several other countries. Understanding the transmission characteristics and the potential for sustained human-to-human transmission of 2019-nCoV is critically important for coordinating current screening and containment strategies. We performed stochastic simulations of early outbreak trajectories that are consistent with the epidemiological findings to date. We found that transmission of 2019-nCoV appears to be similar to severe acute respiratory syndrome-related coronavirus (SARS-CoV), with considerable potential for superspreading events. These findings underline the importance of heightened surveillance and screening, particularly at airports, in order to prevent further international spread of 2019-nCoV.**

## Introduction
- Info about outbreak
- Why it is important to understand transmission characteristics, and why we want to know $k$ and superspreading (limitation of study by Leung).

We used stochastic simulations in order to identify the likely transmission characteristics that have results in the early outbreak trajectory as reported to date.

## Methods
We performed stochastic simulations of the early epidemic spread of 2019-nCoV. Simulations were initialized with $n$ index cases, corresponding to the number of zoonotic animal-to-human transmissions at the wet market in Wuhan. For each infected case, we generated secondary cases according to a negative-binomial offspring distribution with mean $R_0$ and dispersion $k$. The generation time interval $D$ was assumed to be gamma-distributed with a shape parameter of 2. We further varied the date $T$ of the zoonotic transmission events.

We explored a wide range of parameter combinations (Table 1) and ran 10,000 stochastic simulations for each individual combination. This corresponds to a total of 32 million individual simulations that were run on UBELIX ([http://www.id.unibe.ch/hpc](http://www.id.unibe.ch/hpc)), the high performance computing cluster at the University of Bern. For each individual combination of $R_0$ and $k$, we calculated the proportion of stochastic simulations that reached a total number of infected cases within the interval [427, 4,471] by January 12, 2020, as estimated by Imai et al. (REF). Model simulations and analyses were performed in `R` (REF). Code files are available on GitHub: [https://github.com/jriou/wcov](https://github.com/jriou/wcov)

Table 1: Parameter ranges for stochastic simulations of outbreak trajectories (POSSIBLY ADD REFS FOR PARAMETER ASSUMPTIONS).

Parameter | Description | Range
--- | --- | ---
$R_0$ | Basic reproduction number | [0.8, 8.0]
$k$ | Dispersion parameter | [0.01, 10]
$D$ | Generation time interval | [7, 14]
$n$ | Initial number of index cases | [1, 30]
$T$ | Date of zoonotic transmission | [20 Nov 2019, 4 Dec 2019]

## Results
In order to reach between 427 - 4,471 infected cases by January 12, 2020, transmission of 2019-nCoV must be either characterized by high values of $R_0$ (> 5) and $k$ (> 1), or intermediate values of $R_0$ ([2, 5]) and low values of $k$ (< 1). The latter scenario is similar to what has been estimated for SARS-CoV and indicates the considerable potential for superspreading of 2019-nCoV.

## Discussion
- List primary finding
- Why it is important to consider superspreading and negative-binomial offspring distributions
- Still limited data (range depends on estimate as well)
- SARS-like transmission underlines potential for pandemic
- Screening and international efforts crucial at this stage

### Acknowledgements
SNSF funding for Julien?

### Conflict of interest
None declared.

### Authors’ contributions
JR and CLA designed the study, carried out the analysis, and wrote the manuscript.

### References