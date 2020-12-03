# MC event generation with HTCondor
The set of scripts included here, are used for **Monte Carlo**
event generation using **Rivet**, on **CERN lxplus** which uses
the HTCondor batch system.

Apart from these scripts, a python configuration file with the
MC parameters and tune is also needed e.g. Pythia8 tune CUETM1.

The basic usage is as follows:
- For help message just run `./run_condor.sh`

- For submitting jobs `./run_condor.sh <python file>  <Nevents>  <Njobs>  <job flavor>`
  
  e.g. `./run_condor.sh Pythia8_CUETM1.py 10000 50 workday` 

This command will create a directory called *Condor* within the directory
where it was executed. Inside *Condor* will create replicas for python
configuration file, *submit.sub* and *exe.sh* but with the parameters
provided in the above command (e.g Number of events) parsed in those files.
Finally, using *Condor* as the submit directory, it will submit the jobs
to CERN's batch system. 
