nextflow.enable.dsl=2

params.input = null
params.outdir = 'results/fastqc'

if (!params.input) {
  error "Please provide --input paths.tsv"
}

process FASTQC {
  tag { fastq.simpleName }
  label 'process_single'
  container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

  input:
  path fastq

  output:
  path '*_fastqc.{html,zip}'

  script:
  """
  fastqc --threads ${task.cpus} ${fastq}
  """
}

workflow {
  Channel
    .fromPath(params.input)
    .splitText()
    .map { it.trim() }
    .filter { it && !it.startsWith('#') }
    .map { file(it) }
    | FASTQC

  FASTQC.out.view()
}
