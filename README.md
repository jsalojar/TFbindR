# TFbindR

Counting the occurence of transcription factor binding motifs in a set of provided sequences upstream from the translation start site. This is used for performing motif enrichment analysis. First, the occurence matrix is constructed, by scanning FIMO files or a list of regular expressions representing the transcription factor binding motifs, and the set of sequences in FASTA format. The occurence is identified for both, the sense and antisense strands. The enrichment analysis performs a Fisher's exact test for identification of enriched motifs in a set of genes of interest. 
