#!/bin/bash 

if [ "$#" -ne 4 ]; then
  echo
  printf "=%.0s" {1..73}; printf "\n"
  echo "Usage:   $0  <python file>  <Nevents>  <Njobs>  <job flavor>"
  printf "=%.0s" {1..73}; printf "\n"
  echo "python file    ---> the cfg file for the event generation"
  echo "Nevents        ---> the number of events to be generated"
  echo "Njobs          ---> the number of jobs to be submitted"
  echo "job flavor     ---> choose one from the following list:"
  echo "                         - espresso     (20 min)"  
  echo "                         - microcentury (1 hour)"
  echo "                         - longlunch    (2 hour)"
  echo "                         - workday      (8 hour)"
  echo "                         - tomorrow     (1 day)"
  echo "                         - testmatch    (3 days)"
  echo "                         - nextweek     (1 week)"
  printf "=%.0s" {1..73}; printf "\n"
  echo
  exit 1
fi

# Python configuration file with and without extension
pyfile="$1"
if [ ! -f "$pyfile" ]; then
  echo "Error : Cannot find $pyfile"
  exit 1
fi
cfgpy=$(echo "$pyfile" | cut -f 1 -d '.')

# Number of events must be positive integer
Nevents=$2
if ! [[ "$Nevents" =~ ^[0-9]+$ ]] ; then
   echo "Error : Invalid number of events"
   exit 1
fi

# Number of jobs must be positive integer
Njobs=$3
if ! [[ "$Njobs" =~ ^[0-9]+$ ]] ; then
   echo "Error : Invalid number of jobs"
   exit 1
fi

# Job flavor should be in the list above
flav=$4
if ! [[ "$flav" =~ ^(espresso|microcentury|longlunch|workday|tomorrow|testmatch|nextweek)$ ]]; then
    echo "Error : Invalid job flavor"
    exit 1
fi

# Original scripts
orgexe="exe.sh"
orgsub="submit.sub"

# New scripts where the parameters are set
newexe="$cfgpy".sh
newsub="$cfgpy"_"$Njobs"jobs_"$flav".sub
newcfg="$cfgpy"_"$Nevents"events.py

# Apply the changes to the scripts and save them to the new files
# MC events to be generated in py file
sed 's@ *input = cms.untracked.int32([^)]*)@    input = cms.untracked.int32('$Nevents')@' $pyfile > $newcfg

sed 's@afspath@'$PWD'/Condor@g' $orgexe > $newexe    # path to afs directory in the executable
sed -i 's@cfg.py@'$newcfg'@g' $newexe                # config filename in the executable
chmod 744 $newexe  

sed 's@exe.sh@'$newexe'@g' $orgsub > $newsub         # executable name in the submit file
sed -i 's@cfg.py@'$newcfg'@g' $newsub                # config filename in the submit file
sed -i 's@config.py@'$cfgpy'@g' $newsub              # output filename in the submit file
sed -i 's@flavour@'$flav'@g' $newsub                 # job flavor in the submit file
sed -i 's@Njobs@'$Njobs'@g' $newsub                  # number of jobs to be submitted

# Check whether directory Condor exists, otherwise create 
# it and move inside it to proceed with job submission
if [ ! -d Condor ]; then
    mkdir Condor
fi

# New scripts will be moved inside Condor
mv $newcfg ./Condor
mv $newexe ./Condor
mv $newsub ./Condor
cd ./Condor

# Create directories error - log - output
if [ ! -d error ]; then
    mkdir error
fi
if [ ! -d log ]; then
    mkdir log
fi
if [ ! -d output ]; then
    mkdir output
fi

# Submit the jobs
condor_submit $newsub

echo
printf "=%.0s" {1..61}; printf "\n"
echo "                 $Njobs jobs submitted with:"
printf "=%.0s" {1..61}; printf "\n"
echo "submit file ---> $newsub"
echo "python file ---> $newcfg"
echo "executable  ---> $newexe" 
echo "submit dir  ---> $PWD"
printf "=%.0s" {1..61}; printf "\n"
echo
