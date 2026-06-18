## `00.assembly.sh`
Scripts for genome assembly, quality control, and annotation of long-read sequencing data. This workflow generates high-quality genome assemblies and predicts genomic features, including coding sequences and functional annotations.

## `01.hit_modules_scripts`
Scripts for identifying genes belonging to the 14 target modules in newly assembled genomes. The workflow searches annotated genes against a reference module database and retains high-confidence module assignments based on module gene coverage.

## `02.get_neighbors_scripts`
Scripts for extracting genomic neighborhoods surrounding target modules in each assembled genome. The workflow identifies genes flanking module-associated genes to facilitate analyses of genomic context, synteny, and gene co-localization.